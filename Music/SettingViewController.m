//
//  SettingViewController.m
//  Beet
//
//  Created by Yuhua Mai on 12/28/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "SettingViewController.h"

#import "UIViewController+MMDrawerController.h"

#import "Setting.h"

@interface SettingViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *lastFMAccountTextField;

@end

@implementation SettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupBarMenuButton];
    
    _lastFMAccountTextField.delegate = self;
    _lastFMAccountTextField.text = [[Setting sharedSetting] lastFMAccount];
}

#pragma mark - BarMenuButton
-(void)setupBarMenuButton{
    UIBarButtonItem * leftDrawerButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    self.mm_drawerController.navigationItem.leftBarButtonItem = leftDrawerButton;
    
    UIBarButtonItem * rightDrawerButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(popCurrentView)];
    [self.mm_drawerController.navigationItem setRightBarButtonItem:rightDrawerButton];
}


- (void)popCurrentView
{
    [self.mm_drawerController setCenterViewController:self.previousViewController];
}

#pragma mark - UITextField Delegate

- (void)setLastFMAccount:(NSString*)account{
    [[Setting sharedSetting] setLastFMAccount:account];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //hide the keyboard
    if (textField == _lastFMAccountTextField) {
        [self setLastFMAccount:textField.text];
    }
    
    [textField resignFirstResponder];
    
    //return NO or YES, it doesn't matter
    return YES;
}

#pragma mark - Touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UIView * txt in self.view.subviews){
        if ([txt isKindOfClass:[UITextField class]] && [txt isFirstResponder]) {
            UITextField *textField = (UITextField*)txt;

            if (textField == _lastFMAccountTextField) {
                [self setLastFMAccount:textField.text];
            }
            
            [txt resignFirstResponder];
        }
    }
}

@end
