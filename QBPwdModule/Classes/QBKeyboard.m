//
//  QBKeyboard.m
//  Demo
//
//  Created by Qiaokai on 2017/3/1.
//  Copyright © 2017年 Matías Martínez. All rights reserved.
//

#import "QBKeyboard.h"
#import "QBAlphabetView.h"
#import "QBSymbolView.h"
#import "QBKeyBoardButton.h"


/**
 数字键盘按钮类型

 - QBNumberKeyboardButtonNumberMin: 默认数字最小单位
 - QBNumberKeyboardButtonNumberMax: 默认数字最大单位
 - QBNumberKeyboardButtonDone: 完成
 - QBNumberKeyboardButtonDecimalPoint: 小数点
 - QBNumberKeyboardButtonNone: NSNotFound
 */
typedef NS_ENUM(NSUInteger, QBNumberKeyboardButton) {
    QBNumberKeyboardButtonNumberMin,
    QBNumberKeyboardButtonNumberMax = QBNumberKeyboardButtonNumberMin + 10, // Ten digits.
    QBNumberKeyboardButtonBackspace,
    QBNumberKeyboardButtonDone,
    QBNumberKeyboardButtonDecimalPoint,
    QBNumberKeyboardButtonNone = NSNotFound,
};

@interface QBKeyboard ()<UIInputViewAudioFeedback, QBAlphabetViewKeyboardDelegate, QBSymbolViewKeyboardDelegate>

@property (strong, nonatomic) QBAlphabetView *alphabetView;
@property (strong, nonatomic) QBSymbolView *symbolView;

@property (strong, nonatomic) NSDictionary *buttonDictionary;   ///< 按钮集合
@property (strong, nonatomic) NSMutableArray *separatorViews;   ///< 数字键盘分割线集合
@property (strong, nonatomic) NSLocale *locale;

/**
 显示／隐藏 X，默认不显示
 */
@property (nonatomic, assign) BOOL allowsX;
@property (nonatomic, assign) BOOL allowsABC;


@end

static __weak id currentFirstResponder;

@implementation UIResponder (FirstResponder)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
+ (id)QB_currentFirstResponder {
    currentFirstResponder = nil;
    [[UIApplication sharedApplication] sendAction:@selector(QB_findFirstResponder:) to:nil from:nil forEvent:nil];
    return currentFirstResponder;
}
#pragma clang diagnostic pop

- (void)QB_findFirstResponder:(id)sender {
    currentFirstResponder = self;
}

@end


@implementation QBKeyboard

