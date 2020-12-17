//
//  NSArray+CrashHandler.m
//
//  Created by 苏沫离 on 2018/2/16.
//

#import "NSArray+CrashHandler.h"
#import <objc/runtime.h>

@implementation NSArray (CrashHandler)

+ (void)load{
    
#ifdef DEBUG
     // debug 下数组越界，就去调试
    
#else
    // 只有在 release 模式下 才避免数组越界，debug 下数组越界，就去调试
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        //  替换不可变数组中的方法
        Method oldObjectAtIndex = class_getInstanceMethod(objc_getClass("__NSArrayI"), @selector(objectAtIndex:));
        Method oldObjectAtIndex1 = class_getInstanceMethod(objc_getClass("__NSArray0"), @selector(objectAtIndex:));
        Method oldObjectAtIndex2 = class_getInstanceMethod(objc_getClass("__NSPlaceHolderArray"), @selector(objectAtIndex:));
        Method oldObjectAtIndex3 = class_getInstanceMethod(objc_getClass("__NSSingleObjectArrayI"), @selector(objectAtIndex:));
        
        Method newObjectAtIndex = class_getInstanceMethod(objc_getClass("__NSArrayI"), @selector(cus__nickyTsui__objectAtIndex:));
        Method newObjectAtIndex1 = class_getInstanceMethod(objc_getClass("__NSArray0"), @selector(cus__nickyTsui__objectAtIndex:));
        Method newObjectAtIndex2 = class_getInstanceMethod(objc_getClass("__NSPlaceHolderArray"), @selector(cus__nickyTsui__objectAtIndex:));
        Method newObjectAtIndex3 = class_getInstanceMethod(objc_getClass("__NSSingleObjectArrayI"), @selector(cus__nickyTsui__objectAtIndex:));
        
        if (newObjectAtIndex) {
            method_exchangeImplementations(oldObjectAtIndex, newObjectAtIndex);
        } else if (newObjectAtIndex1) {
            method_exchangeImplementations(oldObjectAtIndex1, newObjectAtIndex1);
        } else if (newObjectAtIndex2) {
            method_exchangeImplementations(oldObjectAtIndex2, newObjectAtIndex2);
        } else if (newObjectAtIndex3) {
            method_exchangeImplementations(oldObjectAtIndex3, newObjectAtIndex3);
        }
        
        
        //  替换不可变数组中的方法
        Method oldObjectAtSubscriptIndex = class_getInstanceMethod(objc_getClass("__NSArrayI"), @selector(objectAtIndexedSubscript:));
        Method oldObjectAtSubscriptIndex1 = class_getInstanceMethod(objc_getClass("__NSArray0"), @selector(objectAtIndexedSubscript:));
        Method oldObjectAtSubscriptIndex2 = class_getInstanceMethod(objc_getClass("__NSPlaceHolderArray"), @selector(objectAtIndexedSubscript:));
        Method oldObjectAtSubscriptIndex3 = class_getInstanceMethod(objc_getClass("__NSSingleObjectArrayI"), @selector(objectAtIndexedSubscript:));
        
        Method newObjectAtSubscriptIndex = class_getInstanceMethod(objc_getClass("__NSArrayI"), @selector(cus__nickyTsui__objectAtIndexedSubscript:));
        Method newObjectAtSubscriptIndex1 = class_getInstanceMethod(objc_getClass("__NSArray0"), @selector(cus__nickyTsui__objectAtIndexedSubscript:));
        Method newObjectAtSubscriptIndex2 = class_getInstanceMethod(objc_getClass("__NSPlaceHolderArray"), @selector(cus__nickyTsui__objectAtIndexedSubscript:));
        Method newObjectAtSubscriptIndex3 = class_getInstanceMethod(objc_getClass("__NSSingleObjectArrayI"), @selector(cus__nickyTsui__objectAtIndexedSubscript:));
        
        if (newObjectAtSubscriptIndex) {
            method_exchangeImplementations(oldObjectAtSubscriptIndex, newObjectAtSubscriptIndex);
        } else if (newObjectAtSubscriptIndex1) {
            method_exchangeImplementations(oldObjectAtSubscriptIndex1, newObjectAtSubscriptIndex1);
        } else if (newObjectAtSubscriptIndex2) {
            method_exchangeImplementations(oldObjectAtSubscriptIndex2, newObjectAtSubscriptIndex2);
        } else if (newObjectAtSubscriptIndex3) {
            method_exchangeImplementations(oldObjectAtSubscriptIndex3, newObjectAtSubscriptIndex3);
        }
        
        
        //  替换可变数组中的方法
        Method oldMutableObjectAtIndex = class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(objectAtIndex:));
        Method newMutableObjectAtIndex =  class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(mutableObjectAtIndex:));
        method_exchangeImplementations(oldMutableObjectAtIndex, newMutableObjectAtIndex);
        
        
        //  替换可变数组中的方法
        Method oldMutableObjectAtSubscriptIndex = class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(objectAtIndexedSubscript:));
        Method newMutableObjectAtSubscriptIndex =  class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(mutablebjectAtIndexedSubscript:));
        method_exchangeImplementations(oldMutableObjectAtSubscriptIndex, newMutableObjectAtSubscriptIndex);
        
        
        //  替换可变数组中的方法
        Method oldMutableObjectAtReplaceIndex = class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(replaceObjectAtIndex:withObject:));
        Method newMutableObjectAtReplaceIndex =  class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(mutableReplaceObjectAtIndex:withObject:));
        method_exchangeImplementations(oldMutableObjectAtReplaceIndex, newMutableObjectAtReplaceIndex);
        
        
        //  替换可变数组中的方法
