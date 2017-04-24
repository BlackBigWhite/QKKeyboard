//
//  UIButton+QBConvenient.m
//  Demo
//
//  Created by Qiaokai on 2017/2/28.
//  Copyright © 2017年 Matías Martínez. All rights reserved.
//

#import "UIButton+QBConvenient.h"

@implementation UIButton (QBConvenient)

#pragma mark - 添加基础按钮
+ (UIButton *)setupBasicButtonsWithTitle:(NSString *)title image:(UIImage *)image highImage:(UIImage *)highImage {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:highImage forState:UIControlStateHighlighted];
    
    return button;
}

#pragma mark - 添加功能按钮
+ (UIButton *)setupFunctionButtonWithTitle:(NSString *)title image:(UIImage *)image highImage:(UIImage *)highImage {
    
    UIButton *otherBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    otherBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [otherBtn setTitle:title forState:UIControlStateNormal];
    [otherBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [otherBtn setBackgroundImage:image forState:UIControlStateNormal];
    [otherBtn setBackgroundImage:highImage forState:UIControlStateHighlighted];
    otherBtn.adjustsImageWhenHighlighted = NO;
    return otherBtn;
}

@end
