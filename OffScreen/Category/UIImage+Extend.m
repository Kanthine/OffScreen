//
//  UIImage+Extend.m
//
//  Created by 苏沫离 on 2018/2/16.
//

#import "UIImage+Extend.h"

@implementation UIImage (Compress)

- (NSData *)compressQualityWithMaxLength:(NSInteger)maxLength {
    UIImage *image = self;
    NSData *data = UIImageJPEGRepresentation(image, 1);
    while (data.length > maxLength) {
        float compressibility = maxLength / (data.length * 1.0);
        if (image.size.width > 0 && image.size.height > 0) {
            CGSize size = CGSizeMake(image.size.width * 0.9, image.size.height * 0.9);
            UIGraphicsBeginImageContext(size);
            [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            data = UIImageJPEGRepresentation(image, 1);
            compressibility = maxLength / (data.length * 1.0);
        }
        if (data.length > maxLength) {
            data = UIImageJPEGRepresentation(image, compressibility);
        }
    }
    return data;
}

@end



@implementation UIImage (Color)

- (UIImage *)imageChangeColor:(UIColor*)color{
    //获取画布
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    //画笔沾取颜色
    [color setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    //绘制一次
    [self drawInRect:bounds blendMode:kCGBlendModeOverlay alpha:1.0f];
    //再绘制一次
    [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    //获取图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color{
    CGRect rect = CGRectMake(0, 0, 1000, 1000);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
