//
//  SettingViewController.m
//  Beet
//
//  Created by Yuhua Mai on 12/28/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//
// CustomViewController

#import "SettingViewController.h"
#import "MMNavigationController.h"
#import "UIViewController+MMDrawerController.h"
#import "YoutubeAuthorizeViewController.h"
#import "Setting.h"
#import "PublicMethod.h"
#import "BackgroundImageView.h"
#import "MMDrawerBarButtonItem.h"

@interface SettingViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *lastFMAccountTextField;
@property (nonatomic, strong) UIBarButtonItem * rightDrawerButton;

/**
 * Change textfield value
 */
@property (nonatomic, strong) UITextField *currentSender;
@property (nonatomic, strong) UIAlertView *currentAlertView;
@property (nonatomic, strong) NSString *currentValueToChange;
@property (nonatomic, strong) NSString *currentKey;
@property (nonatomic, strong) NSString *currentType;

//Authorization Sources
@property (nonatomic, strong) YoutubeAuthorizeViewController *youtubeAuthorizeViewController;

@end

@implementation SettingViewController

- (void)viewWillAppear:(BOOL)animated
{
    [self setupBarMenuButton];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; //eliminate lines after last cell
    
//    //LastFM
//    _lastFMAccountTextField.delegate = self;
//    _lastFMAccountTextField.text = [[Setting sharedSetting] lastFMAccount];
//    
//    //View Parameters
//    UIColor *titleBackgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
//    UIColor *titleTextColor = [UIColor whiteColor];
//    UIColor *contentBackgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3];
//    UIColor *contentTextColor = [UIColor blackColor];
//    float barHeight = 15.0f;
//    float width = [[UIScreen mainScreen] bounds].size.width;
//    float height = [[UIScreen mainScreen] bounds].size.height;
//    float scrollWidth = width;
//    float scrollHeight = height*2;
//    float currentHeight = 0.0f;
//    float left = 5.0f;
//    float right = 5.0f;
//    float unitHeight = 30.0f;
//    int item = 15;
//    float totalHeight = unitHeight*item;
//
//    UIView *accountView;
//    UILabel *titleLabel;
//    UILabel *contentLabel;
//    UITextField *textField;
//    
//    //ScrollView
//    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
//    [scrollView setContentSize:CGSizeMake(320, 920)];
//    scrollView.userInteractionEnabled = YES;
//    [scrollView setScrollEnabled:YES];
//    self.view = scrollView;
//    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)]];
//    
//
//    
//    /*AccountView*/
//    item = 4;
//    currentHeight += barHeight;
//    accountView = [[UIView alloc] initWithFrame:CGRectMake(0, currentHeight, width, item*unitHeight)];
//    accountView.backgroundColor = contentBackgroundColor;
//    [scrollView addSubview:accountView];
//    //Title
//    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, unitHeight)];
//    titleLabel.backgroundColor = titleBackgroundColor;
//    titleLabel.text = @" My Avibe Account";
//    titleLabel.textColor = titleTextColor;
//    titleLabel.textAlignment = NSTextAlignmentNatural;
//    [accountView addSubview:titleLabel];
//    //User Name
//    contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, unitHeight, width/2, unitHeight)];
//    contentLabel.backgroundColor = contentBackgroundColor;
//    contentLabel.text = @" Username";
//    contentLabel.textColor = contentTextColor;
//    contentLabel.textAlignment = NSTextAlignmentNatural;
//    [accountView addSubview:contentLabel];
//    //User Name Description
//    textField = [[UITextField alloc] initWithFrame:CGRectMake(width/2, unitHeight, width/2-right, unitHeight)];
//    textField.text = [[PFUser currentUser] username];
//    textField.backgroundColor = contentBackgroundColor;
//    textField.textAlignment = NSTextAlignmentRight;
//    textField.delegate = self;
//    [textField addTarget:self action:@selector(changeUsername:) forControlEvents:UIControlEventEditingDidEnd];
//    [accountView addSubview:textField];
//    
//    //Email
//    contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, unitHeight*2, width/2, unitHeight)];
//    contentLabel.backgroundColor = contentBackgroundColor;
//    contentLabel.text = @" Email";
//    contentLabel.textColor = contentTextColor;
//    contentLabel.textAlignment = NSTextAlignmentNatural;
//    [accountView addSubview:contentLabel];
//    //Email Description
//    textField = [[UITextField alloc] initWithFrame:CGRectMake(width/2, unitHeight*2, width/2-right, unitHeight)];
//    textField.text = [[PFUser currentUser] objectForKey:kClassUserEmail];
//    textField.backgroundColor = contentBackgroundColor;
//    textField.textAlignment = NSTextAlignmentRight;
//    textField.delegate = self;
//    textField.adjustsFontSizeToFitWidth = YES;
//    [textField addTarget:self action:@selector(changeEmail:) forControlEvents:UIControlEventEditingDidEnd];
//    [accountView addSubview:textField];
//    
//    //Mobile#
//    contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, unitHeight*3, width/2, unitHeight)];
//    contentLabel.backgroundColor = contentBackgroundColor;
//    contentLabel.text = @" Mobile#";
//    contentLabel.textColor = contentTextColor;
//    contentLabel.textAlignment = NSTextAlignmentNatural;
//    [accountView addSubview:contentLabel];
//    //Mobile# Description
//    textField = [[UITextField alloc] initWithFrame:CGRectMake(width/2, unitHeight*3, width/2-right, unitHeight)];
//    textField.text = [[PFUser currentUser] objectForKey:kClassUserPhoneNumber];
//    textField.backgroundColor = contentBackgroundColor;
//    textField.textAlignment = NSTextAlignmentRight;
//    textField.delegate = self;
//    [textField addTarget:self action:@selector(changePhoneNumber:) forControlEvents:UIControlEventEditingDidEnd];
//    [accountView addSubview:textField];
//
//    /*OtherAccountView*/
//    currentHeight += item*unitHeight;
//    item = 4;
//    accountView = [[UIView alloc] initWithFrame:CGRectMake(0, currentHeight, width, item*unitHeight)];
//    accountView.backgroundColor = contentBackgroundColor;
//    [scrollView addSubview:accountView];
//    //Title
//    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, unitHeight)];
//    titleLabel.backgroundColor = titleBackgroundColor;
//    titleLabel.text = @" My Other Accounts";
//    titleLabel.textColor = titleTextColor;
//    titleLabel.textAlignment = NSTextAlignmentNatural;
//    [accountView addSubview:titleLabel];
//    //LastFM#
//    contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, unitHeight, width/2, unitHeight)];
//    contentLabel.backgroundColor = contentBackgroundColor;
//    contentLabel.text = @" LastFM Account";
//    contentLabel.textColor = contentTextColor;
//    contentLabel.textAlignment = NSTextAlignmentNatural;
//    [accountView addSubview:contentLabel];
//    //LastFM TextField
//    textField = [[UITextField alloc] initWithFrame:CGRectMake(width/2, unitHeight, width/2-right, unitHeight)];
//    textField.text = [[PFUser currentUser] objectForKey:kClassUserLastFM];
//    textField.backgroundColor = contentBackgroundColor;
//    textField.textAlignment = NSTextAlignmentRight;
//    textField.delegate = self;
//    [textField addTarget:self action:@selector(changeLastFM:) forControlEvents:UIControlEventEditingDidEnd];
//    [accountView addSubview:textField];
//    //Rdio
//    contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, unitHeight*2, width/2, unitHeight)];
//    contentLabel.backgroundColor = contentBackgroundColor;
//    contentLabel.text = @" Rdio Account";
//    contentLabel.textColor = contentTextColor;
//    contentLabel.textAlignment = NSTextAlignmentNatural;
//    [accountView addSubview:contentLabel];
//    //Rdio TextField
//    textField = [[UITextField alloc] initWithFrame:CGRectMake(width/2, unitHeight*2, width/2-right, unitHeight)];
//    textField.text = [[PFUser currentUser] objectForKey:kClassUserRdio];
//    textField.backgroundColor = contentBackgroundColor;
//    textField.textAlignment = NSTextAlignmentRight;
//    textField.delegate = self;
//    [textField addTarget:self action:@selector(changeRdio:) forControlEvents:UIControlEventEditingDidEnd];
//    [accountView addSubview:textField];
//    
//    //Youtube Fetch
//    UIButton *youtubeAccessButton = [[UIButton alloc] initWithFrame:CGRectMake(0,unitHeight*3,width/2,unitHeight)];
//    [youtubeAccessButton setBackgroundColor:contentBackgroundColor];
//    [youtubeAccessButton setTitle:@"Access Youtube" forState:UIControlStateNormal];
//    [youtubeAccessButton addTarget:self action:@selector(youtubeFetch) forControlEvents:UIControlEventTouchUpInside];
//    [accountView addSubview:youtubeAccessButton];
//    UIButton *youtubeRevokeButton = [[UIButton alloc] initWithFrame:CGRectMake(width/2,unitHeight*3,width/2,unitHeight)];
//    [youtubeRevokeButton setBackgroundColor:contentBackgroundColor];
//    [youtubeRevokeButton setTitle:@"Revoke Youtube" forState:UIControlStateNormal];
//    [youtubeRevokeButton addTarget:self action:@selector(youtubeRevoke) forControlEvents:UIControlEventTouchUpInside];
//    [accountView addSubview:youtubeRevokeButton];
//    
////    /*Feed Clogging*/
////    currentHeight += item*unitHeight;
////    item = 3;
////    accountView = [[UIView alloc] initWithFrame:CGRectMake(0, currentHeight, width, item*unitHeight)];
////    accountView.backgroundColor = contentBackgroundColor;
////    [scrollView addSubview:accountView];
////    //Title
////    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, unitHeight)];
////    titleLabel.backgroundColor = titleBackgroundColor;
////    titleLabel.text = @" Feed Clogging";
////    titleLabel.textColor = titleTextColor;
////    titleLabel.textAlignment = NSTextAlignmentNatural;
////    [accountView addSubview:titleLabel];
////    
////    /*Other Setting*/
////    currentHeight += item*unitHeight;
////    item = 3;
////    accountView = [[UIView alloc] initWithFrame:CGRectMake(0, currentHeight, width, item*unitHeight)];
////    accountView.backgroundColor = contentBackgroundColor;
////    [scrollView addSubview:accountView];
////    //Title
////    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, unitHeight)];
////    titleLabel.backgroundColor = titleBackgroundColor;
////    titleLabel.text = @" Others";
////    titleLabel.textColor = titleTextColor;
////    titleLabel.textAlignment = NSTextAlignmentNatural;
////    [accountView addSubview:titleLabel];
////
//    
//    /*Finally*/
//    currentHeight += item*unitHeight;
//    [scrollView setContentSize:CGSizeMake(scrollWidth, currentHeight)];
//
//    //BackgroundView
//    if (currentHeight < height) {
//        currentHeight = height;
//    }
    UIView *backgroundView = [[BackgroundImageView alloc] initWithFrame:self.tableView.frame];
    [self.tableView setBackgroundView:backgroundView];
//    [scrollView addSubview:backgroundView];
//    [scrollView sendSubviewToBack:backgroundView];
}

