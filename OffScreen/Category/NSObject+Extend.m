//
//  NSObject+Extend.m
//
//  Created by 苏沫离 on 2018/2/16.
//

#import "NSObject+Extend.h"
#import <objc/runtime.h>

@implementation NSObject (Swizzling)

+ (void)methodSwizzlingWithOriginalSelector:(SEL)originalSelector bySwizzledSelector:(SEL)swizzledSelector{
    Class class = [self class];
    Method originalMethod = class_getInstanceMethod(class, originalSelector);//old
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);//new
    BOOL didAddMethod = class_addMethod(class,originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod){
        class_replaceMethod(class,swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    }else{
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end


@implementation NSObject (IsEqual)

- (BOOL)isEqualToObject:(id)object{
    if (self == object){ //内存地址相同，一定相同
        return YES;
    }
    
    __block BOOL isSame = YES;

    //两个实例不属于同一个类，没有必要进行下去
    if ([self isKindOfClass:object_getClass(object)] == NO){
        return NO;
    }
    
    if (object == nil){
        return NO;
    }

    unsigned int varCount = 0;
    Ivar *ivarList = class_copyIvarList(object_getClass(self), &varCount);
    for (int i = 0; i < varCount; i ++){
        Ivar ivar = ivarList[i];
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        if ([self respondsToSelector:@selector(valueForKey:)]){
            id oldValue = [self valueForKey:key];
            id newValue = [object valueForKey:key];

            BOOL haveEqual = (!oldValue && !newValue) || [oldValue isEqual:newValue];
            if (haveEqual == NO){
                isSame = NO;
                break;
            }
        }
    }
    free(ivarList);
    return isSame;
}

@end




@implementation NSObject (GetTheController)

+ (UIViewController *)getCurrentViewController
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    result = window.rootViewController;
    while (result.presentedViewController) {
        result = result.presentedViewController;
    }
    
    if ([result isKindOfClass:[UITabBarController class]]) {
        result = [(UITabBarController *)result selectedViewController];
    }
    
    if ([result isKindOfClass:[UINavigationController class]]) {
        result = [(UINavigationController *)result topViewController];
    }
    
    return result;
}


@end
