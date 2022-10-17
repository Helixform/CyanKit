//
//  Created by Cyandev on 2022/10/17.
//  Copyright (c) 2022 Cyandev. All rights reserved.
//

import XCTest
@testable import CyanUtils

@MainActor
final class ChildProcessTests: XCTestCase {
    
    func testSimpleExecution() async throws {
        let childProcess = ChildProcess(builder:
                .init(executablePath: "/bin/sleep")
                .addArgument("1"))
        try childProcess.start()
        
        let pid = Int(childProcess.pid ?? 0)
        XCTAssertGreaterThan(pid, 0)
        
        let exitCode = try await childProcess.waitUntilExit()
        XCTAssertEqual(exitCode, 0)
    }
    
    func testReadingStdout() async throws {
        let childProcess = ChildProcess(builder:
                .init(executablePath: "/usr/bin/uname")
                .addArgument("-a"))
        try childProcess.start()
        
        let pid = Int(childProcess.pid ?? 0)
        XCTAssertGreaterThan(pid, 0)
        
        let readTask = Task<String?, Error> {
            guard let stdoutStream = childProcess.stdoutStream else {
                throw AnyError(message: "No stdout stream available")
            }
            var fullData = Data()
            for await stdoutData in stdoutStream {
                print("Read \(stdoutData.count) bytes from stdout")
                fullData.append(stdoutData)
            }
            return String(data: fullData, encoding: .utf8)
        }
        
        let exitCode = try await childProcess.waitUntilExit()
        XCTAssertEqual(exitCode, 0)
        
        guard let result = try await readTask.value else {
            XCTFail("Unexpected stdout data")
            return
        }
        XCTAssertTrue(result.contains("Darwin") && result.contains("xnu"))
    }
    
    @available(macOS 13.0, *)
    func testLongTermProcess() async throws {
        let childProcess = ChildProcess(builder:
                .init(executablePath: "/usr/bin/yes"))
        try childProcess.start()
        
        let pid = Int(childProcess.pid ?? 0)
        XCTAssertGreaterThan(pid, 0)
        
        // Because the program will not exit unless user kills it, we will
        // send a `SIGTERM` to it after 1 second.
        Task {
            try await Task.sleep(for: .seconds(1))
            kill(Int32(pid), SIGTERM)
        }
        
        guard let stdoutStream = childProcess.stdoutStream else {
            XCTFail("No stdout stream available")
            return
        }
        
        let exitCode = try await childProcess.waitUntilExit()
        XCTAssertEqual(exitCode, 0)
        
        var totalReadCount = 0
        for await stdoutData in stdoutStream {
            totalReadCount += stdoutData.count
        }
        XCTAssertGreaterThan(totalReadCount, 0)
    }
    
}
