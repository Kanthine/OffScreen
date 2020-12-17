//
//  UIButton+Extend.m
//
//  Created by 苏沫离 on 2018/2/16.
//

//默认时间间隔
#define DefaultDoubleHitInterval 1

#import "UIButton+Extend.h"
#import <objc/runtime.h>

@implementation UIButton (Extend)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));//old
        Method swizzledMethod = class_getInstanceMethod(self, @selector(sure_SendAction:to:forEvent:));//new
        BOOL didAddMethod = class_addMethod(self,@selector(sendAction:to:forEvent:),
                                            method_getImplementation(swizzledMethod),
                                            method_getTypeEncoding(swizzledMethod));
        if (didAddMethod){
            class_replaceMethod(self,@selector(sure_SendAction:to:forEvent:),
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        }else{
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)sure_SendAction:(SEL)action to:(nullable id)target forEvent:(nullable UIEvent *)event
{
    if (self.hitType != DoubleHitTypeStart)
    {
        [self sure_SendAction:action to:target forEvent:event];
        return;
    }
    
    if ([NSStringFromClass(self.class) isEqualToString:@"UIButton"])
    {
        self.hitTimeInterval = self.hitTimeInterval == 0 ? DefaultDoubleHitInterval : self.hitTimeInterval;
        if ([self isIgnoreEvent])
        {
            return;
        }
        else if (self.hitTimeInterval > 0)
        {
            [self performSelector:@selector(resertState) withObject:nil afterDelay:self.hitTimeInterval];
        }
    }
    [self setIsIgnoreEvent:YES];
    [self sure_SendAction:action to:target forEvent:event];
}


- (void)resertState
{
    [self setIsIgnoreEvent:NO];
}

- (BOOL)isIgnoreEvent
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setIsIgnoreEvent:(BOOL)isIgnoreEvent
{
    objc_setAssociatedObject(self, @selector(isIgnoreEvent), @(isIgnoreEvent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setHitTimeInterval:(NSTimeInterval)hitTimeInterval
{
    objc_setAssociatedObject(self, @selector(hitTimeInterval), @(hitTimeInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)hitTimeInterval
{
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}

- (void)setHitType:(DoubleHitType)hitType
{
    objc_setAssociatedObject(self, @selector(hitType), @(hitType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (DoubleHitType)hitType
{
    return [objc_getAssociatedObject(self, _cmd) intValue];
}

@end
