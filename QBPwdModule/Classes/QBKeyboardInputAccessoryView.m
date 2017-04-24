
//
//  QBKeyboardInputAccessoryView.m
//  Pods
//
//  Created by Qiaokai on 2017/4/12.
//
//

#import "QBKeyboardInputAccessoryView.h"

@interface QBKeyboardInputAccessoryView ()

@property (nonatomic ,strong) UILabel *titleLabel;
@property (nonatomic ,strong) UIButton *doneButton;

@end

@implementation QBKeyboardInputAccessoryView

+ (instancetype)configureQBKeyboardInputAccessoryView {
    QBKeyboardInputAccessoryView *view = [[QBKeyboardInputAccessoryView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self configureUI];
    }
    return self;
}

- (void)configureUI {
    [self addSubview:self.titleLabel];
    [self addSubview:self.doneButton];
    [self.titleLabel setFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds) - 65 * 2, CGRectGetHeight(self.bounds))];
    self.titleLabel.center = CGPointMake(self.center.x - 10, self.center.y);
    [self.doneButton setFrame:CGRectMake(CGRectGetWidth(self.bounds) - 65, 0, 55, CGRectGetHeight(self.bounds))];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 0.5)];
    line.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.1f];
    [self addSubview:line];
}

- (void)donePressed {
    if ([_delegate respondsToSelector:@selector(keyboardInputAccessoryViewShouldReturn)]) {
        [_delegate keyboardInputAccessoryViewShouldReturn];
    }
}

- (UIButton *)doneButton {
    if (!_doneButton) {
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
        NSString *done = @"Done";
        NSString *currentLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
        if ([currentLanguage containsString:@"zh-Hans"] || [currentLanguage isEqualToString:@"zh-Hant"]) {
            done = @"完成";
        }
        [_doneButton setTitle:done forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(donePressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"安全键盘";
    }
    return _titleLabel;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
