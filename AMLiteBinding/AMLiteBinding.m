//
//  AMLiteBinding.m
//  
//
//  Created by Mellong Lau on 16/7/22.
//  Copyright © 2016年 Mellong Lau. All rights reserved.
//

#import "AMLiteBinding.h"
#import "AMNSObjectExtensions.h"
#import "AMUIViewControllerExtensions.h"
#import "AMUIViewExtensions.h"


#define REG_INDEX_PLACEHOLDER       0
#define REG_INDEX_KEY_PATH          1
#define REG_INDEX_RECEIVER          2
#define REG_INDEX_DATE_FORMAT       4


@interface AMLiteBinding ()

@property (nonatomic, strong) NSArray *am_viewList;
@property (nonatomic, strong) NSString *am_defaultText;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, weak) id target;
@property (nonatomic, strong) NSMutableDictionary *registedKeyPaths;



@end

@implementation AMLiteBinding

- (instancetype)initWithView:(UIView *)view
{
    self = [super init];
    if (self) {
        _view = view;
        _target = view;
        _registedKeyPaths = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self) {
        _view = viewController.view;
        _target = viewController;
        _registedKeyPaths = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (instancetype)liteBindingWithView:(UIView *)view
{
    return [[self alloc] initWithView:view];
}

+ (instancetype)liteBindingWithViewController:(UIViewController *)viewController
{
    return [[self alloc] initWithViewController:viewController];
}

- (void)processEachView:(UIView *)view array:(NSMutableArray *)array
{
    static NSString *regexString = @"\\$\\{((\\w+?)(?:\\.(\\w+?))*)(?:\\s*\\|\\s*(.+?))?\\}";
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:regexString
                                                                                       options:0
                                                                                         error:NULL];
    NSString *viewText;
    
    if ([view isKindOfClass:[UIButton class]]) {
        viewText = [((UIButton *)view) titleForState:UIControlStateNormal];
    }else {
        viewText = [view performSelector:@selector(text)];
    }

    if (view.am_itemFormat) {// if item format exist, should use item format string
        viewText = view.am_itemFormat;
    }
    if (viewText == nil) {
        return;
    }
    
    NSString *displayText = [viewText copy];
    NSString *formatText = [viewText copy];
    
    NSArray<NSTextCheckingResult *> *result = [regularExpression matchesInString:viewText
                                                                         options:0
                                                                           range:NSMakeRange(0, viewText.length)];
    if (result.count == 0) {
        return ;
    }
    if (array) {
        [array addObject:view];
    }
    
    for (NSTextCheckingResult *item in result) {
        
        NSString * (^getStringByRangeIndex)(NSUInteger rangeIndex) = ^NSString *(NSUInteger rangeIndex) {
            return [viewText substringWithRange:[item rangeAtIndex:rangeIndex]];
        };
        NSString * placeholder = getStringByRangeIndex(REG_INDEX_PLACEHOLDER);
        NSString *keyPath = getStringByRangeIndex(REG_INDEX_KEY_PATH);
        NSMutableArray *argList = [NSMutableArray arrayWithArray:view.am_argList];
        
        view.am_keyPath = keyPath;
        
        NSLog(@"placeholder=%@ keyPath=%@",  placeholder, keyPath);
        
        id value = [_target valueForKeyPath:keyPath];
        
        if (!_registedKeyPaths[keyPath]) {
            [_target addObserver:self
                      forKeyPath:keyPath
                         options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                         context:(__bridge void * _Nullable)(view)];
        }
        
        [_registedKeyPaths setObject:view forKey:keyPath];
    
        NSMutableDictionary *args = [NSMutableDictionary dictionaryWithDictionary:@{@"keyPath": keyPath,
                                                                                    @"placeholder": placeholder}];
        if ([item numberOfRanges] == (REG_INDEX_DATE_FORMAT+1)) {
            if ([item rangeAtIndex:REG_INDEX_DATE_FORMAT].location != NSNotFound) {
                NSString *dateformat = getStringByRangeIndex(REG_INDEX_DATE_FORMAT);
                value = [self dateFormatStringWithDate:value format:dateformat];
                [args setObject:dateformat forKey:@"dateFormat"];
                
            }
            
        }
        
        [argList addObject:args];
        view.am_argList = argList;
        
        if (![value isKindOfClass:[NSString class]]) {
            value = [self getDefaultText];
        }
        
        
        if (value == nil) {
            return;
        }
        displayText = [displayText stringByReplacingOccurrencesOfString:placeholder
                                                             withString:value];
    }
    
    NSString * (^enableNewline)(NSString *text) = ^NSString *(NSString *text) {
        return [text stringByReplacingOccurrencesOfString:@"\\n"
                                               withString:@"\n"];
    };
    
    displayText = enableNewline(displayText);
    formatText = enableNewline(formatText);
    view.am_itemFormat = formatText;
    
    if ([view isKindOfClass:[UIButton class]]) {
        [((UIButton *)view) setTitle:displayText forState:UIControlStateNormal];
    }else {
        [view performSelector:@selector(setText:) withObject:displayText];
    }
    
}

- (void)updateDataBinding
{
    if (self.am_viewList == nil || self.am_viewList.count == 0) {
        __block NSMutableArray *array = [NSMutableArray array];
        NSDate *date = [NSDate date];
        [self processWithView:_view withBlock:^(UIView *view) {
            if (([view respondsToSelector:@selector(text)] && [view respondsToSelector:@selector(setText:)])
                || [view isKindOfClass:[UIButton class]]) {
                [self processEachView:view array:array];
                
            }
            
        }];
        NSLog(@"View Search Duration: %lf", fabs([date timeIntervalSinceNow]));
        [self setAm_viewList:array];
    }else {
        for (UIView *view in self.am_viewList) {
            [self processEachView:view array:nil];
        }
    }
}


- (NSString *)dateFormatStringWithDate:(NSDate *)date format:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}

