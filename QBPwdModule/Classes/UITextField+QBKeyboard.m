//
//  UITextField+QBKeyboard.m
//  Pods
//
//  Created by Qiaokai on 2017/4/12.
//
//

#import "UITextField+QBKeyboard.h"

@implementation UITextField (QBKeyboard)

- (QBKeyboard *)addKeyBoardViewWithType:(QBKeyboardType)type title:(NSString *)title {
    QBKeyboard *keyboard = [[QBKeyboard alloc] initWithFrame:CGRectZero];
    keyboard.keyboardType = type;
    if (type != QBKeyboardTypeNumandABC && type != QBKeyboardTypeNum && type != QBKeyboardTypeNumandDecimalPoint && type != QBKeyboardTypeNumandX && type != QBKeyboardTypeAlphabetandandNumABC) {
        keyboard.allowsTopAlert = YES;
    }
    if (type == QBKeyboardTypeNumandABC || type == QBKeyboardTypeAlphabetandandNumABC) {
        
        keyboard.numbers = [self arraySortBreak];
    }
    
    QBKeyboardInputAccessoryView *view = [QBKeyboardInputAccessoryView configureQBKeyboardInputAccessoryView];
    view.title = title;
    view.delegate = self;
    
    self.inputAccessoryView = view;
    self.inputView = keyboard;
    return keyboard;
}

- (void)keyboardInputAccessoryViewShouldReturn {
    [self resignFirstResponder];
}

- (NSArray *)arraySortBreak{
    
    //数组排序
    
    //定义一个数字数组
    
    NSArray *array = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6", @"7", @"8", @"9", @"0"];
    
    //对数组进行排序
    
    return [array sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
        
        NSLog(@"%@~%@",obj1,obj2);
        
        //乱序
        
        if (arc4random_uniform(2) == 0) {
            
            return [obj2 compare:obj1]; //降序
            
        }
        
        else{
            
            return [obj1 compare:obj2]; //升序
            
        }
        
    }];
}

@end
