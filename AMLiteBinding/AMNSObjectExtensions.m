//
//  AMNSObjectAddition.m
//  
//
//  Created by Mellong Lau on 16/8/11.
//  Copyright © 2016年 Mellong Lau. All rights reserved.
//

#import "AMNSObjectExtensions.h"

@implementation NSObject (MethodSwizzler)

+ (void)am_swizzleWithOriginalSelector:(SEL)originalSelector
                      swizzledSelector:(SEL) swizzledSelector
                         isClassMethod:(BOOL)isClassMethod
{
    Class cls = [self class];
    
    Method originalMethod;
    Method swizzledMethod;
    
    if (isClassMethod) {
        originalMethod = class_getClassMethod(cls, originalSelector);
        swizzledMethod = class_getClassMethod(cls, swizzledSelector);
    } else {
        originalMethod = class_getInstanceMethod(cls, originalSelector);
        swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
    }
    
    if (!originalMethod) {
        NSLog(@"Error: originalMethod is nil, did you spell it incorrectly? %@", originalMethod);
        return;
    }
    
    method_exchangeImplementations(originalMethod, swizzledMethod);
}
@end

@implementation NSObject (AM)

AM_ADD_PROPERTY_RUNTIME(liteBinding, AMLiteBinding)

@end