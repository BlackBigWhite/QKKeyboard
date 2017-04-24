//
//  QBSymbolView.m
//  Demo
//
//  Created by Qiaokai on 2017/2/28.
//  Copyright © 2017年 Matías Martínez. All rights reserved.
//

#import "QBSymbolView.h"
#import "UIButton+QBConvenient.h"
#import "QBKeyBoardButton.h"

@interface QBSymbolView ()

@property (nonatomic, strong) NSArray *symbolandNumArr;

@property (nonatomic, strong) NSArray *symbolArr;

@property (nonatomic, strong) NSMutableArray *symbolBtnArrM;

/** 其他按钮 删除按钮 */
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

@implementation QBSymbolView

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

// 添加子控件
- (void)setupControls {
    
    UIImage *image = [self.class _keyboardImageNamed:@"c_charKeyboardButton"];
    
    // 字母按钮
    for (NSUInteger i = 0; i < self.symbolandNumArr.count; i++) {
        NSString *text = self.symbolandNumArr[i];
        QBAlertKeyBoardButton *symbolBtn = [QBAlertKeyBoardButton buttonWithType:UIButtonTypeCustom];
        symbolBtn.titleLabel.font = [UIFont systemFontOfSize:20];
        [symbolBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [symbolBtn setTitle:text forState:UIControlStateNormal];
        [symbolBtn setBackgroundImage:image forState:UIControlStateNormal];
        [symbolBtn setBackgroundImage:image forState:UIControlStateHighlighted];
        [self addSubview:symbolBtn];
        [symbolBtn addTarget:self action:@selector(symbolBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.symbolBtnArrM addObject:symbolBtn];
    }
    
    // 添加其他按钮 切换大小写、删除回退、确定（登录）、 数字、符号
    self.switchA = [UIButton setupFunctionButtonWithTitle:nil image:[self.class _keyboardImageNamed:@"c_chaKeyboardShiftButton"] highImage:[self.class _keyboardImageNamed:@"c_chaKeyboardShiftButtonSel"]];
    self.deleteBtn = [UIButton setupFunctionButtonWithTitle:nil image:[self.class _keyboardImageNamed:@"c_character_keyboardDeleteButton"] highImage:[self.class _keyboardImageNamed:@"c_character_keyboardDeleteButtonSel"]];
    self.loginBtn = [UIButton setupFunctionButtonWithTitle:@"完成" image:[self.class _keyboardImageNamed:@"login_c_character_keyboardLoginButton"] highImage:[self.class _keyboardImageNamed:@"login_c_character_keyboardLoginButton"]];
    [self.loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.switchB = [UIButton setupFunctionButtonWithTitle:@"ABC" image:[self.class _keyboardImageNamed:@"c_chaKeyboardBgButton"] highImage:[self.class _keyboardImageNamed:@"c_chaKeyboardBgButton"]];
    self.spaceBtn = [UIButton setupFunctionButtonWithTitle:@" " image:[self.class _keyboardImageNamed:@"c_character_keyboardSwitchButton"] highImage:[self.class _keyboardImageNamed:@"c_character_keyboardSwitchButton"]];
    
    [self.switchA addTarget:self action:@selector(changeCharacteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteBtn addTarget:self action:@selector(functionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginBtn addTarget:self action:@selector(functionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.switchB addTarget:self action:@selector(functionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.spaceBtn addTarget:self action:@selector(symbolBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.deleteBtn.tag = ButtonTypeDelete;
    self.loginBtn.tag = ButtonTypeDone;
    
    self.switchB.tag = ButtonTypeAlphabet;
    self.spaceBtn.tag = ButtonTypeSpace;
    
    [self addSubview:self.switchA];
    [self addSubview:self.deleteBtn];
    [self addSubview:self.loginBtn];
    [self addSubview:self.switchB];
    [self addSubview:self.spaceBtn];
}

// 符号按钮
- (void)symbolBtnClick:(UIButton *)symbolBtn {
    if ([self.delegate respondsToSelector:@selector(symbolKeyboard:didClickButton:)]) {
        [self.delegate symbolKeyboard:self didClickButton:symbolBtn];
    }
}

- (void)functionBtnClick:(UIButton *)switchBtn {
    if (switchBtn.tag == ButtonTypeAlphabet) {
        if (!self.isUpper) {
            [self changeCharacteBtnClick:nil];
        }
    }

    if ([self.delegate respondsToSelector:@selector(symbolKeyboardKeyboardDidClickButton:)]) {
        [self.delegate symbolKeyboardKeyboardDidClickButton:switchBtn];
    }
}

- (void)changeCharacteBtnClick:(UIButton *)switchA {
    
    NSMutableArray *temp = [NSMutableArray array];
    NSUInteger count = self.symbolBtnArrM.count;
    
    if (self.isUpper) {
        temp = [NSMutableArray arrayWithArray:self.symbolArr];
        self.isUpper = NO;
    } else {
        
        temp = [NSMutableArray arrayWithArray:self.symbolandNumArr];
        self.isUpper = YES;
    }
    for (int i = 0; i < count; i++) {
        UIButton *charBtn = (UIButton *)self.symbolBtnArrM[i];
        NSString *upperTitle = temp[i];
        [charBtn setTitle:upperTitle forState:UIControlStateNormal];
        [charBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
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
    
    // 布局字符按钮
    CGFloat buttonW = (CGRectGetWidth(self.bounds) - 2 * leftMargin - 9 * colMargin) / 10;
    CGFloat buttonH = (CGRectGetHeight(self.bounds) - topMargin - bottomMargin - 3 * rowMargin) / 4;
    
    NSUInteger count = self.symbolBtnArrM.count;
    for (NSUInteger i = 0; i < count; i++) {
        
        UIButton *button = (UIButton *)self.symbolBtnArrM[i];
        CGRect buttonRect = button.frame;
        buttonRect.size.width = buttonW;
        buttonRect.size.height = buttonH;
        
        if (i < 10) { // 第一行
            buttonRect.origin.x = (colMargin + buttonW) * i + leftMargin;
            buttonRect.origin.y = topMargin;
        } else if (i < 20) { // 第二行
            buttonRect.origin.x = (colMargin + buttonW) * (i - 10) + leftMargin;
            buttonRect.origin.y = topMargin + rowMargin + buttonH;
        } else if (i < count) {
            buttonRect.size.width = buttonH;
            buttonRect.origin.y = topMargin + 2 * rowMargin + 2 * buttonH;
            CGFloat offsetx = (CGRectGetWidth(self.bounds) - buttonH * 2 - leftMargin * 2 - 5 * buttonH) / 6;
            buttonRect.origin.x = (offsetx + buttonH) * (i - 20) + leftMargin + offsetx + buttonH;
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
    CGFloat spaceBtnOffsetx = (CGRectGetWidth(self.bounds) - buttonH * 2 - leftMargin * 2 - 5 * buttonH) / 6;;
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
            
            return [UIImage imageWithContentsOfFile:resourcePath];
        } else {
            return [UIImage imageNamed:name];
        }
    }
    return nil;
}

- (NSArray *)symbolandNumArr {
    if (!_symbolandNumArr) {
        _symbolandNumArr = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",@"-",@"/",@":",@";",@"(",@")",@"$",@"&",@"@",@"\"",@".",@",",@"?",@"!",@"'"];
    }
    return _symbolandNumArr;
}

- (NSArray *)symbolArr {
    if (!_symbolArr) {
        _symbolArr = @[@"[",@"]",@"{",@"}",@"#",@"%",@"^",@"*",@"+",@"=",@"_",@"\\",@"|",@"~",@"<",@">",@"€",@"£",@"¥",@"•",@".",@",",@"?",@"!",@"'"];
    }
    return _symbolArr;
}


- (NSMutableArray *)symbolBtnArrM {
    if (!_symbolBtnArrM) {
        _symbolBtnArrM = [NSMutableArray array];
    }
    return _symbolBtnArrM;
}

- (void)setIsShowTopAlert:(BOOL)isShowTopAlert {
    if (_isShowTopAlert != isShowTopAlert) {
        _isShowTopAlert = isShowTopAlert;
        for (int i = 0; i < self.symbolBtnArrM.count; i++) {
            QBAlertKeyBoardButton *charBtn = self.symbolBtnArrM[i];
            charBtn.isShowTopAlert = isShowTopAlert;
        }
    }
}

- (void)setAllowsABC:(BOOL)allowsABC {
    if (_allowsABC != allowsABC) {
        _allowsABC = allowsABC;
//        self.switchB.tag = ButtonTypeNum;
        [self.loginBtn setTitle:@"123" forState:UIControlStateNormal];
        [self.loginBtn setBackgroundImage:[self.class _keyboardImageNamed:@"c_chaKeyboardBgButton"] forState:UIControlStateNormal];
        [self.loginBtn setBackgroundImage:[self.class _keyboardImageNamed:@"c_chaKeyboardBgButton"] forState:UIControlStateHighlighted];
        [self.loginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.loginBtn.tag = ButtonTypeNum;
        
        self.isUpper = YES;
        [self changeCharacteBtnClick:nil];
        
        UIImage *image = [self.class _keyboardImageNamed:@"c_charKeyboardButton"];
        self.switchA.titleLabel.font = [UIFont systemFontOfSize:20];
        [self.switchA setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.switchA setTitle:@"@" forState:UIControlStateNormal];
        [self.switchA setBackgroundImage:image forState:UIControlStateNormal];
        [self.switchA setBackgroundImage:image forState:UIControlStateHighlighted];
        [self.switchA removeTarget:self action:@selector(changeCharacteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.switchA addTarget:self action:@selector(symbolBtnClick:) forControlEvents:UIControlEventTouchUpInside];

    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
