//
//  AMUIViewExtensions.m
//  
//
//  Created by Mellong Lau on 16/8/11.
//  Copyright © 2016年 Mellong Lau. All rights reserved.
//

#import "AMUIViewExtensions.h"
#import "AMLiteBinding.h"
#import "AMLiteBinding.h"

@implementation UIView (AM)

ADD_PROPERTY_RUNTIME(argList, NSArray)
ADD_PROPERTY_RUNTIME(itemFormat, NSString)
ADD_PROPERTY_RUNTIME(keyPath, NSString)

@end

@implementation UIView (BM)

ADD_PROPERTY_RUNTIME(defaultText_v, NSString)

+ (void)load {
    static dispatch_once_t once_token;
    dispatch_once(&once_token,  ^{
        AM_ADD_SWIZZLE_METHOD(awakeFromNib, NO)
        AM_ADD_SWIZZLE_METHOD(removeFromSuperview, NO)
    });
}


- (void)am_awakeFromNib
{
    if ([self conformsToProtocol:@protocol(AMLiteBinding)]) {
        self.am_liteBinding = [AMLiteBinding liteBindingWithView:self];
        [self.am_liteBinding updateDataBinding];
    }
}

- (void)am_removeFromSuperview
{
    self.am_liteBinding = nil;
    [self am_removeFromSuperview];
}

@end