//
//  QBAlphabetView.h
//  Demo
//
//  Created by Qiaokai on 2017/2/28.
//  Copyright © 2017年 Matías Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBKeyboard.h"
@class QBAlphabetView;


@protocol QBAlphabetViewKeyboardDelegate <NSObject>

@optional

- (void)alphabetKeyboard:(QBAlphabetView *)letter didClickButton:(UIButton *)button;

- (void)alphabetKeyboardKeyboardDidClickButton:(UIButton *)button;

@end

@interface QBAlphabetView : UIView

@property (nonatomic, assign) BOOL isShowTopAlert;

@property (nonatomic, assign) BOOL allowsABC;

@property (nonatomic, weak) id<QBAlphabetViewKeyboardDelegate> delegate;


@end
