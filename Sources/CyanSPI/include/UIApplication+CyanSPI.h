//
//  Created by ktiays on 2022/10/23.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

#import <UIKit/UIKit.h>

extern void CAKApplicationSetAlternateIconNameWithCompletionHandler(NSString *iconName, void (^completionHandler)(NSError * _Nullable));

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (CyanSPI)

- (void)suspend;

@end

NS_ASSUME_NONNULL_END