#pragma mark - UITableView DataSource
typedef NS_ENUM(NSInteger, SettingSection){
    AvibeAccount,
    LinkedAccount
};
typedef NS_ENUM(NSInteger, SettingRowInAvibeAccountSection){
    Username,
    Email,
    PhoneNumber
};
typedef NS_ENUM(NSInteger, SettingRowInLinkedAccountSection){
    Scrobble,
    Rdio,
    Youtube,
    Facebook
};
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case AvibeAccount:
            return 3;
        case LinkedAccount:
            return 4;
        default:
            return 2;
    }
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
//        case AvibeAccount:
//            return @"Avibe Account";
//        case LinkedAccount:
//            return @"Linked Account";
        default:
            return @"";
    }
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 8, 320, 20);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
//    label.shadowColor = [UIColor grayColor];
//    label.shadowOffset = CGSizeMake(-1.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = sectionTitle;
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    return view;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor lightGrayColor];
    bgColorView.layer.cornerRadius = 7;
    bgColorView.layer.masksToBounds = YES;
    [cell setSelectedBackgroundView:bgColorView];
    
    if (indexPath.section == AvibeAccount) {
        switch (indexPath.row) {
            case Username:
                cell.textLabel.text = @"Username";
                cell.detailTextLabel.text = [[PFUser currentUser] username];
                break;
            case Email:
                cell.textLabel.text = @"Email";
                cell.detailTextLabel.text = [[PFUser currentUser] objectForKey:kClassUserEmail];
                break;
            case PhoneNumber:
                cell.textLabel.text = @"Phone Number";
                cell.detailTextLabel.text = [[PFUser currentUser] objectForKey:kClassUserPhoneNumber];
                break;
            default:
                break;
        }
    }else if (indexPath.section == LinkedAccount){
        switch (indexPath.row) {
            case Scrobble:
                cell.textLabel.text = @"Scrobble";
                cell.detailTextLabel.text = @"detail";
                break;
            case Rdio:
                cell.textLabel.text = @"Rdio";
                cell.detailTextLabel.text = @"detail";
                break;
            case Youtube:
                cell.textLabel.text = @"Youtube";
                cell.detailTextLabel.text = @"detail";
                break;
            case Facebook:
                cell.textLabel.text = @"Facebook";
                cell.detailTextLabel.text = @"detail";
                break;
            default:
                break;
        }

    }
    
    return cell;
}