- (void)processWithView:(UIView *)view withBlock:(void (^)(UIView *view))block
{
    if (view.subviews.count == 0) {
        return;
    }
    if ([_target isKindOfClass:[UIViewController class]] && [view conformsToProtocol:@protocol(AMLiteBinding)]) {
        return;
    }
    for (UIView *item in view.subviews) {
        if (block) {
            block(item);
            [self processWithView:item withBlock:block];
        }
    }
}

- (NSString *)getDisplayTextWithNewValue:(id)newValue
                                    item:(id)item
                              itemFormat:(NSString *)itemFormat
                             placeholder:(NSString *)placeholder
{
    NSString *format = item[@"dateFormat"];
    if (format) {
        newValue = [self dateFormatStringWithDate:newValue format:format];
    }
    return [itemFormat stringByReplacingOccurrencesOfString:placeholder
                                                 withString:newValue];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    
    UIView *view = (__bridge id _Nonnull)context;
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"keyPath = %@", keyPath];
    NSArray *result = [view.am_argList filteredArrayUsingPredicate:filterPredicate];
    if (result.count > 0) {
        
        NSString *displayText = [view.am_itemFormat copy];
        
        for (id item in view.am_argList) {
            NSString *placeholder = item[@"placeholder"];
            NSString *key = item[@"keyPath"];
            id changedValue = nil;
            if ([keyPath isEqualToString:key]) {
                changedValue = [change objectForKey:NSKeyValueChangeNewKey];
            }else {
                changedValue = [_target valueForKeyPath:key];
                
            }
            if (!changedValue || [changedValue isEqual:[NSNull null]]) {
                changedValue = [self getDefaultText];
            }
            
            displayText = [self getDisplayTextWithNewValue:changedValue
                                                      item:item
                                                itemFormat:displayText
                                               placeholder:placeholder];
        }
        
        if ([view isKindOfClass:[UIButton class]]) {
            [((UIButton *)view) setTitle:displayText forState:UIControlStateNormal];
        }else {
            [view performSelector:@selector(setText:) withObject:displayText];
        }
        
        return;
    }
    
    [super observeValueForKeyPath:keyPath
                         ofObject:object
                           change:change
                          context:context];
}

- (NSString *)getDefaultText
{
    return self.am_defaultText == nil ? @"--" : self.am_defaultText;
}

- (void)dealloc
{
    NSArray *list = [_registedKeyPaths allKeys];
    for (id key in list) {
        [_target removeObserver:self forKeyPath:key];
        [_registedKeyPaths removeObjectForKey:key];
    }
}

@end
