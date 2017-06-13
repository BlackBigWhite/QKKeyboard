//
//  QBKeyBoardButton.h
//  Demo
//
//  Created by Qiaokai on 2017/3/1.
//  Copyright © 2017年 Matías Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBKeyboard.h"

@interface QBKeyBoardButton : UIButton

+ (QBKeyBoardButton *)keyboardButtonWithStyle:(QBNumberKeyboardButtonStyle)style;

// The style of the keyboard button.
@property (assign, nonatomic) QBNumberKeyboardButtonStyle style;

// Notes the continuous press time interval, then adds the target/action to the UIControlEventValueChanged event.
- (void)addTarget:(id)target action:(SEL)action forContinuousPressWithTimeInterval:(NSTimeInterval)timeInterval;

@end

@interface QBAlertKeyBoardButton : UIButton

@property (nonatomic, assign) BOOL isShowTopAlert;


@end
