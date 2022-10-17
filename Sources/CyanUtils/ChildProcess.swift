//
//  Created by Cyandev on 2022/10/17.
//  Copyright (c) 2022 Cyandev. All rights reserved.
//

import Foundation

#if os(macOS)
@MainActor
class ChildProcess {
    
    struct Builder {
        
        let executablePath: String
        var arguments = [String]()
        var environment = [String : String]()
        
        init(executablePath: String) {
            self.executablePath = executablePath
        }
        
        func addArgument(_ argument: String) -> Builder {
            var newBuilder = self
            newBuilder.arguments.append(argument)
            return newBuilder
        }
        
        func addEnvironmentVariable(_ value: String, forKey key: String) -> Builder {
            var newBuilder = self
            newBuilder.environment[key] = value
            return newBuilder
        }
        
    }
    
    let executablePath: String
    let arguments: [String]
    let environment: [String : String]
    
    var stdoutStream: AsyncStream<Data>? {
        guard let stdoutFileDescriptor = self.stdoutFileDescriptor else {
            return nil
        }
        
        return AsyncStream(Data.self, bufferingPolicy: .unbounded) { cont in
            self.stdoutFDRefCount += 1
            let source = DispatchSource.makeReadSource(
                fileDescriptor: stdoutFileDescriptor,
                queue: .main)
            source.setEventHandler(handler: .init {
                var data = Data()
                defer {
                    if !data.isEmpty {
                        cont.yield(data)
                    }
                }
                while true {
                    let bufferSize = 1024
                    var buffer = Data(count: bufferSize)
                    let readCount = buffer.withUnsafeMutableBytes { pointer in
                        return read(stdoutFileDescriptor, pointer.baseAddress, bufferSize)
                    }
                    
                    // Handle end-of-file or interruption.
                    if readCount <= 0 {
                        if errno == EINTR {
                            continue
                        } else if errno == EAGAIN {
                            if !self.isRunning {
                                // No data available and the process is terminated,
                                // there will not be data produced anymore.
                                cont.finish()
                            }
                        } else {
                            // Other error occurred, just close the stream.
                            cont.finish()
                        }
                        return
                    }
                    
                    data.append(buffer.subdata(in: 0..<readCount))
                }
            })
            
            cont.onTermination = { _ in
                source.cancel()
                DispatchQueue.main.async {
                    self.stdoutFDRefCount -= 1
                }
            }
            
            source.resume()
        }
    }
    
    private(set) var isRunning = false
    private(set) var pid: pid_t?
    
    private var stdinFileDescriptor: Int32?
    private var stdoutFileDescriptor: Int32?
    private var stdoutFDRefCount = 0 {
        didSet {
            if stdoutFDRefCount == 0 {
                let _ = stdoutFileDescriptor.map { close($0) }
                stdoutFileDescriptor = nil
            }
        }
    }
    private var exitContinuations = [CheckedContinuation<Int, Error>]()
    private var processSource: DispatchSourceProcess?
    
    deinit {
        // No-op
    }
    
    init(builder: Builder) {
        self.executablePath = builder.executablePath
        self.arguments = builder.arguments
        self.environment = builder.environment
    }
    
