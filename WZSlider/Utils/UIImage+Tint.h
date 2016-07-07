//
//  UIImage+Tint.h
//  WZSlider
//
//  Created by liwang.zhao on 16/7/6.
//  Copyright © 2016年 LandOfMystery. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Tint)

//可以为图像涂指定颜色，节约空间的利器
- (UIImage *)imageWithTintColor:(UIColor *)tintColor;

@end
