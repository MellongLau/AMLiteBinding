//
//  AMNSObjectExtensions.h
//  
//
//  Created by Mellong Lau on 16/8/11.
//  Copyright © 2016年 Mellong Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define AM_ADD_SWIZZLE_METHOD(methodName, classMethod) \
[self am_swizzleWithOriginalSelector:NSSelectorFromString(@#methodName) \
swizzledSelector:NSSelectorFromString(@"am_"#methodName) \
isClassMethod:classMethod];

#define AM_DECLARE_PROPERTY_RUNTIME(name, type)  \
@property (nonatomic, strong) type *am_##name;

#define AM_ADD_PROPERTY_RUNTIME(name, type)  \
static const void * kAM_##name;\
@dynamic am_##name;\
- (type *)am_##name\
{\
return objc_getAssociatedObject(self, &kAM_##name);\
}\
\
- (void)setAm_##name:(type *)name\
{\
objc_setAssociatedObject(self, &kAM_##name, name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);\
}

@class AMLiteBinding;

@interface NSObject (MethodSwizzler)

+ (void)am_swizzleWithOriginalSelector:(SEL)originalSelector
                      swizzledSelector:(SEL) swizzledSelector
                         isClassMethod:(BOOL)isClassMethod;

@end

@interface NSObject (AM)

AM_DECLARE_PROPERTY_RUNTIME(liteBinding, AMLiteBinding)

@end