//
//  UIImage+Extend.h
//
//  Created by 苏沫离 on 2018/2/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 图片压缩
@interface UIImage (Compress)

///压缩图片至指定大小
///@note: 大小、尺寸均压缩
- (NSData *)compressQualityWithMaxLength:(NSInteger)maxLength;

@end

/** 颜色
 */
@interface UIImage (Color)

///改变图片的颜色
- (UIImage *)imageChangeColor:(UIColor *)color;

/// UIColor 转UIImage
+ (UIImage *)imageWithColor:(UIColor *)color;

@end


NS_ASSUME_NONNULL_END
