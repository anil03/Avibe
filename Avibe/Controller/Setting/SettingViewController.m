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
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)]];
    
    //BackgroundView
    UIView *backgroundView = [[BackgroundImageView alloc] initWithFrame:CGRectMake(0, 0, scrollWidth, scrollHeight)];
    [scrollView addSubview:backgroundView];
    [scrollView sendSubviewToBack:backgroundView];
    
    /*AccountView*/
    item = 4;
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
    textField = [[UITextField alloc] initWithFrame:CGRectMake(width/2, unitHeight, width/2-right, unitHeight)];
    textField.text = [[PFUser currentUser] username];
    textField.backgroundColor = contentBackgroundColor;
    textField.textAlignment = NSTextAlignmentRight;
    textField.delegate = self;
//    [textField addTarget:self action:@selector(changeUsername:) forControlEvents:UIControlEventEditingDidEnd];
    [accountView addSubview:textField];
    
    //Email
    contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, unitHeight*2, width/2, unitHeight)];
    contentLabel.backgroundColor = contentBackgroundColor;
    contentLabel.text = @" Email";
    contentLabel.textColor = contentTextColor;
    contentLabel.textAlignment = NSTextAlignmentNatural;
    [accountView addSubview:contentLabel];
    //Email Description
    textField = [[UITextField alloc] initWithFrame:CGRectMake(width/2, unitHeight*2, width/2-right, unitHeight)];
    textField.text = [[PFUser currentUser] objectForKey:kClassUserEmail];
    textField.backgroundColor = contentBackgroundColor;
    textField.textAlignment = NSTextAlignmentRight;
    textField.delegate = self;
    textField.adjustsFontSizeToFitWidth = YES;
    [textField addTarget:self action:@selector(changeEmail:) forControlEvents:UIControlEventEditingDidEnd];
    [accountView addSubview:textField];
    
    //Mobile#
    contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, unitHeight*3, width/2, unitHeight)];
    contentLabel.backgroundColor = contentBackgroundColor;
    contentLabel.text = @" Mobile#";
    contentLabel.textColor = contentTextColor;
    contentLabel.textAlignment = NSTextAlignmentNatural;
    [accountView addSubview:contentLabel];
    //Mobile# Description
    textField = [[UITextField alloc] initWithFrame:CGRectMake(width/2, unitHeight*3, width/2-right, unitHeight)];
    textField.text = [[PFUser currentUser] objectForKey:kClassUserPhoneNumber];
    textField.backgroundColor = contentBackgroundColor;
    textField.textAlignment = NSTextAlignmentRight;
    textField.delegate = self;
    [textField addTarget:self action:@selector(changePhoneNumber:) forControlEvents:UIControlEventEditingDidEnd];
    [accountView addSubview:textField];
    
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

#pragma mark - Textfield Method
- (void)changeUsername:(UITextField*)sender
{
    NSString *username = sender.text;
    
    PFQuery *query = [PFUser query];
    [query getObjectInBackgroundWithId:[[PFUser currentUser] objectId] block:^(PFObject *object, NSError *error) {
        if(object){
            [object setObject:username forKey:kClassUserUsername];
            [object saveEventually:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [[[UIAlertView alloc] initWithTitle: @"Success" message: [NSString stringWithFormat:@"You have changed username to %@.  Please sign in again to see the update.", username] delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }else if(error){
                    [[[UIAlertView alloc] initWithTitle: @"Error" message:[NSString stringWithFormat:@"You can't change to %@, please try another one", username] delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    sender.text = [[PFUser currentUser] username];
                }
            }];
        }
    }];
}
- (void)changeEmail:(UITextField*)sender
{
    NSString *email = sender.text;
    
    PFQuery *query = [PFUser query];
    [query getObjectInBackgroundWithId:[[PFUser currentUser] objectId] block:^(PFObject *object, NSError *error) {
        if(object){
            [object setObject:email forKey:kClassUserEmail];
            [object saveEventually:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [[[UIAlertView alloc] initWithTitle: @"Success" message: [NSString stringWithFormat:@"You have changed email address to %@. Please sign in again to see the update.", email] delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }else if(error){
                    [[[UIAlertView alloc] initWithTitle: @"Error" message:[NSString stringWithFormat:@"You can't change email address to %@, please try another one", email] delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    sender.text = [[PFUser currentUser] objectForKey:kClassUserEmail];
                }
            }];
        }
    }];
}
- (void)changePhoneNumber:(UITextField*)sender
{
    NSString *phoneNumber = sender.text;
    
    PFQuery *query = [PFUser query];
    [query getObjectInBackgroundWithId:[[PFUser currentUser] objectId] block:^(PFObject *object, NSError *error) {
        if(object){
            [object setObject:phoneNumber forKey:kClassUserPhoneNumber];
            [object saveEventually:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [[[UIAlertView alloc] initWithTitle: @"Success" message: [NSString stringWithFormat:@"You have changed phone number to %@. Please sign in again to see the update.", phoneNumber] delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }else if(error){
                    [[[UIAlertView alloc] initWithTitle: @"Error" message:[NSString stringWithFormat:@"You can't change phone number to %@, please try another one", phoneNumber] delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    sender.text = [[PFUser currentUser] objectForKey:kClassUserPhoneNumber];
                }
            }];
        }
    }];
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

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
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
- (void)hideKeyBoard
{
    for (UIView *view1 in self.view.subviews){
        for(UIView *view2 in view1.subviews){
            if ([view2 isKindOfClass:[UITextField class]] && [view2 isFirstResponder]) {
                UITextField *textField = (UITextField*)view2;
                [textField resignFirstResponder];
                return;
            }
        }
    }
}



@end
