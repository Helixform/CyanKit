//
//  Created by ktiays on 2022/10/23.
//  Copyright (c) 2022 ktiays. All rights reserved.
//

#if __has_include (<UIKit/UIKit.h>)

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CAKApplicationSPI : NSObject

+ (void)suspend;

/// Changes the icon the system displays for the app.
///
/// - Parameters:
///   - iconName: The name of the alternate icon, as declared in the `CFBundleAlternateIcons` key of your app's `Info.plist` file.
///   Specify `nil` if you want to display the app's primary icon, which you declare using the `CFBundlePrimaryIcon` key.
///   Both keys are subentries of the `CFBundleIcons` key in your app's `Info.plist` file.
///   - completionHandler: The handler to execute with the results. After attempting to change your app’s icon, the system reports the results by calling your handler. The handler executes on a UIKit-provided queue, and not necessarily on your app’s main queue.
+ (void)setAlternateIconName:(NSString * _Nullable)iconName
           completionHandler:(void (^)(NSError * _Nullable))completionHandler;

@end

NS_ASSUME_NONNULL_END

#endif
