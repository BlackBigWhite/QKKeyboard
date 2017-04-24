//
//  UITextField+QBKeyboard.h
//  Pods
//
//  Created by Qiaokai on 2017/4/12.
//
//

#import <UIKit/UIKit.h>
#import "QBKeyboard.h"

@interface UITextField (QBKeyboard)<QBKeyboardInputAccessoryViewDelegate>

- (QBKeyboard *)addKeyBoardViewWithType:(QBKeyboardType)type title:(NSString *)title;

@end
