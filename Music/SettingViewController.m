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
    
    self.view.backgroundColor = [[Setting sharedSetting] sharedBackgroundColor];
    
    _lastFMAccountTextField.delegate = self;
    _lastFMAccountTextField.text = [[Setting sharedSetting] lastFMAccount];
}

#pragma mark - BarMenuButton
-(void)setupBarMenuButton{
    //Navigation Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = @"Settings";
    titleLabel.textColor = [UIColor colorWithRed:3.0/255.0
                                           green:49.0/255.0
                                            blue:107.0/255.0
                                           alpha:1.0];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [titleLabel sizeToFit];
    self.mm_drawerController.navigationItem.titleView = titleLabel;
    
    
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
