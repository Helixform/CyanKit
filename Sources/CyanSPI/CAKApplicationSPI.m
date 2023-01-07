//
//  Created by ktiays on 2022/10/23.
//  Copyright (c) 2022 ktiays. All rights reserved.
//

#if __has_include (<UIKit/UIKit.h>)

#import <UIKit/UIKit.h>

#import "CAKApplicationSPI.h"

@implementation CAKApplicationSPI

+ (void)suspend {
    [((id) [UIApplication sharedApplication]) suspend];
}

+ (void)setAlternateIconName:(NSString *)iconName
           completionHandler:(void (^)(NSError * _Nullable))completionHandler {
    
}

@end

#endif
