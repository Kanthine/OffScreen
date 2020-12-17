//
//  UIImageView+Extend.m
//
//  Created by 苏沫离 on 2018/2/16.
//

#import "UIImageView+Extend.h"

@implementation UIImageView (CornerRadius)

- (void)clipsLayerWithCornerRadius:(CGFloat)cornerRadius{
    [self clipsLayerWithCornerRadius:cornerRadius byRoundingCorners:UIRectCornerAllCorners];
}

- (void)clipsLayerWithCornerRadius:(CGFloat)cornerRadius byRoundingCorners:(UIRectCorner)corners{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, UIScreen.mainScreen.scale);
    [[UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(cornerRadius, cornerRadius)] addClip];
    [self drawRect:self.bounds];
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

@end
