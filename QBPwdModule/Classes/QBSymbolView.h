//
//  QBSymbolView.h
//  Demo
//
//  Created by Qiaokai on 2017/2/28.
//  Copyright © 2017年 Matías Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBKeyboard.h"
@class QBSymbolView;

@protocol QBSymbolViewKeyboardDelegate <NSObject>

@optional

- (void)symbolKeyboard:(QBSymbolView *)symbol didClickButton:(UIButton *)button;

- (void)symbolKeyboardKeyboardDidClickButton:(UIButton *)button;

@end

@interface QBSymbolView : UIView

@property (nonatomic, assign) id<QBSymbolViewKeyboardDelegate> delegate;

@property (nonatomic, assign) BOOL isShowTopAlert;

@property (nonatomic, assign) BOOL allowsABC;

@end
