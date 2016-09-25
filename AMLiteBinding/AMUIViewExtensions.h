//
//  AMUIViewExtensions.h
//  
//
//  Created by Mellong Lau on 16/8/11.
//  Copyright © 2016年 Mellong Lau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMNSObjectExtensions.h"

@interface UIView (AM)

DECLARE_PROPERTY_RUNTIME(argList, NSArray)
DECLARE_PROPERTY_RUNTIME(itemFormat, NSString)
DECLARE_PROPERTY_RUNTIME(keyPath, NSString)

@end

@interface UIView (BM)
DECLARE_PROPERTY_RUNTIME(defaultText_v, NSString)
@end