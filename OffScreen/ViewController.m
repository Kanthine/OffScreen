//
//  ViewController.m
//  OffScreen
//
//  Created by 苏沫离 on 2020/12/8.
//

#import "ViewController.h"
#import "UIImageView+Extend.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 100, 100, 100)];
    UILabel *label = [[UILabel alloc] initWithFrame:view.bounds];
    label.text = @"在普通的 layer 绘制中，上层的 sublayer 会覆盖下层的 sublayer，下层 sublayer 绘制完之后就可以抛弃了，从而节约空间提高效率。所有 sublayer 依次绘制完毕之后，整个绘制过程完成，就可以进行后续的呈现了。假设我们需要绘制一个三层的 sublayer，不设置裁剪和圆角，那么整个绘制过程就如下图所示";
    label.layer.opacity = 0.5;
    label.numberOfLines = 0;
    [view addSubview:label];
    view.backgroundColor = UIColor.redColor;
    [self.view addSubview:view];
    
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 250, 100, 100)];
        imageView.image = [UIImage imageNamed:@"Image"];
        imageView.layer.cornerRadius = 30;
        imageView.clipsToBounds = YES;
        imageView.backgroundColor = UIColor.redColor;
        [self.view addSubview:imageView];
                
        UIImageView *imageView_1 = [[UIImageView alloc] initWithFrame:CGRectMake(180, 250, 100, 100)];
        imageView_1.image = [UIImage imageNamed:@"Image"];

        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:imageView_1.bounds   byRoundingCorners:UIRectCornerTopLeft cornerRadii:CGSizeMake(30, 30)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = imageView_1.bounds;
        maskLayer.path = maskPath.CGPath;
        imageView_1.layer.mask = maskLayer;
        [self.view addSubview:imageView_1];
    }
    
    UIImageView *imageView_2 = [[UIImageView alloc] initWithFrame:CGRectMake(20, 400, 100, 100)];
    imageView_2.image = [UIImage imageNamed:@"Image"];
    [imageView_2 clipsLayerWithCornerRadius:30];
    [self.view addSubview:imageView_2];
}



@end
