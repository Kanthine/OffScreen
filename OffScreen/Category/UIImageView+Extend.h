//
//  UIImageView+Extend.h
//
//  Created by 苏沫离 on 2018/2/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** 设置圆角
 */
@interface UIImageView (CornerRadius)

/** 切圆角
 * @note 在设置完 image 之后裁切
 */
- (void)clipsLayerWithCornerRadius:(CGFloat)cornerRadius;
- (void)clipsLayerWithCornerRadius:(CGFloat)cornerRadius byRoundingCorners:(UIRectCorner)corners;

@end

NS_ASSUME_NONNULL_END
