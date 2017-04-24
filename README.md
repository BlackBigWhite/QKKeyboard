# QBPwdModule

[![CI Status](http://img.shields.io/travis/qiaokai/QBPwdModule.svg?style=flat)](https://travis-ci.org/qiaokai/QBPwdModule)
[![Version](https://img.shields.io/cocoapods/v/QBPwdModule.svg?style=flat)](http://cocoapods.org/pods/QBPwdModule)
[![License](https://img.shields.io/cocoapods/l/QBPwdModule.svg?style=flat)](http://cocoapods.org/pods/QBPwdModule)
[![Platform](https://img.shields.io/cocoapods/p/QBPwdModule.svg?style=flat)](http://cocoapods.org/pods/QBPwdModule)

>>```
source 'http://git.qianbaoqm.com/mobileios/QBSpecs.git'
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
target ‘target_name’ do
pod 'QBPwdModule', '~> 2.5’
end
>>```

SDK使用说明:<br>
---------------

>1.初始化:<br>

>>```
#import "QBKeyboard.h"
-------
QBKeyboard *keyboard = [[QBKeyboard alloc] initWithFrame:CGRectZero];
keyboard.keyboardType = QBKeyboardTypeNumandX;
keyboard.delegate = self;
keyboard.numbers = @[@"1", @"3", @"2", @"5", @"4", @"6", @"7", @"8", @"9", @"0"];
// 
UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
textField.inputView = keyboard;
textField.text = @(123456789).stringValue;
textField.placeholder = @"Type something…";
textField.font = [UIFont systemFontOfSize:24.0f];
//
----- or----
#import "UITextField+QBKeyboard.h"
--------
[self.textfield addKeyBoardViewWithType:QBKeyboardTypeNumandABC title:@"廊坊安全键盘"];
>>```

>2.实现协议:<br>

>>```
- (BOOL)keyboard:(QBKeyboard *)keyboard shouldInsertText:(NSString *)text;
>>```

>>```
- (BOOL)keyboardShouldReturn:(QBKeyboard *)keyboard;
>>```

>>```
- (BOOL)keyboardShouldDeleteBackward:(QBKeyboard *)keyboard;
>>```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

QBPwdModule is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "QBPwdModule"
```

## Author

qiaokai, qiaokai@qianbao.com

## License

QBPwdModule is available under the MIT license. See the LICENSE file for more info.
