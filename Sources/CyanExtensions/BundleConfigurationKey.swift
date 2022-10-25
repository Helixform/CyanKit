//
//  Created by ktiays on 2022/10/25.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

import Foundation

/// A structure that defines the property list key of bundle configuration.
public struct BundleConfigurationKey {
    
    /// The type of bundle.
    ///
    /// This key consists of a four-letter code for the bundle type.
    /// For apps, the code is `APPL`, for frameworks, it's `FMWK`, and for bundles, it's `BNDL`.
    /// The default value is derived from the bundle extension or, if it can't be derived, the default value is `BNDL`.
    public static let cfBundlePackageType: String = "CFBundlePackageType"
    
    #if os(macOS)
    /// The category that best describes your app for the App Store.
    public static let lsApplicationCategoryType: String = "LSApplicationCategoryType"
    #endif
    
    /// A unique identifier for a bundle.
    ///
    /// A *bundle ID* uniquely identifies a single app throughout the system.
    /// The bundle ID string must contain only alphanumeric characters (A–Z, a–z, and 0–9), hyphens (-), and periods (.).
    /// Typically, you use a reverse-DNS format for bundle ID strings.
    /// Bundle IDs are case-insensitive.
    ///
    /// The operating system uses the bundle ID to identify the app when applying specified preferences.
    /// Similarly, Launch Services uses the bundle ID to locate an app capable of opening a particular file.
    /// The bundle ID also validates an app's signature.
    ///
    /// > Important:
    /// > The bundle ID in the information property list must match the bundle ID you enter in App Store Connect.
    /// > After you upload a build to App Store Connect, you can't change the bundle ID or delete the associated explicit App ID in your developer account.
    public static let cfBundleIdentifier: String = "CFBundleIdentifier"
    
    #if os(watchOS)
    /// The bundle ID of the watchOS app.
    ///
    /// This key is automatically included in your WatchKit extension's information property list when you create a watchOS project from a template.
    public static let wkAppBundleIdentifier: String = "WKAppBundleIdentifier"
    
    /// The bundle ID of the watchOS app's companion iOS app.
    ///
    /// Xcode automatically includes this key in the WatchKit app's information property list when you create a watchOS project from a template.
    /// The value should be the same as the iOS app's `CFBundleIdentifier`.
    public static let wkCompanionAppBundleIdentifier: String = "WKCompanionAppBundleIdentifier"
    #endif
    
    /// A user-visible short name for the bundle.
    ///
    /// This name can contain up to 15 characters.
    /// The system may display it to users if `CFBundleDisplayName` isn't set.
    public static let cfBundleName: String = "CFBundleName"
    
    /// The user-visible name for the bundle, used by Siri and visible on the iOS Home screen.
    ///
    /// Use this key if you want a product name that's longer than `CFBundleName`.
    public static let cfBundleDisplayName: String = "CFBundleDisplayName"
    
    /// A replacement for the app name in text-to-speech operations.
    public static let cfBundleSpokenName: String = "CFBundleSpokenName"
    
    /// The version of the build that identifies an iteration of the bundle.
    ///
    /// This key is a machine-readable string composed of one to three period-separated integers, such as 10.14.1.
    /// The string can only contain numeric characters (0-9) and periods.
    ///
    /// Each integer provides information about the build version in the format [*Major*].[*Minor*].[*Patch*]:
    /// - Major: A major revision number.
    /// - Minor: A minor revision number.
    /// - Patch: A maintenance release number.
    ///
    /// You can include more integers but the system ignores them.
    ///
    /// You can also abbreviate the build version by using only one or two integers, where missing integers in the format are interpreted as zeros.
    /// For example, 0 specifies 0.0.0, 10 specifies 10.0.0, and 10.5 specifies 10.5.0.
    ///
    /// This key is required by the App Store and is used throughout the system to identify the version of the build.
    /// For macOS apps, increment the build version before you distribute a build.
    public static let cfBundleVersion: String = "CFBundleVersion"
    
    /// The release or version number of the bundle.
    ///
    /// This key is a user-visible string for the version of the bundle.
    /// The required format is three period-separated integers, such as 10.14.1.
    /// The string can only contain numeric characters (0-9) and periods.
    ///
    /// Each integer provides information about the build version in the format [*Major*].[*Minor*].[*Patch*]:
    /// - Major: A major revision number.
    /// - Minor: A minor revision number.
    /// - Patch: A maintenance release number.
    ///
    /// This key is used throughout the system to identify the version of the bundle.
    public static let cfBundleShortVersionString: String = "CFBundleShortVersionString"
    