static const NSInteger QBNumberKeyboardRows = 4;
static const CGFloat QBNumberKeyboardRowHeight = 55.0f;
static const CGFloat QBNumberKeyboardPadBorder = 7.0f;
static const CGFloat QBNumberKeyboardPadSpacing = 8.0f;


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame inputViewStyle:UIInputViewStyleKeyboard];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame inputViewStyle:(UIInputViewStyle)inputViewStyle
{
    self = [super initWithFrame:frame inputViewStyle:inputViewStyle];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame inputViewStyle:(UIInputViewStyle)inputViewStyle locale:(NSLocale *)locale
{
    self = [super initWithFrame:frame inputViewStyle:inputViewStyle];
    if (self) {
        self.locale = locale;
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit
{
    NSMutableDictionary *buttonDictionary = [NSMutableDictionary dictionary];
    
    const NSInteger numberMin = QBNumberKeyboardButtonNumberMin;
    const NSInteger numberMax = QBNumberKeyboardButtonNumberMax;
    
    UIFont *buttonFont;
    if ([UIFont respondsToSelector:@selector(systemFontOfSize:weight:)]) {
        buttonFont = [UIFont systemFontOfSize:28.0f weight:UIFontWeightLight];
    } else {
        buttonFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:28.0f];
    }
    
    UIFont *doneButtonFont = [UIFont systemFontOfSize:17.0f];
    
    for (QBNumberKeyboardButton key = numberMin; key < numberMax; key++) {
        UIButton *button = [QBKeyBoardButton keyboardButtonWithStyle:QBNumberKeyboardButtonStyleWhite];
        NSString *title = @(key - numberMin).stringValue;
        if (self.numbers && self.numbers.count >= (key - numberMin)) {
            title = self.numbers[(key - numberMin)];
        }
        
        [button setTitle:title forState:UIControlStateNormal];
        [button.titleLabel setFont:buttonFont];
        
        [buttonDictionary setObject:button forKey:@(key)];
    }
    
    UIImage *backspaceImage = [self.class _keyboardImageNamed:@"MMNumberKeyboardDeleteKey.png"];
    
    UIButton *backspaceButton = [QBKeyBoardButton keyboardButtonWithStyle:QBNumberKeyboardButtonStyleGray];
    [backspaceButton setImage:[backspaceImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    
    [(QBKeyBoardButton *)backspaceButton addTarget:self action:@selector(_backspaceRepeat:) forContinuousPressWithTimeInterval:0.15f];
    
    [buttonDictionary setObject:backspaceButton forKey:@(QBNumberKeyboardButtonBackspace)];
    
    UIButton *doneButton = [QBKeyBoardButton keyboardButtonWithStyle:QBNumberKeyboardButtonStyleDone];
    [doneButton.titleLabel setFont:doneButtonFont];
    NSString *done = @"Done";
    NSString *currentLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([currentLanguage containsString:@"zh-Hans"] || [currentLanguage isEqualToString:@"zh-Hant"]) {
        done = @"完成";
    }
    [doneButton setTitle:done forState:UIControlStateNormal];
    
    [buttonDictionary setObject:doneButton forKey:@(QBNumberKeyboardButtonDone)];
    
    UIButton *decimalPointButton = [QBKeyBoardButton keyboardButtonWithStyle:QBNumberKeyboardButtonStyleWhite];
    
    NSLocale *locale = self.locale ?: [NSLocale currentLocale];
    NSString *decimalSeparator = [locale objectForKey:NSLocaleDecimalSeparator];
    [decimalPointButton setTitle:decimalSeparator ?: @"." forState:UIControlStateNormal];
    
    [buttonDictionary setObject:decimalPointButton forKey:@(QBNumberKeyboardButtonDecimalPoint)];
    
    for (UIButton *button in buttonDictionary.objectEnumerator) {
        [button setExclusiveTouch:YES];
        [button addTarget:self action:@selector(_buttonInput:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(_buttonPlayClick:) forControlEvents:UIControlEventTouchDown];
        
        [self addSubview:button];
    }
    
    // Initialize an array for the separators.
    self.separatorViews = [NSMutableArray array];
    
    // Layout separators if phone. 分割线初始化
    const UIUserInterfaceIdiom interfaceIdiom = UI_USER_INTERFACE_IDIOM();
    if (interfaceIdiom != UIUserInterfaceIdiomPad) {
        NSMutableArray *separatorViews = self.separatorViews;
        
        const NSUInteger totalColumns = 4;
        const NSInteger numbersPerLine = 3;
        const NSUInteger totalRows = numbersPerLine + 1;
        const NSUInteger numberOfSeparators = totalColumns + totalRows - 1;
        
        NSUInteger separatorsToInsert = numberOfSeparators;
        while (separatorsToInsert--) {
            UIView *separator = [[UIView alloc] initWithFrame:CGRectZero];
            separator.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.1f];
            [self addSubview:separator];
            [separatorViews addObject:separator];
        }
    }
    
    //字母键盘
    _alphabetView.hidden = YES;
    [self addSubview:self.alphabetView];
    //符号键盘
    _symbolView.hidden = YES;
    [self addSubview:self.symbolView];
    
    self.buttonDictionary = buttonDictionary;
    
    // Add default return key title.
    [self setReturnKeyTitle:[self defaultReturnKeyTitle]];
    
    // Size to fit.
    [self sizeToFit];
    
    self.keyboardType = QBKeyboardTypeNum;
}

#pragma mark - Input.
/**
 播放点击声音
 
 @param button
 */
- (void)_buttonPlayClick:(UIButton *)button {
    [[UIDevice currentDevice] playInputClick];
}

- (void)_buttonInput:(UIButton *)button {
    __block QBNumberKeyboardButton keyboardButton = QBNumberKeyboardButtonNone;
    
    //判断是否特殊按钮
    [self.buttonDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        QBNumberKeyboardButton k = [key unsignedIntegerValue];
        if (button == obj) {
            keyboardButton = k;
            *stop = YES;
        }
    }];
    //不是特殊按钮，则不特殊处理
    if (keyboardButton == QBNumberKeyboardButtonNone) {
        return;
    }
    // Get first responder.
    id <UIKeyInput> keyInput = self.keyInput;
    id <QBKeyboardDelegate> delegate = self.delegate;
    if (!keyInput) {
        return;
    }
    // Handle number. 输入数字
    const NSInteger numberMin = QBNumberKeyboardButtonNumberMin;
    const NSInteger numberMax = QBNumberKeyboardButtonNumberMax;
    if (keyboardButton >= numberMin && keyboardButton < numberMax) {
        NSString *string = [button titleForState:UIControlStateNormal];
        if ([delegate respondsToSelector:@selector(keyboard:shouldInsertText:)]) {
            BOOL shouldInsert = [delegate keyboard:self shouldInsertText:string];
            if (!shouldInsert) {
                return;
            }
        }
        [keyInput insertText:string];
    }
    // Handle backspace. 输入删除
    else if (keyboardButton == QBNumberKeyboardButtonBackspace) {
        BOOL shouldDeleteBackward = YES;
        if ([delegate respondsToSelector:@selector(keyboardShouldDeleteBackward:)]) {
            shouldDeleteBackward = [delegate keyboardShouldDeleteBackward:self];
        }
        if (shouldDeleteBackward) {
            [keyInput deleteBackward];
        }
    }
    // Handle done. 输入完成
    else if (keyboardButton == QBNumberKeyboardButtonDone) {
        BOOL shouldReturn = YES;
        if ([delegate respondsToSelector:@selector(keyboardShouldReturn:)]) {
            shouldReturn = [delegate keyboardShouldReturn:self];
        }
        if (shouldReturn) {
            [self _dismissKeyboard:button];
        }
    }
    // Handle . 输入小数点
    else if (keyboardButton == QBNumberKeyboardButtonDecimalPoint) {
        NSString *decimalText = [button titleForState:UIControlStateNormal];
        if ([delegate respondsToSelector:@selector(keyboard:shouldInsertText:)]) {
            BOOL shouldInsert = [delegate keyboard:self shouldInsertText:decimalText];
            if (!shouldInsert) {
                return;
            }
        }
        [keyInput insertText:decimalText];
    }
}


/**
 x button 输入
 */
- (void)XbuttonInput:(UIButton *)button {
    NSString *string = [button titleForState:UIControlStateNormal];
    id <UIKeyInput> keyInput = self.keyInput;
    id <QBKeyboardDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(keyboard:shouldInsertText:)]) {
        BOOL shouldInsert = [delegate keyboard:self shouldInsertText:string];
        if (!shouldInsert) {
            return;
        }
    }
    [keyInput insertText:string];
}

/**
 ABC button 输入
 */
- (void)ABCbuttonInput:(UIButton *)button {
    [self cutKeyboardWithType:QBKeyboardTypeAlphabet];
}

/**
 点击删除按钮，持续删除
 
 @param button
 */
- (void)_backspaceRepeat:(UIButton *)button {
    id <UIKeyInput> keyInput = self.keyInput;
    if (![keyInput hasText]) {
        return;
    }
    [self _buttonPlayClick:button];
    [self _buttonInput:button];
}

/**
 获得keyInput
 */
- (id<UIKeyInput>)keyInput {
    id <UIKeyInput> keyInput = _keyInput;
    if (keyInput) {
        return keyInput;
    }
    keyInput = [UIResponder QB_currentFirstResponder];
    if (![keyInput conformsToProtocol:@protocol(UITextInput)]) {
        NSLog(@"Warning: First responder %@ does not conform to the UIKeyInput protocol.", keyInput);
        return nil;
    }
    _keyInput = keyInput;
    return keyInput;
}

#pragma mark - Default special action. 回收键盘
- (void)_dismissKeyboard:(id)sender {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        id <UIKeyInput> keyInput = strongSelf.keyInput;
        
        if ([keyInput isKindOfClass:[UIResponder class]]) {
            [(UIResponder *)keyInput resignFirstResponder];
        }
    }];
}