- (void)youtubeFetch
{
    _youtubeAuthorizeViewController = [[YoutubeAuthorizeViewController alloc] init];
    _youtubeAuthorizeViewController.previousViewController = self;
    
    MMNavigationController *navigationAddFriendsViewController = [[MMNavigationController alloc] initWithRootViewController:_youtubeAuthorizeViewController];
    [self.mm_drawerController setCenterViewController:navigationAddFriendsViewController withCloseAnimation:YES completion:nil];
    
    //    [[PublicMethod sharedInstance] authorizeGoogle:self.view];

}
- (void)youtubeRevoke
{
    [[PublicMethod sharedInstance] revokeAccess];
}

#pragma mark - Textfield Method


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView isEqual:_currentAlertView] && buttonIndex == 0) {
        PFQuery *query = [PFUser query];
        [query getObjectInBackgroundWithId:[[PFUser currentUser] objectId] block:^(PFObject *object, NSError *error) {
            if(object){
                [object setObject:_currentValueToChange forKey:_currentKey];
                [object saveEventually:^(BOOL succeeded, NSError *error) {
                    NSString *warningString;
                    if (succeeded) {
                        warningString = [NSString stringWithFormat:@"You have successfully changed %@ to %@.  Please log in again to see the update.", _currentType, _currentValueToChange];
                        if([_currentValueToChange length] == 0){
                            warningString = [NSString stringWithFormat:@"You have successfully deleted %@. Please log in again to see the update.", _currentType];
                        }

                        [[[UIAlertView alloc] initWithTitle: @"Success" message: warningString delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    }else if(error){
                        warningString = [NSString stringWithFormat:@"You can't change %@ to %@, please try another one.", _currentType,_currentValueToChange];
                        if([_currentValueToChange length] == 0){
                            warningString = [NSString stringWithFormat:@"You can't deleted %@.", _currentType];
                        }
                        
                        [[[UIAlertView alloc] initWithTitle: @"Error" message:warningString delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                        _currentSender.text = [[PFUser currentUser] objectForKey: _currentKey];
                    }
                }];
            }
        }];
    }else if([alertView isEqual:_currentAlertView] && buttonIndex == 1){
        _currentSender.text = [[PFUser currentUser] objectForKey: _currentKey];
    }
    
    //Restore DONE action
    _rightDrawerButton.action = @selector(popCurrentView);
}
- (void)disableBarItem
{
    //Disable DONE to avoid killing current controller by mistake
    _rightDrawerButton.action = nil;
}
- (void)changeTextField
{
    //Ignore if user not change
    if([_currentValueToChange isEqualToString:[[PFUser currentUser] objectForKey:kClassUserUsername]]){
        _currentSender.text = [[PFUser currentUser] objectForKey: _currentKey];
        return;
    }
    //Change to nil
    NSString *warningString = [NSString stringWithFormat:@"Are you sure to change %@ to %@?", _currentType, _currentValueToChange];
    if([_currentValueToChange length] == 0){
        warningString = [NSString stringWithFormat:@"Are you sure to delete %@?", _currentType];
    }
    
    _currentAlertView = [[UIAlertView alloc] initWithTitle: @"Warning" message:warningString  delegate: self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
    [_currentAlertView show];
}
- (void)changeUsername:(UITextField*)sender
{
    _currentValueToChange = sender.text;
    _currentKey = kClassUserUsername;
    _currentSender = sender;
    _currentType = @"User Name";
    [self changeTextField];
}
- (void)changeEmail:(UITextField*)sender
{
    _currentValueToChange = sender.text;
    _currentKey = kClassUserEmail;
    _currentSender = sender;
    _currentType = @"Email";
    [self changeTextField];
}
- (void)changePhoneNumber:(UITextField*)sender
{
    _currentValueToChange = sender.text;
    _currentKey = kClassUserPhoneNumber;
    _currentSender = sender;
    _currentType = @"Phone Number";
    [self changeTextField];
}
- (void)changeLastFM:(UITextField*)sender
{
    _currentValueToChange = sender.text;
    _currentKey = kClassUserLastFM;
    _currentSender = sender;
    _currentType = @"LastFM Account";
    [self changeTextField];
}
- (void)changeRdio:(UITextField*)sender
{
    _currentValueToChange = sender.text;
    _currentKey = kClassUserRdio;
    _currentSender = sender;
    _currentType = @"Rdio Account";
    [self changeTextField];
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
    
    
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
	[self.mm_drawerController.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
    [self.mm_drawerController.navigationItem setRightBarButtonItem:nil];
}
-(void)leftDrawerButtonPress:(id)sender{
	[self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}



#pragma mark - UITextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self disableBarItem];
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    //Restore DONE action
    _rightDrawerButton.action = @selector(popCurrentView);
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //hide the keyboard
    [textField resignFirstResponder];
    
    //return NO or YES, it doesn't matter
    return YES;
}


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
