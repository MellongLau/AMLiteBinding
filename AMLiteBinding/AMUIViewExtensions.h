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

AM_DECLARE_PROPERTY_RUNTIME(argList, NSArray)
AM_DECLARE_PROPERTY_RUNTIME(itemFormat, NSString)
AM_DECLARE_PROPERTY_RUNTIME(keyPath, NSString)

@end

@interface UIView (BM)
AM_DECLARE_PROPERTY_RUNTIME(defaultText_v, NSString)
@end