- (void)cutKeyboardWithType:(QBKeyboardType)type {
    switch (type) {
        case QBKeyboardTypeAlphabet: {
            [self dismissSymbolView];
            [self showAlphabetView];
            break;
        }
        case QBKeyboardTypeSymbolandNum: {
            [self dismissAlphabetView];
            [self showSymbolView];
            break;
        }
        case QBKeyboardTypeNumandX: {
            [self dismissSymbolView];
            [self dismissAlphabetView];
            self.allowsX = YES;
            
            break;
        }
        case QBKeyboardTypeNumandABC: {
            [self dismissSymbolView];
            [self dismissAlphabetView];
            self.allowsABC = YES;
            break;
        }
        case QBKeyboardTypeSymbol: {
            [self dismissAlphabetView];
            [self showSymbolView];
            self.allowsABC = YES;
            break;
        }
        case QBKeyboardTypeAlphabetandandNumABC: {
//            self.keyboardType = QBKeyboardTypeNumandABC;
            self.allowsABC = YES;
//            [self layoutSubviews];
            self.keyboardType = QBKeyboardTypeAlphabet;
            break;
        }
            default:
            break;
    }
}

#pragma mark - 切换 字母键盘
- (void)showAlphabetView {
    self.alphabetView.hidden = NO;
}

