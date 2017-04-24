//
//  UIButton+QBConvenient.h
//  Demo
//
//  Created by Qiaokai on 2017/2/28.
//  Copyright © 2017年 Matías Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (QBConvenient)

+ (UIButton *)setupBasicButtonsWithTitle:(NSString *)title image:(UIImage *)image highImage:(UIImage *)highImage;

+ (UIButton *)setupFunctionButtonWithTitle:(NSString *)title image:(UIImage *)image highImage:(UIImage *)highImage;

@end
