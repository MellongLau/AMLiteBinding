//
//  AMLiteBinding.h
//  
//
//  Created by Mellong Lau on 16/8/9.
//  Copyright © 2016年 Mellong Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface AMLiteBinding: NSObject

+ (instancetype)liteBindingWithView:(UIView *)view;
+ (instancetype)liteBindingWithViewController:(UIViewController *)viewController;
- (void)updateDataBinding;

@end


@protocol AMLiteBinding <NSObject>

@end