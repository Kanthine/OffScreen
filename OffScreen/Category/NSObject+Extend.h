//
//  NSObject+Extend.h
//
//  Created by 苏沫离 on 2018/2/16.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** 方法交换
 */
@interface NSObject (Swizzling)

+ (void)methodSwizzlingWithOriginalSelector:(SEL)originalSelector bySwizzledSelector:(SEL)swizzledSelector;

@end


/** 判断两个模型是否完全一样
 */
@interface NSObject (IsEqual)

- (BOOL)isEqualToObject:(id)object;

@end


@interface NSObject (GetTheController)

/** 获取当前的 ViewController
 */
+ (UIViewController *_Nullable)getCurrentViewController;

@end


NS_ASSUME_NONNULL_END