    func start() throws {
        guard !isRunning else {
            return
        }
        
        // Setup the file actions.
        var fileActions: posix_spawn_file_actions_t!
        var errorCode = posix_spawn_file_actions_init(&fileActions)
        guard errorCode == 0 else {
            throw AnyError(message: "posix_spawn_file_actions_init failed with error code: \(errorCode)")
        }
        defer { posix_spawn_file_actions_destroy(&fileActions) }
        
        let stdinPipeFds = try Self.createPipe()
        let stdoutPipeFds = try Self.createPipe()
        
        posix_spawn_file_actions_adddup2(&fileActions, stdinPipeFds.0, STDIN_FILENO)
        posix_spawn_file_actions_addclose(&fileActions, stdinPipeFds.0)
        posix_spawn_file_actions_adddup2(&fileActions, stdoutPipeFds.1, STDOUT_FILENO)
        posix_spawn_file_actions_addclose(&fileActions, stdoutPipeFds.1)
        
        // Convert strings for C APIs.
        let argv = Self.makeCStringArray(forStrings: [executablePath] + arguments)
        defer { argv.forEach { $0.map { free(.init($0)) } } }
        
        let envp = Self.makeCStringArray(forStrings: environment.map { "\($0.key)=\($0.value)" })
        defer { envp.forEach { $0.map { free(.init($0)) } } }
        
        // Start the process!
        var pid: pid_t! = -1
        errorCode = argv.withUnsafeBufferPointer { argvPointer in
            return envp.withUnsafeBufferPointer { envpPointer in
                return posix_spawn(&pid, executablePath, &fileActions, nil,
                                   argvPointer.baseAddress, envpPointer.baseAddress)
            }
        }
        
        guard errorCode == 0 else {
            throw AnyError(message: "posix_spawn failed with error code: \(errorCode)")
        }
        
        // Listen for child-process events.
        let processSource = DispatchSource.makeProcessSource(identifier: pid,
                                                             eventMask: [.exit, .signal],
                                                             queue: .main)
        processSource.setEventHandler(handler: .init {
            self.handleProcessEvent()
        })
        processSource.resume()
        self.processSource = processSource
        
        stdinFileDescriptor = stdinPipeFds.1
        stdoutFileDescriptor = stdoutPipeFds.0
        stdoutFDRefCount = 1
        close(stdinPipeFds.0)
        close(stdoutPipeFds.1)
        self.pid = pid
        isRunning = true
    }
    
    func waitUntilExit() async throws -> Int {
        guard isRunning else {
            throw AnyError(message: "Child process is not running")
        }
        
        return try await withCheckedThrowingContinuation { cont in
            exitContinuations.append(cont)
        }
    }
    
    private func handleProcessEvent() {
        guard isRunning else {
            return
        }
        
        guard let data = processSource?.data, let pid = self.pid else {
            fatalError("Inconsistent internal state")
        }
        
        var wstatus: Int32 = 0
        switch data {
        case .exit, .signal:
            var errorCode: pid_t = EINTR
            while errorCode == EINTR {
                errorCode = waitpid(pid, &wstatus, WNOHANG)
                if errorCode == pid {
                    break
                } else if errorCode == EAGAIN {
                    return
                }
            }
            
        default:
            return
        }
        
        // Handle exit or signal.
        let _wstatus = wstatus & 0x7f
        if _wstatus != _WSTOPPED && _wstatus != 0 {
            // The process is killed by signal.
            let error = AnyError(message: "Process was killed by signal \(_wstatus)")
            for cont in exitContinuations {
                cont.resume(throwing: error)
            }
        } else {
            for cont in exitContinuations {
                cont.resume(returning: Int(wstatus >> 8))
            }
        }
        
        // Perform clean-ups.
        isRunning = false
        let _ = stdinFileDescriptor.map { close($0) }
        stdinFileDescriptor = nil
        stdoutFDRefCount -= 1
        self.pid = nil
        processSource?.cancel()
        processSource = nil
    }
    
    private static func createPipe() throws -> (Int32, Int32) {
        var fds: [Int32] = [0, 0]
        var errorCode = fds.withUnsafeMutableBufferPointer { pointer in
            return pipe(pointer.baseAddress)
        }
        guard errorCode == 0 else {
            throw AnyError(message: "failed to create pipe with error code: \(errorCode)")
        }
        
        // Make the reading-end of the pipe non-blocking, because we will
        // use kevent to poll the data asynchrously.
        errorCode = fcntl(fds[0], F_SETFL, O_NONBLOCK)
        guard errorCode == 0 else {
            throw AnyError(message: "failed to make fd non-blocking with error code: \(errorCode)")
        }
        
        return (fds[0], fds[1])
    }
    
    private static func makeCStringArray(forStrings strings: [String]) -> [UnsafeMutablePointer<CChar>?] {
        var array = [UnsafeMutablePointer<CChar>?]()
        for string in strings {
            string.withCString {
                array.append(strdup($0))
            }
        }
        array.append(nil)
        return array
    }
    
}
#endif
