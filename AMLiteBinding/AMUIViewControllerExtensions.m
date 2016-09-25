//
//  AMUIViewControllerExtensions.m
//  
//
//  Created by Mellong Lau on 16/8/11.
//  Copyright © 2016年 Mellong Lau. All rights reserved.
//

#import "AMUIViewControllerExtensions.h"
#import "AMLiteBinding.h"
#import "AMLiteBinding.h"

@implementation UIViewController (AM)

AM_ADD_PROPERTY_RUNTIME(defaultText_vc, NSString)

+ (void)load {
    static dispatch_once_t once_token;
    dispatch_once(&once_token,  ^{
        AM_ADD_SWIZZLE_METHOD(viewWillAppear:, NO)
        AM_ADD_SWIZZLE_METHOD(viewWillDisappear:, NO)
    });
}

- (void)am_viewWillDisappear:(BOOL)animated
{
    [self am_viewWillDisappear:animated];
    self.am_liteBinding = nil;
}

- (void)am_viewWillAppear:(BOOL)animated
{
    [self am_viewWillAppear:animated];
    if ([self conformsToProtocol:@protocol(AMLiteBinding) ]) {
        self.am_liteBinding = [AMLiteBinding liteBindingWithViewController:self];
        [self.am_liteBinding performSelector:@selector(updateDataBinding)];

    }
}

@end
