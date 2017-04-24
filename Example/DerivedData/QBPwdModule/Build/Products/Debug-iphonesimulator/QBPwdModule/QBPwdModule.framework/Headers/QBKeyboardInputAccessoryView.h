//
//  QBKeyboardInputAccessoryView.h
//  Pods
//
//  Created by Qiaokai on 2017/4/12.
//
//

#import <UIKit/UIKit.h>
@class QBKeyboardInputAccessoryView;

@protocol QBKeyboardInputAccessoryViewDelegate <NSObject>
@optional

/**
 输入完成 回收键盘
 
 @param keyboard
 @return           默认YES YES：回收键盘 NO：不回收
 */
- (void)keyboardInputAccessoryViewShouldReturn;

@end

@interface QBKeyboardInputAccessoryView : UIView

@property (nonatomic, weak) id<QBKeyboardInputAccessoryViewDelegate> delegate;

@property (nonatomic, strong) NSString *title;
+ (instancetype)configureQBKeyboardInputAccessoryView;

@end
