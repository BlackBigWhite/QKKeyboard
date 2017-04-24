//
//  QBKeyboard.h
//  Demo
//
//  Created by Qiaokai on 2017/3/1.
//  Copyright © 2017年 Matías Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBKeyboardInputAccessoryView.h"
@class QBKeyboard;

#define PW_IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define PWUIColorFromHex(HexValue) [UIColor colorWithRed:((float)((HexValue & 0xFF0000) >> 16))/255.0 green:((float)((HexValue & 0xFF00) >> 8))/255.0 blue:((float)(HexValue & 0xFF))/255.0 alpha:1.0]


/**
 键盘切换按钮类型

 - ButtonTypeDelete: 删除
 - ButtonTypeDone: 完成
 - ButtonTypeNum: 数字
 - ButtonTypeSymbol: 字符
 - ButtonTypeAlphabet: 字母
 */
typedef NS_ENUM(NSUInteger, ButtonType) {
    ButtonTypeDelete,
    ButtonTypeDone,
    ButtonTypeNum,
    ButtonTypeNumandSymbol,
    ButtonTypeSymbol,
    ButtonTypeAlphabet,
    ButtonTypeSpace,
};


/**
 键盘类型

 - QBKeyboardTypeNum: 数字
 - QBKeyboardTypeAlphabet: 字母
 - QBKeyboardTypeSymbol: 字符
 */
typedef NS_ENUM(NSUInteger, QBKeyboardType) {
    QBKeyboardTypeNum,
    QBKeyboardTypeNumandDecimalPoint,
    QBKeyboardTypeNumandX,
    QBKeyboardTypeNumandABC,
    QBKeyboardTypeAlphabet,
    QBKeyboardTypeSymbol,
    QBKeyboardTypeSymbolandNum,
    QBKeyboardTypeAlphabetandandNumABC,
};


@protocol QBKeyboardDelegate <NSObject>
@optional

- (BOOL)keyboard:(QBKeyboard *)keyboard shouldInsertText:(NSString *)text;


/**
 输入完成 回收键盘

 @param keyboard
 @return           默认YES YES：回收键盘 NO：不回收
 */
- (BOOL)keyboardShouldReturn:(QBKeyboard *)keyboard;


/**
 删除输入

 @param keyboard
 @return YES：删除   NO：不删除
 */
- (BOOL)keyboardShouldDeleteBackward:(QBKeyboard *)keyboard;

@end


/**
 数字键盘按钮类型

 - such:
 - such:
 - for:
 - a:
 */
typedef NS_ENUM(NSUInteger, QBNumberKeyboardButtonStyle) {
    
    QBNumberKeyboardButtonStyleWhite,
    
    QBNumberKeyboardButtonStyleGray,
    
    QBNumberKeyboardButtonStyleDone
};

@interface QBKeyboard : UIInputView

- (instancetype)initWithFrame:(CGRect)frame inputViewStyle:(UIInputViewStyle)inputViewStyle locale:(NSLocale *)locale;

/**
 输入代理
 */
@property (weak, nonatomic) id <UIKeyInput> keyInput;

/**
 输出代理
 */
@property (weak, nonatomic) id <QBKeyboardDelegate> delegate;


/**
 键盘类型
 */
@property (assign, nonatomic) QBKeyboardType keyboardType;


/**
 数字键盘顺序
 */
@property (strong, nonatomic) NSArray<NSString *> *numbers;


/**
 完成按钮title
 */
@property (copy, nonatomic) NSString *returnKeyTitle;

/**
 显示／隐藏 按钮alert，默认不显示， ps：必须是字母，字符键盘才能显示alert
 */
@property (nonatomic, assign) BOOL allowsTopAlert;

@end
