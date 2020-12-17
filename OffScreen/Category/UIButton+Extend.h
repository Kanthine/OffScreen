//
//  UIButton+Extend.h
//
//  Created by 苏沫离 on 2018/2/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger,DoubleHitType) {
    DoubleHitTypeDefault = 0,
    DoubleHitTypeStart = 5,
};

@interface UIButton (DoubleHit)

/*
 * 设置点击时间间隔
 */
@property (nonatomic, assign) NSTimeInterval hitTimeInterval;

/*
 * 防连击处理时
 */
@property (nonatomic, assign) DoubleHitType hitType;

@end

NS_ASSUME_NONNULL_END
