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
    
    //LastFM
    _lastFMAccountTextField.delegate = self;
    _lastFMAccountTextField.text = [[Setting sharedSetting] lastFMAccount];
    
    //View Parameters
    UIColor *titleBackgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    UIColor *titleTextColor = [UIColor whiteColor];
    UIColor *contentBackgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3];
    UIColor *contentTextColor = [UIColor blackColor];
    float barHeight = 20.0f;
    float width = [[UIScreen mainScreen] bounds].size.width;
    float height = [[UIScreen mainScreen] bounds].size.height;
    float scrollWidth = width;
    float scrollHeight = height*2;
    float currentHeight = 0.0f;
    float left = 5.0f;
    float right = 5.0f;
    float unitHeight = 30.0f;
    int item = 0;
    UIView *accountView;
    UILabel *titleLabel;
    UILabel *contentLabel;
    UITextField *textField;
    
    //ScrollView
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [scrollView setContentSize:CGSizeMake(scrollWidth, scrollHeight)];
    scrollView.userInteractionEnabled = YES;
    self.view = scrollView;
    
    //BackgroundView
    UIView *backgroundView = [[BackgroundImageView alloc] initWithFrame:CGRectMake(0, 0, scrollWidth, scrollHeight)];
    [scrollView addSubview:backgroundView];
    [scrollView sendSubviewToBack:backgroundView];
    
    /*AccountView*/
    item = 3;
    currentHeight += barHeight;
    accountView = [[UIView alloc] initWithFrame:CGRectMake(0, currentHeight, width, item*unitHeight)];
    accountView.backgroundColor = contentBackgroundColor;
    [scrollView addSubview:accountView];
    //Title
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, unitHeight)];
    titleLabel.backgroundColor = titleBackgroundColor;
    titleLabel.text = @" My Avibe Account";
    titleLabel.textColor = titleTextColor;
    titleLabel.textAlignment = NSTextAlignmentNatural;
    [accountView addSubview:titleLabel];
    //User Name
    contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, unitHeight, width/2, unitHeight)];
    contentLabel.backgroundColor = contentBackgroundColor;
    contentLabel.text = @" Username";
    contentLabel.textColor = contentTextColor;
    contentLabel.textAlignment = NSTextAlignmentNatural;
    [accountView addSubview:contentLabel];
    //User Name Description
    contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(width/2, unitHeight, width/2-right, unitHeight)];
    contentLabel.backgroundColor = contentBackgroundColor;
    contentLabel.text = @" myhgew ";
    contentLabel.textColor = contentTextColor;
    contentLabel.textAlignment = NSTextAlignmentRight;
    [accountView addSubview:contentLabel];
    //Mobile#
    contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, unitHeight*2, width/2, unitHeight)];
    contentLabel.backgroundColor = contentBackgroundColor;
    contentLabel.text = @" Mobile#";
    contentLabel.textColor = contentTextColor;
    contentLabel.textAlignment = NSTextAlignmentNatural;
    [accountView addSubview:contentLabel];
    //Mobile# Description
    contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(width/2, unitHeight*2, width/2-right, unitHeight)];
    contentLabel.backgroundColor = contentBackgroundColor;
    contentLabel.text = @" 9193082709 ";
    contentLabel.textColor = contentTextColor;
    contentLabel.textAlignment = NSTextAlignmentRight;
    [accountView addSubview:contentLabel];
    
    /*OtherAccountView*/
    currentHeight += item*unitHeight;
    item = 10;
    accountView = [[UIView alloc] initWithFrame:CGRectMake(0, currentHeight, width, item*unitHeight)];
    accountView.backgroundColor = contentBackgroundColor;
    [scrollView addSubview:accountView];
    //Title
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, unitHeight)];
    titleLabel.backgroundColor = titleBackgroundColor;
    titleLabel.text = @" My Other Accounts";
    titleLabel.textColor = titleTextColor;
    titleLabel.textAlignment = NSTextAlignmentNatural;
    [accountView addSubview:titleLabel];
    //TextField
    textField = [[UITextField alloc] initWithFrame:CGRectMake(width/2, unitHeight, width/2, unitHeight)];
    [accountView addSubview:textField];
    
    /*Feed Clogging*/
    currentHeight += item*unitHeight;
    item = 3;
    accountView = [[UIView alloc] initWithFrame:CGRectMake(0, currentHeight, width, item*unitHeight)];
    accountView.backgroundColor = contentBackgroundColor;
    [scrollView addSubview:accountView];
    //Title
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, unitHeight)];
    titleLabel.backgroundColor = titleBackgroundColor;
    titleLabel.text = @" Feed Clogging";
    titleLabel.textColor = titleTextColor;
    titleLabel.textAlignment = NSTextAlignmentNatural;
    [accountView addSubview:titleLabel];
    
    /*Other Setting*/
    currentHeight += item*unitHeight;
    item = 3;
    accountView = [[UIView alloc] initWithFrame:CGRectMake(0, currentHeight, width, item*unitHeight)];
    accountView.backgroundColor = contentBackgroundColor;
    [scrollView addSubview:accountView];
    //Title
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, unitHeight)];
    titleLabel.backgroundColor = titleBackgroundColor;
    titleLabel.text = @" Others";
    titleLabel.textColor = titleTextColor;
    titleLabel.textAlignment = NSTextAlignmentNatural;
    [accountView addSubview:titleLabel];
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
