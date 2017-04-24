//
//  QBAlphabetView.m
//  Demo
//
//  Created by Qiaokai on 2017/2/28.
//  Copyright © 2017年 Matías Martínez. All rights reserved.
//

#import "QBAlphabetView.h"
#import "UIButton+QBConvenient.h"
#import "QBKeyBoardButton.h"



@interface QBAlphabetView ()

@property (nonatomic, strong) NSArray *lettersArr;

@property (nonatomic, strong) NSArray *uppersArr;

/** 小写字母按钮 */
@property (nonatomic, strong) NSMutableArray *charBtnsArrM;

/** 其他按钮 */
@property (nonatomic, strong) NSMutableArray *tempArrM;

/** 其他按钮 切换大小写 */
@property (nonatomic, strong) UIButton *switchA;
/** 其他按钮 删除按钮 */
@property (nonatomic, strong) UIButton *deleteBtn;
/** 其他按钮 切换至数字键盘 */
@property (nonatomic, strong) UIButton *switchB;
/** 其他按钮 切换至符号按钮 */
@property (nonatomic, strong) UIButton *spaceBtn;
/** 其他按钮 登录 */
@property (nonatomic, strong) UIButton *loginBtn;

@property (nonatomic, assign) BOOL isUpper;
@end

@implementation QBAlphabetView

- (NSArray *)lettersArr {
    if (!_lettersArr) {
        _lettersArr = @[@"q",@"w",@"e",@"r",@"t",@"y",@"u",@"i",@"o",@"p",@"a",@"s",@"d",@"f",@"g",@"h",@"j",@"k",@"l",@"z",@"x",@"c",@"v",@"b",@"n",@"m"];
    }
    return _lettersArr;
}

- (NSArray *)uppersArr {
    if (!_uppersArr) {
        _uppersArr = @[@"Q",@"W",@"E",@"R",@"T",@"Y",@"U",@"I",@"O",@"P",@"A",@"S",@"D",@"F",@"G",@"H",@"J",@"K",@"L",@"Z",@"X",@"C",@"V",@"B",@"N",@"M"];
    }
    return _uppersArr;
}

- (NSMutableArray *)charBtnsArrM {
    if (!_charBtnsArrM) {
        _charBtnsArrM = [NSMutableArray array];
    }
    return _charBtnsArrM;
}

- (NSMutableArray *)tempArrM {
    if (!_tempArrM) {
        _tempArrM = [NSMutableArray array];
    }
    return _tempArrM;
}

- (void)setIsShowTopAlert:(BOOL)isShowTopAlert {
    if (_isShowTopAlert != isShowTopAlert) {
        _isShowTopAlert = isShowTopAlert;
        for (int i = 0; i < self.charBtnsArrM.count; i++) {
            QBAlertKeyBoardButton *charBtn = self.charBtnsArrM[i];
            charBtn.isShowTopAlert = isShowTopAlert;
        }
    }
}

