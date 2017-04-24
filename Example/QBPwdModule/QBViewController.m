//
//  QBViewController.m
//  QBPwdModule
//
//  Created by qiaokai on 03/01/2017.
//  Copyright (c) 2017 qiaokai. All rights reserved.
//

#import "QBViewController.h"
#import "QBKeyboard.h"
#import "UITextField+QBKeyboard.h"
@interface QBViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textfield;

@end

@implementation QBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    QBKeyboard *kb = [self.textfield addKeyBoardViewWithType:QBKeyboardTypeAlphabetandandNumABC title:@"廊坊安全键盘"];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.textfield becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