//        Method oldMutableObjectRemoveIndex = class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(removeObjectAtIndex:));
//        Method newMutableObjectRemove =  class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(yl_removeObjectAtIndex:));
//        method_exchangeImplementations(oldMutableObjectRemoveIndex, newMutableObjectRemove);
    });
    
#endif

}

- (id)cus__nickyTsui__objectAtIndex:(NSUInteger)index{
    if (index > self.count - 1 || !self.count){
        @try {
            return [self cus__nickyTsui__objectAtIndex:index];
        } @catch (NSException *exception) {
            //__throwOutException  抛出异常
            NSLog(@"不可变数组越界--------------objectAtIndex");
            return nil;
        } @finally {
            
        }
    }else{
        return [self cus__nickyTsui__objectAtIndex:index];
    }
}

- (id)mutableObjectAtIndex:(NSUInteger)index{
    if (index > self.count - 1 || !self.count){
        @try {
            return [self mutableObjectAtIndex:index];
        } @catch (NSException *exception) {
            //__throwOutException  抛出异常
            NSLog(@"可变数组越界--------------objectAtIndex");
            return nil;
        } @finally {
            
        }
    }else{
        return [self mutableObjectAtIndex:index];
    }
}

- (id)cus__nickyTsui__objectAtIndexedSubscript:(NSUInteger)index{
    if (index > self.count - 1 || !self.count){
        @try {
            return [self cus__nickyTsui__objectAtIndexedSubscript:index];
        } @catch (NSException *exception) {
            
            //__throwOutException  抛出异常
            NSLog(@"不可变数组越界--------------字面量");
            return nil;
        } @finally {
            
        }
    }
    else{
        return [self cus__nickyTsui__objectAtIndexedSubscript:index];
    }
}

- (id)mutablebjectAtIndexedSubscript:(NSUInteger)index{
    if (index > self.count - 1 || !self.count){
        @try {
            return [self mutablebjectAtIndexedSubscript:index];
        } @catch (NSException *exception) {
            //__throwOutException  抛出异常
            NSLog(@"可变数组越界--------------字面量");
            return nil;
        } @finally {
            
        }
    }
    else{
        return [self mutablebjectAtIndexedSubscript:index];
    }
}

- (void)mutableReplaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    if (index > self.count - 1 || !self.count)
    {
        @try
        {
            [self mutableReplaceObjectAtIndex:index withObject:anObject];
        }
        @catch (NSException *exception)
        {
            //__throwOutException  抛出异常
            NSLog(@"可变数组越界--------------字面量");
        }
        @finally
        {
            
        }
    }
    else
    {
        [self mutableReplaceObjectAtIndex:index withObject:anObject];
    }
}


@end
