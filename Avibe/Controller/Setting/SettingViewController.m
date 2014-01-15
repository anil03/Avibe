//
//  SettingViewController.m
//  Beet
//
//  Created by Yuhua Mai on 12/28/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//
// CustomViewController

#import "SettingViewController.h"

#import "UIViewController+MMDrawerController.h"

#import "Setting.h"
#import "PublicMethod.h"
#import "BackgroundImageView.h"

@interface SettingViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *lastFMAccountTextField;

@end

@implementation SettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupBarMenuButton];
    
    //BackgroundView
    UIView *backgroundView = [[BackgroundImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:backgroundView];
    [self.view sendSubviewToBack:backgroundView];
//    self.view.backgroundColor = [[Setting sharedSetting] sharedBackgroundColor];
    
    _lastFMAccountTextField.delegate = self;
    _lastFMAccountTextField.text = [[Setting sharedSetting] lastFMAccount];
    
    //View Parameters
    UIColor *titleBackgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    UIColor *titleTextColor = [UIColor whiteColor];
    UIColor *contentBackgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6];
    UIColor *contentTextColor = [UIColor whiteColor];
    float barHeight = 80.0f;
    float width = [[UIScreen mainScreen] bounds].size.width;
    float height = 0.0f;
    float left = 5.0f;
    float unitHeight = 30.0f;
    int item = 0;
    
    //AccountView
    item = 3;
    height += barHeight;
    UIView *accountView = [[UIView alloc] initWithFrame:CGRectMake(0, height, width, item*unitHeight)];
    accountView.backgroundColor = contentBackgroundColor;
    [self.view addSubview:accountView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, unitHeight)];
    titleLabel.backgroundColor = titleBackgroundColor;
    titleLabel.text = @" My Avibe Account";
    titleLabel.textColor = titleTextColor;
    titleLabel.textAlignment = NSTextAlignmentNatural;
    [accountView addSubview:titleLabel];
    
    //OtherAccountView
    
    //Feed Clogging
    
    //Background Art
}

#pragma mark - BarMenuButton
-(void)setupBarMenuButton{
    //Navigation Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = @"Settings";
    titleLabel.textColor = [[Setting sharedSetting] barTintColor];
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