    /// The current version of the Information Property List structure.
    ///
    /// Xcode adds this key automatically. Don't change the value.
    public static let cfBundleInfoDictionaryVersion: String = "CFBundleInfoDictionaryVersion"
    
    #if os(macOS)
    /// A human-readable copyright notice for the bundle.
    public static let nsHumanReadableCopyright: String = "NSHumanReadableCopyright"
    #endif
    
    #if os(macOS) || targetEnvironment(macCatalyst)
    /// The minimum version of the operating system required for the app to run in macOS.
    ///
    /// Use this key to indicate the minimum macOS release that your app supports.
    /// The App Store uses this key to indicate the macOS releases on which your app can run, and to show compatibility with a person's Mac.
    ///
    /// Starting with macOS 11.4, the lowest version number you can specify as the value for the `LSMinimumSystemVersion` key is:
    /// - `10` if your app links against the macOS SDK.
    /// - `10.15` if your app links against the iOS 14.3 SDK (or later) and builds using Mac Catalyst.
    /// - `11` if your iPad or iPhone app links against the iOS 14.3 SDK (or later) and can run on a Mac with Apple silicon.
    ///
    /// To specify the minimum version of iOS, iPadOS, tvOS, or watchOS that your app supports, use `MinimumOSVersion`.
    public static let lsMinimumSystemVersion: String = "LSMinimumSystemVersion"
    #endif
    
    #if os(macOS)
    /// The minimum version of macOS required for the app to run on a set of architectures.
    public static let lsMinimumSystemVersionByArchitecture: String = "LSMinimumSystemVersionByArchitecture"
    #else
    /// The minimum version of the operating system required for the app to run in iOS, iPadOS, tvOS, and watchOS.
    ///
    /// The App Store uses this key to indicate the OS releases on which your app can run.
    ///
    /// Don't specify `MinimumOSVersion` in the `Info.plist` file for apps built in Xcode. It uses the value of the Deployment Target in the General settings pane.
    ///
    /// For macOS, see `LSMinimumSystemVersion`.
    public static let minimumOSVersion: String = "MinimumOSVersion"
    #endif
    
    #if os(iOS)
    /// A Boolean value indicating whether the app must run in iOS.
    public static let lsRequiresIPhoneOS: String = "LSRequiresIPhoneOS"
    #endif
    
    #if os(watchOS)
    /// A Boolean value that indicates whether the bundle is a watchOS app.
    ///
    /// Xcode automatically includes this key in the WatchKit app's information property list when you create a watchOS project from a template.
    public static let wkWatchKitApp: String = "WKWatchKitApp"
    #endif
    
    /// The default language and region for the bundle, as a language ID.
    ///
    /// The system uses this key as the language if it can't locate a resource for the user's preferred language.
    /// The value should be a *language ID* that identifies a language, dialect, or script.
    public static let cfBundleDevelopmentRegion: String = "CFBundleDevelopmentRegion"
    
    /// The localizations handled manually by your app.
    public static let cfBundleLocalizations: String = "CFBundleLocalizations"
    
    /// A Boolean value that indicates whether the bundle supports the retrieval of localized strings from frameworks.
    public static let cfBundleAllowMixedLocalizations: String = "CFBundleAllowMixedLocalizations"
    
    #if os(macOS)
    /// A Boolean value that enables the Caps Lock key to switch between Latin and non-Latin input sources.
    ///
    /// Latin input sources, such as ABC, U.S., and Vietnamese, output characters in Latin script.
    /// Non-Latin input sources, such as Bulgarian (Cyrillic script), Hindi (Devanagari script), and Urdu (Arabic script), output characters in scripts other than Latin.
    ///
    /// After implementing the key, users can enable or disable this functionality by modifying the "Use Caps Lock to switch to and from" preference,
    /// which can be found in System Preferences > Keyboard > Input Sources.
    public static let latinInputCapsLockLanguageSwitchCapable: String = "TICapsLockLanguageSwitchCapable"
    
    /// The name of the bundle's HTML help file.
    public static let cfAppleHelpAnchor: String = "CFAppleHelpAnchor"
    
    /// The name of the help file that will be opened in Help Viewer.
    public static let cfBundleHelpBookName: String = "CFBundleHelpBookName"
    
    /// The name of the folder containing the bundle's help files.
    public static let cfBundleHelpBookFolder: String = "CFBundleHelpBookFolder"
    #endif
    
}
