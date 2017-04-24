//
//  QBKeyBoardButton.m
//  Demo
//
//  Created by Qiaokai on 2017/3/1.
//  Copyright © 2017年 Matías Martínez. All rights reserved.
//

#import "QBKeyBoardButton.h"

@interface QBKeyBoardButton ()

@property (strong, nonatomic) NSTimer *continuousPressTimer;
@property (assign, nonatomic) NSTimeInterval continuousPressTimeInterval;

@property (strong, nonatomic) UIColor *fillColor;
@property (strong, nonatomic) UIColor *highlightedFillColor;

@property (strong, nonatomic) UIColor *controlColor;
@property (strong, nonatomic) UIColor *highlightedControlColor;

@end

@implementation QBKeyBoardButton

+ (QBKeyBoardButton *)keyboardButtonWithStyle:(QBNumberKeyboardButtonStyle)style
{
    QBKeyBoardButton *button = [self buttonWithType:UIButtonTypeCustom];
    button.style = style;
    
    return button;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _buttonStyleDidChange];
    }
    return self;
}

- (void)setStyle:(QBNumberKeyboardButtonStyle)style
{
    if (style != _style) {
        _style = style;
        
        [self _buttonStyleDidChange];
    }
}

- (void)_buttonStyleDidChange
{
    const UIUserInterfaceIdiom interfaceIdiom = UI_USER_INTERFACE_IDIOM();
    const QBNumberKeyboardButtonStyle style = self.style;
    
    UIColor *fillColor = nil;
    UIColor *highlightedFillColor = nil;
    if (style == QBNumberKeyboardButtonStyleWhite) {
        fillColor = [UIColor whiteColor];
        highlightedFillColor = [UIColor colorWithRed:0.82f green:0.837f blue:0.863f alpha:1];
    } else if (style == QBNumberKeyboardButtonStyleGray) {
        if (interfaceIdiom == UIUserInterfaceIdiomPad) {
            fillColor =  [UIColor colorWithRed:0.674f green:0.7f blue:0.744f alpha:1];
        } else {
            fillColor = [UIColor colorWithRed:0.81f green:0.837f blue:0.86f alpha:1];
        }
        highlightedFillColor = [UIColor whiteColor];
    } else if (style == QBNumberKeyboardButtonStyleDone) {
        fillColor = [UIColor colorWithRed:0 green:0.479f blue:1 alpha:1];
        highlightedFillColor = [UIColor whiteColor];
    }
    
    UIColor *controlColor = nil;
    UIColor *highlightedControlColor = nil;
    if (style == QBNumberKeyboardButtonStyleDone) {
        controlColor = [UIColor whiteColor];
        highlightedControlColor = [UIColor blackColor];
    } else {
        controlColor = [UIColor blackColor];
        highlightedControlColor = [UIColor blackColor];
    }
    
    [self setTitleColor:controlColor forState:UIControlStateNormal];
    [self setTitleColor:highlightedControlColor forState:UIControlStateSelected];
    [self setTitleColor:highlightedControlColor forState:UIControlStateHighlighted];
    
    self.fillColor = fillColor;
    self.highlightedFillColor = highlightedFillColor;
    self.controlColor = controlColor;
    self.highlightedControlColor = highlightedControlColor;
    
    if (interfaceIdiom == UIUserInterfaceIdiomPad) {
        CALayer *buttonLayer = [self layer];
        buttonLayer.cornerRadius = 4.0f;
        buttonLayer.shadowColor = [UIColor colorWithRed:0.533f green:0.541f blue:0.556f alpha:1].CGColor;
        buttonLayer.shadowOffset = CGSizeMake(0, 1.0f);
        buttonLayer.shadowOpacity = 1.0f;
        buttonLayer.shadowRadius = 0.0f;
    }
    
    [self _updateButtonAppearance];
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    
    if (newWindow) {
        [self _updateButtonAppearance];
    }
}