- (void)setAllowsABC:(BOOL)allowsABC {
    if (_allowsABC != allowsABC) {
        _allowsABC = allowsABC;
        self.switchB.tag = ButtonTypeNum;
        [self.loginBtn setTitle:@"#+=" forState:UIControlStateNormal];
        [self.loginBtn setBackgroundImage:[self.class _keyboardImageNamed:@"c_chaKeyboardBgButton"] forState:UIControlStateNormal];
        [self.loginBtn setBackgroundImage:[self.class _keyboardImageNamed:@"c_chaKeyboardBgButton"] forState:UIControlStateHighlighted];
        [self.loginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.loginBtn.tag = ButtonTypeSymbol;
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = PWUIColorFromHex(0xf1f5f9);
        self.isUpper = YES;
        [self setupControls];
        
    }
    return self;
}

- (void)setupControls {
    
    // 添加26个字母按钮
    UIImage *image = [self.class _keyboardImageNamed:@"c_charKeyboardButton"];
    image = [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
    
    NSUInteger count = self.lettersArr.count;
    for (NSUInteger i = 0 ; i < count; i++) {
        
        QBAlertKeyBoardButton *charBtn = [QBAlertKeyBoardButton buttonWithType:UIButtonTypeCustom];
        charBtn.titleLabel.font = [UIFont systemFontOfSize:20];
        [charBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [charBtn setBackgroundImage:image forState:UIControlStateNormal];
        [charBtn setBackgroundImage:image forState:UIControlStateHighlighted];
        [charBtn addTarget:self action:@selector(charbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:charBtn];
        [self.charBtnsArrM addObject:charBtn];
    }
    
    // 添加其他按钮 切换大小写、删除回退、确定（登录）、 数字、符号
    self.switchA = [UIButton setupFunctionButtonWithTitle:nil image:[self.class _keyboardImageNamed:@"c_chaKeyboardShiftButton"] highImage:[self.class _keyboardImageNamed:@"c_chaKeyboardShiftButton"]];
    [self.switchA setBackgroundImage:[self.class _keyboardImageNamed:@"c_chaKeyboardShiftButtonSel"] forState:UIControlStateSelected];
    self.deleteBtn = [UIButton setupFunctionButtonWithTitle:nil image:[self.class _keyboardImageNamed:@"c_character_keyboardDeleteButton"] highImage:nil];
    self.loginBtn = [UIButton setupFunctionButtonWithTitle:@"完成" image:[self.class _keyboardImageNamed:@"login_c_character_keyboardLoginButton"] highImage:[self.class _keyboardImageNamed:@"login_c_character_keyboardLoginButton"]];
    [self.loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    self.switchB = [UIButton setupFunctionButtonWithTitle:@"123" image:[self.class _keyboardImageNamed:@"c_chaKeyboardBgButton"] highImage:[self.class _keyboardImageNamed:@"c_chaKeyboardBgButton"]];
    self.spaceBtn = [UIButton setupFunctionButtonWithTitle:@" " image:[self.class _keyboardImageNamed:@"c_character_keyboardSwitchButton"] highImage:[self.class _keyboardImageNamed:@"c_character_keyboardSwitchButton"]];
    
    [self.switchA addTarget:self action:@selector(changeCharacteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteBtn addTarget:self action:@selector(functionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginBtn addTarget:self action:@selector(functionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.switchB addTarget:self action:@selector(functionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.spaceBtn addTarget:self action:@selector(charbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.deleteBtn.tag = ButtonTypeDelete;
    self.loginBtn.tag = ButtonTypeDone;
    
    self.switchB.tag = ButtonTypeNumandSymbol;
    self.spaceBtn.tag = ButtonTypeSpace;
    
    [self addSubview:self.switchA];
    [self addSubview:self.deleteBtn];
    [self addSubview:self.loginBtn];
    [self addSubview:self.switchB];
    [self addSubview:self.spaceBtn];
    
    [self changeCharacteBtnClick:nil];
    
}

- (void)charbuttonClick:(UIButton *)charButton {
    
    if ([self.delegate respondsToSelector:@selector(alphabetKeyboard:didClickButton:)]) {
        [self.delegate alphabetKeyboard:self didClickButton:charButton];
    }
}


- (void)changeCharacteBtnClick:(UIButton *)switchA {
    switchA.selected = !switchA.isSelected;
    [self.tempArrM removeAllObjects];
    NSUInteger count = self.charBtnsArrM.count;
    
    if (self.isUpper) {
        self.tempArrM = [NSMutableArray arrayWithArray:self.lettersArr];
        self.isUpper = NO;
    } else {
        
        self.tempArrM = [NSMutableArray arrayWithArray:self.uppersArr];
        self.isUpper = YES;
    }
    for (int i = 0; i < count; i++) {
        UIButton *charBtn = (UIButton *)self.charBtnsArrM[i];
        NSString *upperTitle = self.tempArrM[i];
        [charBtn setTitle:upperTitle forState:UIControlStateNormal];
        [charBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

- (void)functionBtnClick:(UIButton *)switchBtn {
    if (switchBtn.tag == ButtonTypeNum) {
        if (self.isUpper) {
            [self changeCharacteBtnClick:self.switchA];
        }
    }
    if ([self.delegate respondsToSelector:@selector(alphabetKeyboardKeyboardDidClickButton:)]) {
        [self.delegate alphabetKeyboardKeyboardDidClickButton:switchBtn];
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    CGFloat topMargin = 5;
    CGFloat bottomMargin = 5;
    CGFloat leftMargin = 5;
    CGFloat colMargin = 5;
    CGFloat rowMargin = 10;
    
    if (PW_IS_IPHONE_5) {
        topMargin = 8;
        bottomMargin = 8;
        rowMargin = 15;
    }
    
    // 布局字母按钮
    CGFloat buttonW = (CGRectGetWidth(self.bounds) - 2 * leftMargin - 9 * colMargin) / 10;
    CGFloat buttonH = (CGRectGetHeight(self.bounds) - topMargin - bottomMargin - 3 * rowMargin) / 4;
    
    NSUInteger count = self.charBtnsArrM.count;
    for (NSUInteger i = 0; i < count; i++) {
        
        UIButton *button = (UIButton *)self.charBtnsArrM[i];
        CGRect buttonRect = button.frame;
        buttonRect.size.width = buttonW;
        buttonRect.size.height = buttonH;
        
        if (i < 10) { // 第一行
            buttonRect.origin.x = (colMargin + buttonW) * i + leftMargin;
            buttonRect.origin.y = topMargin;
        } else if (i < 19) { // 第二行
            buttonRect.origin.x = (colMargin + buttonW) * (i - 10) + leftMargin + buttonW / 2 + colMargin/2;
            buttonRect.origin.y = topMargin + rowMargin + buttonH;
        } else if (i < count) {
            buttonRect.origin.y = topMargin + 2 * rowMargin + 2 * buttonH;
            buttonRect.origin.x = (colMargin + buttonW) * (i - 19) + leftMargin + buttonW / 2 + colMargin + buttonW + colMargin/2;
        }
        button.frame = buttonRect;
    }
    
    // 布局其他功能按钮  切换大小写、删除回退、确定（登录）、 数字、符号
    CGFloat switchAW = buttonH;
    CGFloat switchAY = topMargin + 2 * rowMargin + 2 * buttonH;
    self.switchA.frame = CGRectMake(leftMargin, switchAY, switchAW, buttonH);
    
    CGFloat deleteBtnW = buttonH;
    self.deleteBtn.frame = CGRectMake(CGRectGetWidth(self.bounds) - leftMargin - deleteBtnW, switchAY, deleteBtnW, buttonH);
    
    CGFloat loginBtnW = 2 * buttonW + colMargin;
    CGFloat loginBtnY = CGRectGetHeight(self.bounds) - bottomMargin - buttonH;
    CGFloat loginBtnX = CGRectGetWidth(self.bounds) - leftMargin - loginBtnW;
    
    self.loginBtn.frame = CGRectMake(loginBtnX, loginBtnY, loginBtnW, buttonH);
    
    CGFloat switchBtnW = buttonH;
    
    self.switchB.frame = CGRectMake(leftMargin, loginBtnY, switchBtnW, buttonH);
    CGFloat spaceBtnOffsetx = (CGRectGetWidth(self.bounds) - buttonH * 2 - leftMargin * 2 - 7 * buttonW - 6*colMargin) / 2;
    CGFloat spaceBtnW = CGRectGetWidth(self.bounds) - (spaceBtnOffsetx * 2 + loginBtnW + leftMargin + leftMargin + switchBtnW);
    self.spaceBtn.frame = CGRectMake(spaceBtnOffsetx + leftMargin + switchBtnW, loginBtnY, spaceBtnW, buttonH);
}

+ (UIImage *)_keyboardImageNamed:(NSString *)name
{
    NSString *resource = [name stringByDeletingPathExtension];
    NSString *extension = [name pathExtension];
    extension = [extension isEqualToString:@""] ? @"png":extension;
    
    if (resource) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
//        NSURL *url = [bundle URLForResource:@"QBPwdModule" withExtension:@"bundle"];
//        bundle = [NSBundle bundleWithURL:url];
        if (bundle) {
            NSString *resourcePath = [bundle pathForResource:resource ofType:extension];
            
            return [UIImage imageNamed:resourcePath];
        } else {
            return [UIImage imageNamed:name];
        }
    }
    return nil;
}

@end