- (void)dismissAlphabetView {
    self.alphabetView.hidden = YES;
}

#pragma mark - 切换 符号键盘
- (void)showSymbolView {
    self.symbolView.hidden = NO;
}

- (void)dismissSymbolView {
    self.symbolView.hidden = YES;
}

#pragma mark - 显示／隐藏 X
- (void)setAllowsX:(BOOL)allowsX {
    if (_allowsX != allowsX) {
        _allowsX = allowsX;
        QBKeyBoardButton *specialKey = self.buttonDictionary[@(QBNumberKeyboardButtonDecimalPoint)];
        specialKey.style = QBNumberKeyboardButtonStyleWhite;
        [specialKey setTitle:@"X" forState:UIControlStateNormal];
        [specialKey removeTarget:self action:@selector(_buttonInput:) forControlEvents:UIControlEventTouchUpInside];
        [specialKey addTarget:self action:@selector(XbuttonInput:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

#pragma mark - 显示／隐藏 ABC
- (void)setAllowsABC:(BOOL)allowsABC {
    if (_allowsABC != allowsABC) {
        _allowsABC = allowsABC;
        self.alphabetView.allowsABC = allowsABC;
        self.symbolView.allowsABC = allowsABC;
        QBKeyBoardButton *specialKey = self.buttonDictionary[@(QBNumberKeyboardButtonDecimalPoint)];
        specialKey.style = QBNumberKeyboardButtonStyleWhite;
        [specialKey setTitle:@"ABC" forState:UIControlStateNormal];
        [specialKey removeTarget:self action:@selector(_buttonInput:) forControlEvents:UIControlEventTouchUpInside];
        [specialKey addTarget:self action:@selector(ABCbuttonInput:) forControlEvents:UIControlEventTouchUpInside];
    }
}


#pragma mark - 显示／隐藏 alert
- (void)setAllowsTopAlert:(BOOL)allowsTopAlert {
    if (_allowsTopAlert != allowsTopAlert) {
        _allowsTopAlert = allowsTopAlert;
        self.alphabetView.isShowTopAlert = allowsTopAlert;
        self.symbolView.isShowTopAlert = allowsTopAlert;
    }
    
}

#pragma mark - 配置数字
- (void)setNumbers:(NSArray<NSString *> *)numbers {
    if (numbers) {
        _numbers = numbers;
        const NSInteger numberMin = QBNumberKeyboardButtonNumberMin;
        const NSInteger numberMax = QBNumberKeyboardButtonNumberMax;
        NSDictionary *buttonDictionary = self.buttonDictionary;
        for (QBNumberKeyboardButton key = numberMin; key < numberMax; key++) {
            UIButton *button = buttonDictionary[@(key)];
            [button setTitle:numbers[key-numberMin] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - 配置return title
- (void)setReturnKeyTitle:(NSString *)title {
    if (![title isEqualToString:self.returnKeyTitle]) {
        UIButton *button = self.buttonDictionary[@(QBNumberKeyboardButtonDone)];
        if (button) {
            NSString *returnKeyTitle = (title != nil && title.length > 0) ? title : [self defaultReturnKeyTitle];
            [button setTitle:returnKeyTitle forState:UIControlStateNormal];
        }
    }
}

- (NSString *)returnKeyTitle
{
    UIButton *button = self.buttonDictionary[@(QBNumberKeyboardButtonDone)];
    if (button) {
        NSString *title = [button titleForState:UIControlStateNormal];
        if (title != nil && title.length > 0) {
            return title;
        }
    }
    return [self defaultReturnKeyTitle];
}

#pragma mark - 配置键盘类型
- (void)setKeyboardType:(QBKeyboardType)keyboardType {
//    if (self.keyboardType != keyboardType) {
        _keyboardType = keyboardType;
        [self cutKeyboardWithType:keyboardType];
//    }
}

- (NSString *)defaultReturnKeyTitle
{
    NSString *done = @"Done";
    NSString *currentLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([currentLanguage containsString:@"zh-Hans"] || [currentLanguage isEqualToString:@"zh-Hant"]) {
        done = @"完成";
    }

    return done;
}

#pragma mark - Layout.

NS_INLINE CGRect MMButtonRectMake(CGRect rect, CGRect contentRect, UIUserInterfaceIdiom interfaceIdiom){
    rect = CGRectOffset(rect, contentRect.origin.x, contentRect.origin.y);
    
    if (interfaceIdiom == UIUserInterfaceIdiomPad) {
        CGFloat inset = QBNumberKeyboardPadSpacing / 2.0f;
        rect = CGRectInset(rect, inset, inset);
    }
    
    return rect;
};

#if CGFLOAT_IS_DOUBLE
#define MMRound round
#else
#define MMRound roundf
#endif

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.keyboardType == QBKeyboardTypeSymbol || self.keyboardType == QBKeyboardTypeSymbolandNum) {
        return;
    }
    
    CGRect bounds = (CGRect){
        .size = self.bounds.size
    };
    
    NSDictionary *buttonDictionary = self.buttonDictionary;
    
    // Settings.
    const UIUserInterfaceIdiom interfaceIdiom = UI_USER_INTERFACE_IDIOM();
    const CGFloat spacing = (interfaceIdiom == UIUserInterfaceIdiomPad) ? QBNumberKeyboardPadBorder : 0.0f;
    const CGFloat maximumWidth = (interfaceIdiom == UIUserInterfaceIdiomPad) ? 400.0f : CGRectGetWidth(bounds);
    
    const CGFloat width = MIN(maximumWidth, CGRectGetWidth(bounds));
    const CGRect contentRect = (CGRect){
        .origin.x = MMRound((CGRectGetWidth(bounds) - width) / 2.0f),
        .origin.y = spacing,
        .size.width = width,
        .size.height = CGRectGetHeight(bounds) - (spacing * 2.0f)
    };
    
    // Layout.
    const CGFloat rowHeight = QBNumberKeyboardRowHeight;
    CGFloat columnWidth = CGRectGetWidth(contentRect) / 4.0f;
    
    if (self.keyboardType == QBKeyboardTypeNum || self.keyboardType == QBKeyboardTypeNumandABC) {
        columnWidth = CGRectGetWidth(contentRect) / 3.0f;
    }
    // Layout numbers.数字
    const NSInteger numberMin = QBNumberKeyboardButtonNumberMin;
    const NSInteger numberMax = QBNumberKeyboardButtonNumberMax;
    
    const NSInteger numbersPerLine = 3;
    
    CGSize numberSize = CGSizeMake(columnWidth, rowHeight);
    
    
    
    for (QBNumberKeyboardButton key = numberMin; key < numberMax; key++) {
        UIButton *button = buttonDictionary[@(key)];
        NSInteger digit = key - numberMin;
        
        CGRect rect = (CGRect){ .size = numberSize };
        
        if (digit == 0) {
            rect.origin.y = numberSize.height * 3;
            rect.origin.x = numberSize.width;
            
            if (self.keyboardType != QBKeyboardTypeNum && self.keyboardType != QBKeyboardTypeNumandABC) {
                rect.size.width = numberSize.width * 2.0f;
            }
            
        } else {
            NSUInteger idx = (digit - 1);
            
            NSInteger line = idx / numbersPerLine;
            NSInteger pos = idx % numbersPerLine;
            
            rect.origin.y = line * numberSize.height;
            rect.origin.x = pos * numberSize.width;
        }
        
        [button setFrame:MMButtonRectMake(rect, contentRect, interfaceIdiom)];
    }
    
    // Layout decimal point.小数点
    UIButton *decimalPointKey = buttonDictionary[@(QBNumberKeyboardButtonDecimalPoint)];
    if (decimalPointKey) {
        CGRect rect = (CGRect){ .size = numberSize };
        rect.origin.y = numberSize.height * 3;
        
        [decimalPointKey setFrame:MMButtonRectMake(rect, contentRect, interfaceIdiom)];
        if (self.keyboardType == QBKeyboardTypeNum) {
            decimalPointKey.hidden = YES;
        }
    }
    
    // Layout utility column.删除和完成
    const int utilityButtonKeys[2] = { QBNumberKeyboardButtonBackspace, QBNumberKeyboardButtonDone };
    const CGSize utilitySize = CGSizeMake(columnWidth, rowHeight * 2.0f);
    
    if (self.keyboardType == QBKeyboardTypeNum) {
        //删除
        UIButton *delete = buttonDictionary[@(QBNumberKeyboardButtonBackspace)];
        delete.frame = decimalPointKey.frame;
        //完成
        UIButton *done = buttonDictionary[@(QBNumberKeyboardButtonDone)];
        CGRect rect = (CGRect){ .size = numberSize };
        rect.origin.y = numberSize.height * 3;
        rect.origin.x = numberSize.width * 2;
        [done setFrame:MMButtonRectMake(rect, contentRect, interfaceIdiom)];
        
    }else if (self.keyboardType == QBKeyboardTypeNumandABC) {
        //完成
        UIButton *done = buttonDictionary[@(QBNumberKeyboardButtonDone)];
        done.hidden = YES;
        //删除
        UIButton *delete = buttonDictionary[@(QBNumberKeyboardButtonBackspace)];
        CGRect rect = (CGRect){ .size = numberSize };
        rect.origin.y = numberSize.height * 3;
        rect.origin.x = numberSize.width * 2;
        [delete setFrame:MMButtonRectMake(rect, contentRect, interfaceIdiom)];

    }else {
        for (NSInteger idx = 0; idx < sizeof(utilityButtonKeys) / sizeof(int); idx++) {
            QBNumberKeyboardButton key = utilityButtonKeys[idx];
            
            UIButton *button = buttonDictionary[@(key)];
            CGRect rect = (CGRect){ .size = utilitySize };
            
            rect.origin.x = columnWidth * 3.0f;
            rect.origin.y = idx * utilitySize.height;
            
            [button setFrame:MMButtonRectMake(rect, contentRect, interfaceIdiom)];
        }
    }
    
    // Layout separators if phone. 分割线
    if (interfaceIdiom != UIUserInterfaceIdiomPad) {
        NSMutableArray *separatorViews = self.separatorViews;
        
        const NSUInteger totalRows = numbersPerLine + 1;
        //分割线布局
        const CGFloat separatorDimension = 1.0f / (self.window.screen.scale ?: 1.0f);
        
        [separatorViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIView *separator = obj;
            
            CGRect rect = CGRectZero;
            
            if (idx < totalRows) {
                rect.origin.y = idx * rowHeight;
                if (idx % 2 && self.keyboardType != QBKeyboardTypeNum && self.keyboardType != QBKeyboardTypeNumandABC) {
                    rect.size.width = CGRectGetWidth(contentRect) - columnWidth;
                } else {
                    rect.size.width = CGRectGetWidth(contentRect);
                }
                rect.size.height = separatorDimension;
            } else {
                NSInteger col = (idx - totalRows);
                
                rect.origin.x = (col + 1) * columnWidth;
                rect.size.width = separatorDimension;
                
                if (col == 1) {
                    rect.size.height = CGRectGetHeight(contentRect) - rowHeight;
                } else {
                    rect.size.height = CGRectGetHeight(contentRect);
                }
            }
            
            [separator setFrame:MMButtonRectMake(rect, contentRect, interfaceIdiom)];
        }];
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    const UIUserInterfaceIdiom interfaceIdiom = UI_USER_INTERFACE_IDIOM();
    const CGFloat spacing = (interfaceIdiom == UIUserInterfaceIdiomPad) ? QBNumberKeyboardPadBorder : 0.0f;
    
    size.height = QBNumberKeyboardRowHeight * QBNumberKeyboardRows + (spacing * 2.0f);
    
    if (size.width == 0.0f) {
        size.width = [UIScreen mainScreen].bounds.size.width;
    }
    
    return size;
}

#pragma mark - QBAlphabetViewKeyboardDelegate
- (void)alphabetKeyboard:(QBAlphabetView *)letter didClickButton:(UIButton *)button {
    
    // Get first responder.
    id <UIKeyInput> keyInput = self.keyInput;
    id <QBKeyboardDelegate> delegate = self.delegate;
    
    if (!keyInput) {
        return;
    }
    
    NSString *title = [button titleForState:UIControlStateNormal];
    
    if ([delegate respondsToSelector:@selector(keyboard:shouldInsertText:)]) {
        BOOL shouldInsert = [delegate keyboard:self shouldInsertText:title];
        if (!shouldInsert) {
            return;
        }
    }
    
    [keyInput insertText:title];
}

- (void)alphabetKeyboardKeyboardDidClickButton:(UIButton *)button {
    // Get first responder.
    id <UIKeyInput> keyInput = self.keyInput;
    id <QBKeyboardDelegate> delegate = self.delegate;
    
    if (!keyInput) {
        return;
    }
    
    //输入删除
    if (button.tag == ButtonTypeDelete) {
        BOOL shouldDeleteBackward = YES;
        
        if ([delegate respondsToSelector:@selector(keyboardShouldDeleteBackward:)]) {
            shouldDeleteBackward = [delegate keyboardShouldDeleteBackward:self];
        }
        
        if (shouldDeleteBackward) {
            [keyInput deleteBackward];
        }
    }
    
    // Handle done. 输入完成
    if (button.tag == ButtonTypeDone) {
        BOOL shouldReturn = YES;
        
        if ([delegate respondsToSelector:@selector(keyboardShouldReturn:)]) {
            shouldReturn = [delegate keyboardShouldReturn:self];
        }
        
        if (shouldReturn) {
            [self _dismissKeyboard:nil];
        }
    }
    
    //输入数字
    if (button.tag == ButtonTypeNum) {
        self.keyboardType = QBKeyboardTypeNumandABC;
        [self layoutSubviews];
    }
    
    //输入数字和字符
    if (button.tag == ButtonTypeNumandSymbol) {
        self.keyboardType = QBKeyboardTypeSymbolandNum;
    }
    
    //输入字符
    if (button.tag == ButtonTypeSymbol) {
        self.keyboardType = QBKeyboardTypeSymbol;
    }
}

- (void)symbolKeyboard:(QBSymbolView *)symbol didClickButton:(UIButton *)button {
    
    // Get first responder.
    id <UIKeyInput> keyInput = self.keyInput;
    id <QBKeyboardDelegate> delegate = self.delegate;
    
    if (!keyInput) {
        return;
    }
    
    NSString *title = [button titleForState:UIControlStateNormal];
    
    if ([delegate respondsToSelector:@selector(keyboard:shouldInsertText:)]) {
        BOOL shouldInsert = [delegate keyboard:self shouldInsertText:title];
        if (!shouldInsert) {
            return;
        }
    }
    
    [keyInput insertText:title];
}

- (void)symbolKeyboardKeyboardDidClickButton:(UIButton *)button {
    // Get first responder.
    id <UIKeyInput> keyInput = self.keyInput;
    id <QBKeyboardDelegate> delegate = self.delegate;
    
    if (!keyInput) {
        return;
    }
    
    //输入删除
    if (button.tag == ButtonTypeDelete) {
        BOOL shouldDeleteBackward = YES;
        
        if ([delegate respondsToSelector:@selector(keyboardShouldDeleteBackward:)]) {
            shouldDeleteBackward = [delegate keyboardShouldDeleteBackward:self];
        }
        
        if (shouldDeleteBackward) {
            [keyInput deleteBackward];
        }
    }
    
    // Handle done. 输入完成
    if (button.tag == ButtonTypeDone) {
        BOOL shouldReturn = YES;
        
        if ([delegate respondsToSelector:@selector(keyboardShouldReturn:)]) {
            shouldReturn = [delegate keyboardShouldReturn:self];
        }
        
        if (shouldReturn) {
            [self _dismissKeyboard:nil];
        }
    }
        
    //输入字母
    if (button.tag == ButtonTypeAlphabet) {
        self.keyboardType = QBKeyboardTypeAlphabet;
    }
    //输入数字
    if (button.tag == ButtonTypeNum) {
        self.keyboardType = QBKeyboardTypeNumandABC;
        [self layoutSubviews];
    }
}

#pragma mark - Audio feedback.

- (BOOL)enableInputClicksWhenVisible
{
    return YES;
}

#pragma mark - Accessing keyboard images.

+ (UIImage *)_keyboardImageNamed:(NSString *)name
{
    NSString *resource = [name stringByDeletingPathExtension];
    NSString *extension = [name pathExtension];
    
    if (resource) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        if (bundle) {
            NSString *resourcePath = [bundle pathForResource:resource ofType:extension];
            
            return [UIImage imageWithContentsOfFile:resourcePath];
        } else {
            return [UIImage imageNamed:name];
        }
    }
    return nil;
}

- (QBAlphabetView *)alphabetView {
    if (!_alphabetView) {
        _alphabetView = [[QBAlphabetView alloc] initWithFrame:self.bounds];
        _alphabetView.delegate = self;
        _alphabetView.hidden = YES;
        _alphabetView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _alphabetView;
}

- (QBSymbolView *)symbolView {
    if (!_symbolView) {
        _symbolView = [[QBSymbolView alloc] initWithFrame:self.bounds];
        _symbolView.delegate = self;
        _symbolView.hidden = YES;
        _symbolView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _symbolView;
}




@end