- (void)_updateButtonAppearance
{
    if (self.isHighlighted || self.isSelected) {
        self.backgroundColor = self.highlightedFillColor;
        self.imageView.tintColor = self.controlColor;
    } else {
        self.backgroundColor = self.fillColor;
        self.imageView.tintColor = self.highlightedControlColor;
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    [self _updateButtonAppearance];
}

#pragma mark - Continuous press 点击删除按钮不放， 持续删除

- (void)addTarget:(id)target action:(SEL)action forContinuousPressWithTimeInterval:(NSTimeInterval)timeInterval
{
    self.continuousPressTimeInterval = timeInterval;
    
    [self addTarget:target action:action forControlEvents:UIControlEventValueChanged];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL begins = [super beginTrackingWithTouch:touch withEvent:event];
    const NSTimeInterval continuousPressTimeInterval = self.continuousPressTimeInterval;
    
    if (begins && continuousPressTimeInterval > 0) {
        [self _beginContinuousPressDelayed];
    }
    
    return begins;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super endTrackingWithTouch:touch withEvent:event];
    [self _cancelContinousPressIfNeeded];
}

- (void)dealloc
{
    [self _cancelContinousPressIfNeeded];
}

- (void)_beginContinuousPress
{
    const NSTimeInterval continuousPressTimeInterval = self.continuousPressTimeInterval;
    
    if (!self.isTracking || continuousPressTimeInterval == 0) {
        return;
    }
    
    self.continuousPressTimer = [NSTimer scheduledTimerWithTimeInterval:continuousPressTimeInterval target:self selector:@selector(_handleContinuousPressTimer:) userInfo:nil repeats:YES];
}

- (void)_handleContinuousPressTimer:(NSTimer *)timer
{
    if (!self.isTracking) {
        [self _cancelContinousPressIfNeeded];
        return;
    }
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)_beginContinuousPressDelayed
{
    [self performSelector:@selector(_beginContinuousPress) withObject:nil afterDelay:self.continuousPressTimeInterval * 2.0f];
}

- (void)_cancelContinousPressIfNeeded
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_beginContinuousPress) object:nil];
    
    NSTimer *timer = self.continuousPressTimer;
    if (timer) {
        [timer invalidate];
        
        self.continuousPressTimer = nil;
    }
}
@end

@interface QBAlertKeyBoardButton ()

/** 漂浮窗 */
@property (nonatomic, strong) UIView *alertView;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *alertLetterLabel;

@end

@implementation QBAlertKeyBoardButton

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL begins = [super beginTrackingWithTouch:touch withEvent:event];
    
    if (self.isShowTopAlert) {
        self.alertView.center = CGPointMake(CGRectGetMidX(self.bounds), -10);
        self.alertLetterLabel.text = [self titleForState:UIControlStateNormal];
        [self addSubview:self.alertView];
    }
    return begins;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super endTrackingWithTouch:touch withEvent:event];
    
    if (self.isShowTopAlert) {
        [self.alertLetterLabel removeFromSuperview];
        [self.imgView removeFromSuperview];
        [self.alertView removeFromSuperview];
        self.alertLetterLabel = nil;
        self.imgView = nil;
        self.alertView = nil;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.isShowTopAlert) {
        self.alertView.frame = CGRectMake(0, -(89 - self.bounds.size.height), self.bounds.size.width, 90);
        self.imgView.frame = CGRectMake(-8, 0, self.bounds.size.width + 16, 90);
        
        self.alertLetterLabel.frame = CGRectMake(0, 10, self.bounds.size.width, 36);
    }
}

- (UIView *)alertView {
    if (!_alertView) {
        _alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _alertView.backgroundColor = [UIColor clearColor];
//        _alertView.clipsToBounds = YES;
//        _alertView.layer.masksToBounds = YES;
//        _alertView.layer.cornerRadius = 3;
//        _alertView.layer.borderColor = [UIColor grayColor].CGColor;
//        _alertView.layer.borderWidth = 0.5;
        
        [_alertView addSubview:self.imgView];
        [_alertView addSubview:self.alertLetterLabel];
        
    }
    return _alertView;
}

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithImage:[self.class _keyboardImageNamed:@"c_chaKeyboardButtonSel"]];
//        _imgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imgView;
}

- (UILabel *)alertLetterLabel {
    if (!_alertLetterLabel) {
        _alertLetterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 32)];
        _alertLetterLabel.textColor = [UIColor blackColor];
        _alertLetterLabel.font = [UIFont systemFontOfSize:32];
        _alertLetterLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _alertLetterLabel;
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
