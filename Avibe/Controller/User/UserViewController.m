//
//  UserViewController.m
//  Beet
//
//  Created by Yuhua Mai on 12/7/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//
// CustomViewController

#import "UserViewController.h"

#import "MMDrawerBarButtonItem.h"
#import "MMNavigationController.h"
#import "UIViewController+MMDrawerController.h"

#import "Setting.h"
#import "BackgroundImageView.h"

@interface UserViewController () <UITextFieldDelegate>

//@property (weak, nonatomic) IBOutlet UILabel *username;
//@property (weak, nonatomic) IBOutlet UILabel *numberOfSongs;
//@property (weak, nonatomic) IBOutlet UITextField *lastFMAccountInput;



@end

@implementation UserViewController
@synthesize listenedViewController;
@synthesize userShareViewController;

- (id)init
{
    return [self initWithUsername:[[PFUser currentUser] username]];
}
- (id)initWithUsername:(NSString*)username
{
    self = [super init];
    if(self){
        _username = username;
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
	[self setupMenuButton];
    //Clear cache
    listenedViewController = nil;
    userShareViewController = nil;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //View Parameters
    UIColor *titleBackgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    UIColor *titleTextColor = [UIColor whiteColor];
    UIColor *componentBackgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3];
    UIColor *componentTextColor = [UIColor whiteColor];
    UIColor *componentTextHighlightColor = [UIColor grayColor];
    
    float width = [[UIScreen mainScreen] bounds].size.width;
    float height = [[UIScreen mainScreen] bounds].size.height;
    float barHeight = 80.0f;
    float currentHeight = 0.0f;
    float buttonWidth = width;
    float buttonHeight = 100.0f;
    float unitHeight = 30.0f;
    int item = 15;
    UIView *accountView;
    UILabel *titleLabel;
    UILabel *contentLabel;
    UITextField *textField;

    //Set up View
    self.view.backgroundColor = [[Setting sharedSetting] sharedBackgroundColor];


    //BackgroundView
    UIView *backgroundView = [[BackgroundImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:backgroundView];
    [self.view sendSubviewToBack:backgroundView];
    

    /*AccountView*/
    item = 3;
    currentHeight += barHeight;
    accountView = [[UIView alloc] initWithFrame:CGRectMake(0, currentHeight, width, item*unitHeight)];
    accountView.backgroundColor = componentBackgroundColor;
    [self.view addSubview:accountView];
    
    //Title
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, unitHeight)];
    titleLabel.backgroundColor = titleBackgroundColor;
    titleLabel.text = @" Profile";
    titleLabel.textColor = titleTextColor;
    titleLabel.textAlignment = NSTextAlignmentNatural;
    [accountView addSubview:titleLabel];

    
    //Recent History Button
    UIButton *recentHistoryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, unitHeight, buttonWidth, unitHeight)];
    [recentHistoryButton setTitle:@"Recent History" forState:UIControlStateNormal];
    [recentHistoryButton setTitleColor:componentTextColor forState:UIControlStateNormal];
    [recentHistoryButton setTitleColor:componentTextHighlightColor forState:UIControlStateHighlighted];
    recentHistoryButton.backgroundColor = componentBackgroundColor;
    [recentHistoryButton addTarget:self action:@selector(recentHistoryButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [accountView addSubview:recentHistoryButton];
    
    //Share Button
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(0, unitHeight*2, buttonWidth, unitHeight)];
    [shareButton setTitle:@"Share" forState:UIControlStateNormal];
    [shareButton setTitleColor:componentTextColor forState:UIControlStateNormal];
    [shareButton setTitleColor:componentTextHighlightColor forState:UIControlStateHighlighted];
    shareButton.backgroundColor = componentBackgroundColor;
    [shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [accountView addSubview:shareButton];
    
    
    //Delegate
//    _lastFMAccountInput.delegate = self;
//
//    self.username.text = [[PFUser currentUser] username];
//    [self updateInfo];
//    
//    //Update textfield
//    if(self.delegate && [self.delegate respondsToSelector:@selector(getLastFMAccount)]){
//        _lastFMAccountInput.text = [self.delegate getLastFMAccount];
//    }
}

- (void)recentHistoryButtonPressed
{
    listenedViewController = [[ListenedViewController alloc] initWithUsername:_username];
    listenedViewController.previousViewController = self;
    
    MMNavigationController *navigationAddFriendsViewController = [[MMNavigationController alloc] initWithRootViewController:listenedViewController];
    [self.mm_drawerController setCenterViewController:navigationAddFriendsViewController withCloseAnimation:YES completion:nil];
}
- (void)shareButtonPressed
{
    userShareViewController = [[UserShareViewController alloc] initWithUsername:_username];
    userShareViewController.previousViewController = self;
    
    MMNavigationController *navigationAddFriendsViewController = [[MMNavigationController alloc] initWithRootViewController:userShareViewController];
    [self.mm_drawerController setCenterViewController:navigationAddFriendsViewController withCloseAnimation:YES completion:nil];
}

#pragma mark - Button Handlers
-(void)setupMenuButton{
    //Navigation Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    NSString *titleText = _username;
    int titleLength = 8;
    if([titleText length] > titleLength) titleText = [[titleText substringToIndex:titleLength]  stringByAppendingString:@"..."];
    titleLabel.text = [NSString stringWithFormat:@"%@'s Profile", titleText];
    titleLabel.textColor = [UIColor colorWithRed:3.0/255.0
                                           green:49.0/255.0
                                            blue:107.0/255.0
                                           alpha:1.0];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [titleLabel sizeToFit];
    self.mm_drawerController.navigationItem.titleView = titleLabel;
    
    
	MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
	[self.mm_drawerController.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
    [self.mm_drawerController.navigationItem setRightBarButtonItem:nil];
}

-(void)leftDrawerButtonPress:(id)sender{
	[self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

#pragma mark - Call UserViewController Delegate
- (void)callUserViewController:(NSString*)input
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(setLastFMAccount:)]){
        [self.delegate setLastFMAccount:input];
    }
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //hide the keyboard
    [self callUserViewController:textField.text];
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
            [self callUserViewController:textField.text];
            [txt resignFirstResponder];
        }
    }
}

@end
