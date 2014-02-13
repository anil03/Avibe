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
#import "NSString+MD5.h"
#import "ScrobbleAuthorizeViewController.h"
#import "RdioAuthorizeViewController.h"
#import "YoutubeAuthorizeViewController.h"
#import "FacebookAuthorizeViewController.h"

#import "Setting.h"
#import "PublicMethod.h"
#import "BackgroundImageView.h"
#import "MMDrawerBarButtonItem.h"

@interface SettingViewController () <UITextFieldDelegate, UIAlertViewDelegate, GoogleOAuthDelegate, FBLoginViewDelegate>

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

//UIAlertview - Avibe Account
@property NSString *valueToChange;
@property NSString *classToChange;

@property UIAlertView *displayNameAlertView;
@property UIAlertView *displayNameConfirmAlertView;
@property UIAlertView *emailAlertView;
@property UIAlertView *emailConfirmAlertView;
@property UIAlertView *phoneNumberAlertView;
@property UIAlertView *phoneNumberConfirmAlertView;
//UIAlertview - Linked Account
//LastFM
@property UIAlertView *scrobbleAlertView;
@property UIAlertView *scrobbleRevokeAlertView;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSURLConnection *urlConnection;
@property BOOL lastFMAuthorizationSucceed;
//Rdio
@property UIAlertView *rdioAlertView;
//Youtube
@property UIAlertView *youtubeConfirmAlertView;
@property BOOL youtubeAuthorized;
//Facebook
@property UIAlertView *facebookAlertView;
@property FBLoginView *facebookLoginView;
@property UILabel *facebookLoginLabel;
@property NSString *facebookCellString;
@property UIColor *facebookCellColor;

//Authorization Sources
@property (nonatomic, strong) ScrobbleAuthorizeViewController *scrobbleAuthorizeViewController;
@property (nonatomic, strong) RdioAuthorizeViewController *rdioAuthorizeViewController;
@property (nonatomic, strong) YoutubeAuthorizeViewController *youtubeAuthorizeViewController;
@property (nonatomic, strong) FacebookAuthorizeViewController *facebookAuthorizeViewController;

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
    
    //LastFM
    _receivedData = [[NSMutableData alloc] init];
    _urlConnection = [[NSURLConnection alloc] init];
    
    //Youtube
    _youtubeAuthorized = NO;
    _youtubeAuthorizeViewController = [[YoutubeAuthorizeViewController alloc] init];
    _youtubeAuthorizeViewController.previousViewController = self;
    [_youtubeAuthorizeViewController setGOAuthDelegate:self];
    [self authorizeGoogle:nil];
    
    
    //Facebook
//    _facebookLoginView
    
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
    DisplayName,
    Email,
    PhoneNumber
};
typedef NS_ENUM(NSInteger, SettingRowInLinkedAccountSection){
    Youtube,
    Facebook,
    Scrobble,
    Rdio
};
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case AvibeAccount:
            return 4;
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
    
    UIColor *uicolor = [UIColor lightGrayColor];
    CGColorRef color = [uicolor CGColor];
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor clearColor];
    bgColorView.layer.borderColor = color;
    bgColorView.layer.borderWidth = 1;
    bgColorView.layer.cornerRadius = 7;
    bgColorView.layer.masksToBounds = YES;
    [cell setSelectedBackgroundView:bgColorView];
    
    if (indexPath.section == AvibeAccount) {
        switch (indexPath.row) {
            case Username:
                cell.textLabel.text = @"Username";
                cell.detailTextLabel.text = [[PFUser currentUser] username];
                break;
            case DisplayName:
                cell.textLabel.text = @"Full Name";
                cell.detailTextLabel.text = [[PFUser currentUser] objectForKey:kClassUserDisplayname];
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
            case Scrobble:{
                cell.textLabel.text = @"Last.fm";
                NSString *lastFMUser = [[PFUser currentUser] objectForKey:kClassUserLastFM];
                cell.detailTextLabel.text = lastFMUser? [lastFMUser stringByAppendingString:@"✓"] : @"Unauthorized✗";
                cell.detailTextLabel.textColor = lastFMUser? [UIColor redColor] : [UIColor grayColor];
                }
                break;
            case Rdio:
                cell.backgroundColor = [UIColor grayColor];
                cell.textLabel.text = @"Rdio";
                cell.detailTextLabel.text = @"detail";
                break;
            case Youtube:
                cell.textLabel.text = @"YouTube";
                cell.detailTextLabel.text = _youtubeAuthorized? @"Authorized✓" : @"Unauthorized✗";
                cell.detailTextLabel.textColor = _youtubeAuthorized? [UIColor redColor] : [UIColor grayColor];
                break;
            case Facebook:{
                [self customizeFacebookLoginView:cell.frame];
                assert(_facebookLoginView != nil);
                assert(_facebookLoginLabel != nil);
                [cell addSubview:_facebookLoginView];
                [cell bringSubviewToFront:_facebookLoginView];
                
                
                BOOL facebookLogIn = NO;
                NSString *facebookUser = [[PFUser currentUser] objectForKey:kClassUserFacebook];
                if([_facebookLoginLabel.text rangeOfString:@"out"].location != NSNotFound) facebookLogIn = YES;
                cell.textLabel.text = @"Facebook";
                cell.detailTextLabel.text = facebookLogIn? [facebookUser stringByAppendingString:@"✓"] : @"Unauthorized✗";
                cell.detailTextLabel.textColor = facebookLogIn? [UIColor redColor] : [UIColor grayColor];

;
                
                break;
            }
            default:
                break;
        }

    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == AvibeAccount) {
        switch (indexPath.row) {
            case DisplayName:
                [self displaynameSelected];
                break;
            case Email:
                [self emailSelected];
                break;
            case PhoneNumber:
                [self phoneNumberSelected];
                break;
            default:
                break;
        }
    }else if (indexPath.section == LinkedAccount){
        switch (indexPath.row) {
            case Scrobble:
                [self scrobbleAuthorize];
                break;
            case Rdio:
                [self rdioAuthorize];
                break;
            case Youtube:
                [self youtubeAuthorize];
                break;
            case Facebook:
//                [self facebookAuthorize];
                break;
            default:
                break;
        }
        
    }
}
#pragma mark - Cell selected method for Avibe account
- (void)displaynameSelected
{
    _displayNameAlertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please enter the full name you want to change." delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    _displayNameAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [_displayNameAlertView show];
}
- (void)emailSelected
{
    _emailAlertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please enter the email you want to change." delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    _emailAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [_emailAlertView show];
}
- (void)phoneNumberSelected
{
    _phoneNumberAlertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please enter the phone number you want to change." delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    _phoneNumberAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [_phoneNumberAlertView show];
}

#pragma mark - AlertView Method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Display Name
    if([alertView isEqual:_displayNameAlertView] && buttonIndex == 0) {
        _classToChange = kClassUserDisplayname;
        
        NSString *string = [alertView textFieldAtIndex:0].text;
        if (!string || [string isEqualToString:@""] || [string isEqualToString:[[PFUser currentUser] objectForKey:_classToChange]]) {
            [self warnEmptyInput];
            return;
        }
        
        _valueToChange = string;
        
        
        _displayNameConfirmAlertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:[@"Are you sure to change full name to: " stringByAppendingString:string] delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        _displayNameConfirmAlertView.alertViewStyle = UIAlertViewStyleDefault;
        [_displayNameConfirmAlertView show];
    }
    if ([alertView isEqual:_displayNameConfirmAlertView] && buttonIndex == 0){
        PFQuery *query = [PFUser query];
        [query getObjectInBackgroundWithId:[[PFUser currentUser] objectId] target:self selector:@selector(changePFUser:error:)];
    }
    
    
    //Email
    if([alertView isEqual:_emailAlertView] && buttonIndex == 0) {
        _classToChange = kClassUserEmail;

        NSString *string = [alertView textFieldAtIndex:0].text;
        if (!string || [string isEqualToString:@""] || [string isEqualToString:[[PFUser currentUser] objectForKey:_classToChange]]) {
            [self warnEmptyInput];
            return;
        }
        
        _valueToChange = string;
        
        _emailConfirmAlertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:[@"Are you sure to change email to: " stringByAppendingString:string] delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        _emailConfirmAlertView.alertViewStyle = UIAlertViewStyleDefault;
        [_emailConfirmAlertView show];
    }
    if ([alertView isEqual:_emailConfirmAlertView] && buttonIndex == 0){
        PFQuery *query = [PFUser query];
        [query getObjectInBackgroundWithId:[[PFUser currentUser] objectId] target:self selector:@selector(changePFUser:error:)];
    }
    
    //Phone number
    if([alertView isEqual:_phoneNumberAlertView] && buttonIndex == 0) {
        _classToChange = kClassUserPhoneNumber;
        
        NSString *string = [alertView textFieldAtIndex:0].text;
        if (!string || [string isEqualToString:@""] || [string isEqualToString:[[PFUser currentUser] objectForKey:_classToChange]]) {
            [self warnEmptyInput];
            return;
        }
        
        _valueToChange = string;
        
        _phoneNumberConfirmAlertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:[@"Are you sure to change phone number to: " stringByAppendingString:string] delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        _phoneNumberConfirmAlertView.alertViewStyle = UIAlertViewStyleDefault;
        [_phoneNumberConfirmAlertView show];
    }
    if ([alertView isEqual:_phoneNumberConfirmAlertView] && buttonIndex == 0){
        PFQuery *query = [PFUser query];
        [query getObjectInBackgroundWithId:[[PFUser currentUser] objectId] target:self selector:@selector(changePFUser:error:)];
    }
    
    
    //LastFM
    if ([alertView isEqual:_scrobbleAlertView] && buttonIndex == 0){
        assert(alertView.alertViewStyle == UIAlertViewStyleLoginAndPasswordInput);
        NSString *username = [alertView textFieldAtIndex:0].text;
        NSString *passwrod = [alertView textFieldAtIndex:1].text;
        
        [self makePostRequestToGetMobileSession:username password:passwrod];
    }
    if ([alertView isEqual:_scrobbleRevokeAlertView] && buttonIndex == 0){
        PFQuery *query = [PFUser query];
        [query getObjectInBackgroundWithId:[[PFUser currentUser] objectId] block:^(PFObject *object, NSError *error) {
            if (object) {
                [object removeObjectForKey:kClassUserLastFM];
                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        [[[UIAlertView alloc] initWithTitle: @"Congratulations" message: @"LastFM authorization has been revoked." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                        [[PFUser currentUser] refresh];
                        [self.tableView reloadData];
                    }else{
                        [self authorizeFailed];
                    }
                }];
            }
        }];
    }
    
    //Youtube
    if ([alertView isEqual:_youtubeConfirmAlertView] && buttonIndex == 0){
        [self revokeAccess];
    }
    
}
- (void)warnEmptyInput
{
    [[[UIAlertView alloc] initWithTitle:@"Ooops" message:@"Your input is not correct, please try agian." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}
- (void)authorizeFailed
{
    [[[UIAlertView alloc] initWithTitle: @"Oooops" message: @"Something wrong happens, please try later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}
#pragma mark - Change Parse PFUser field
- (void)changePFUser:(PFObject*)object error:(NSError*)error
{
    if (_valueToChange) {
        [object setObject:_valueToChange forKey:_classToChange];
        [object saveEventually:^(BOOL succeeded, NSError *error) {
            [self objectSaveResult:succeeded];
        }];
    }
}
- (void)objectSaveResult:(BOOL)succeeded
{
    if (succeeded) {
        [[PFUser currentUser] refresh];
        [[[UIAlertView alloc] initWithTitle: @"Congratulations" message: @"Save successfully!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [self.tableView reloadData];
    }else{
        [[[UIAlertView alloc] initWithTitle: @"Oops" message: @"Save not finish. Please try later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

#pragma mark - TableViewcell selected method for linked account
- (void)scrobbleAuthorize
{
    NSString *lastFMAccount = [[PFUser currentUser] objectForKey:kClassUserLastFM];
    if (lastFMAccount == nil || [lastFMAccount isEqualToString:@""]) {
        _scrobbleAlertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please enter username and password to authorize with Last.fm." delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        _scrobbleAlertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        [_scrobbleAlertView show];
    }else{
        _scrobbleRevokeAlertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Are you sure to revoke Last.fm authorization?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        _scrobbleRevokeAlertView.alertViewStyle = UIAlertViewStyleDefault;
        [_scrobbleRevokeAlertView show];
    }
    
//
//    
//    _scrobbleAuthorizeViewController = [[ScrobbleAuthorizeViewController alloc] init];
//    _scrobbleAuthorizeViewController.previousViewController = self;
//    
//    MMNavigationController *navigationAddFriendsViewController = [[MMNavigationController alloc] initWithRootViewController:_scrobbleAuthorizeViewController];
//    [self.mm_drawerController setCenterViewController:navigationAddFriendsViewController withCloseAnimation:YES completion:nil];
}
- (void)rdioAuthorize
{
    _rdioAuthorizeViewController = [[RdioAuthorizeViewController alloc] init];
    _rdioAuthorizeViewController.previousViewController = self;
    
    MMNavigationController *navigationAddFriendsViewController = [[MMNavigationController alloc] initWithRootViewController:_rdioAuthorizeViewController];
    [self.mm_drawerController setCenterViewController:navigationAddFriendsViewController withCloseAnimation:YES completion:nil];
}
- (void)youtubeAuthorize
{
    if (!_youtubeAuthorized) {
        _youtubeAuthorizeViewController = [[YoutubeAuthorizeViewController alloc] init];
        _youtubeAuthorizeViewController.previousViewController = self;
        [_youtubeAuthorizeViewController setGOAuthDelegate:self];
    }
    
    if (!_youtubeAuthorized) {
        MMNavigationController *navigationAddFriendsViewController = [[MMNavigationController alloc] initWithRootViewController:_youtubeAuthorizeViewController];
        [self.mm_drawerController setCenterViewController:navigationAddFriendsViewController withCloseAnimation:YES completion:nil];
        
        
        [self authorizeGoogle:nil];
    }else{
        _youtubeConfirmAlertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Are you sure to revoke Youtube authorization" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        [_youtubeConfirmAlertView show];
    }
    
}
- (void)youtubeRevoke
{
    [[PublicMethod sharedInstance] revokeAccess];
}
- (void)facebookAuthorize
{
    _facebookAuthorizeViewController = [[FacebookAuthorizeViewController alloc] init];
    _facebookAuthorizeViewController.previousViewController = self;
    
    MMNavigationController *navigationAddFriendsViewController = [[MMNavigationController alloc] initWithRootViewController:_facebookAuthorizeViewController];
    [self.mm_drawerController setCenterViewController:navigationAddFriendsViewController withCloseAnimation:YES completion:nil];
    
//    NSArray *permissionsNeeded = @[@"user_actions.music"];
//    
//    // Request the permissions the user currently has
//    [FBRequestConnection startWithGraphPath:@"/me/permissions"
//                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                              if (!error){
//                                  // These are the current permissions the user has
//                                  NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
//                                  
//                                  // We will store here the missing permissions that we will have to request
//                                  NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:@[]];
//                                  
//                                  // Check if all the permissions we need are present in the user's current permissions
//                                  // If they are not present add them to the permissions to be requested
//                                  for (NSString *permission in permissionsNeeded){
//                                      if (![currentPermissions objectForKey:permission]){
//                                          [requestPermissions addObject:permission];
//                                      }
//                                  }
//                                  
//                                  // If we have permissions to request
//                                  if ([requestPermissions count] > 0){
//                                      [FBSession.activeSession
//                                       requestNewReadPermissions:requestPermissions
//                                       completionHandler:^(FBSession *session, NSError *error) {
//                                           if (!error) {
//                                               // Permission granted, we can request the user information
////                                               [self makeMusicHistoryRequest];
//                                           } else {
//                                               // An error occurred, we need to handle the error
//                                               // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
//                                               NSLog(@"error %@", error.description);
//                                           }
//                                       }];
//                                  } else {
//                                      // Permissions are present
//                                      // We can request the user information
////                                      [self makeMusicHistoryRequest];
//                                  }
//                                  
//                              } else {
//                                  // An error occurred, we need to handle the error
//                                  // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
//                                  NSLog(@"error %@", error.description);
//                              }
//                          }];

    
}




#pragma mark - Last.fm Authorization
- (void)makePostRequestToGetMobileSession:(NSString*)username password:(NSString*)password
{
    //api_keyxxxxxxxxmethodauth.getMobileSessionpasswordxxxxxxxusernamexxxxxxxx
    //    Ensure your parameters are utf8 encoded. Now append your secret to this string.
    NSString *api_key = @"862a61374f83fe58088571f3134b88bc";
    NSString *method = @"auth.getMobileSession";
    NSString *secret = @"a5bfdfebc2ef66b04984d78c116b88fb";
    NSString *md5String = [NSString stringWithFormat:@"api_key%@method%@password%@username%@%@", api_key,method,password,username,secret];
    
    NSString *sig = [md5String MD5];
//    NSLog(@"%@ %@", md5String, sig);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://ws.audioscrobbler.com/2.0/"]];
    [request setHTTPMethod:@"POST"];
    NSString *postParams = [NSString stringWithFormat: @"api_key=862a61374f83fe58088571f3134b88bc&format=json&method=auth.getMobileSession&password=1989723&username=myhgew&api_sig=%@",sig];
    [request setHTTPBody:[postParams dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [self makeRequest:request];
}
-(void)makeRequest:(NSMutableURLRequest *)request{
    // Set the length of the _receivedData mutableData object to zero.
    [_receivedData setLength:0];
    
    // Make the request.
    _urlConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if (_lastFMAuthorizationSucceed) {
        NSString *responseJSON;
        responseJSON = [[NSString alloc] initWithData:(NSData *)_receivedData encoding:NSUTF8StringEncoding];
        //    NSLog(responseJSON);
        
        NSError* error = nil;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:(NSData *)_receivedData
                              options:kNilOptions
                              error:&error];
        NSMutableDictionary *session = [json objectForKey:@"session"];
        NSString *name = [session objectForKey:@"name"];
        NSString *key = [session objectForKey:@"key"];
        //    NSLog(@"%@ %@", name, key);
        
        if (name && key) {
            [self lastFMAuthorizeSucceed:name];
        }else{
            [self authorizeFailed];
        }
    }else{
        [self authorizeFailed];
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    // Append any new data to the _receivedData object.
    [_receivedData appendData:data];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSLog(@"%d", [httpResponse statusCode]);
    
    //200 means successful
    if ([httpResponse statusCode] == 200) {
        _lastFMAuthorizationSucceed = YES;
    }else{
        _lastFMAuthorizationSucceed = NO;
    }
}
- (void)lastFMAuthorizeSucceed:(NSString*)username
{
    PFQuery *query = [PFUser query];
    [query getObjectInBackgroundWithId:[[PFUser currentUser] objectId] block:^(PFObject *object, NSError *error) {
        if (object) {
            [object setObject:username forKey:kClassUserLastFM];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [[[UIAlertView alloc] initWithTitle: @"Congratulations" message: @"LastFM authorized successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    [[PFUser currentUser] refresh];
                    [self.tableView reloadData];
                }else{
                    [self authorizeFailed];
                }
            }];
        }
    }];
}


#pragma mark - Google OAuth
- (void)authorizeGoogle:(UIView*)view {
    //    [_googleOAuth authorizeUserWithClienID:@"746869634473-hl2v6kv6e65r1ak0u6uvajdl5grrtsgb.apps.googleusercontent.com"
    //                           andClientSecret:@"_FsYBVXMeUD9BGzNmmBvE9Q4"
    //                             andParentView:self.view
    //                                 andScopes:[NSArray arrayWithObjects:@"https://www.googleapis.com/auth/userinfo.profile", nil]
    //     ];
    [self.youtubeAuthorizeViewController authorizeUserWithClienID:@"4881560502-uteihtgcnas28bcjmnh0hfrbk4chlmsa.apps.googleusercontent.com"
                               andClientSecret:@"R02t8Pk-59eEYy-B359-gvOY"
                                 andParentView:view
                                     andScopes:[NSArray arrayWithObjects:@"https://www.googleapis.com/auth/youtube", @"https://www.googleapis.com/auth/youtube.readonly",@"https://www.googleapis.com/auth/youtubepartner",@"https://www.googleapis.com/auth/youtubepartner-channel-audit", nil]
     ];
}
- (void)revokeAccess{
    [self.youtubeAuthorizeViewController revokeAccessToken];
}

-(void)authorizationWasSuccessful{
    _youtubeAuthorized = YES;
    [self.tableView reloadData];
    
//    [self.youtubeAuthorizeViewController callAPI:@"https://www.googleapis.com/youtube/v3/channels"
//               withHttpMethod:httpMethod_GET
//           postParameterNames:[NSArray arrayWithObjects:@"part",@"mine",nil] postParameterValues:[NSArray arrayWithObjects:@"contentDetails",@"true",nil]];
    
    //    [_googleOAuth callAPI:@"https://www.googleapis.com/oauth2/v1/userinfo"
    //           withHttpMethod:httpMethod_GET
    //       postParameterNames:nil postParameterValues:nil];
}
-(void)accessTokenWasRevoked{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"Your access was revoked!"
                                                   delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    
    _youtubeAuthorized = NO;
    [self.tableView reloadData];
}
-(void)errorOccuredWithShortDescription:(NSString *)errorShortDescription andErrorDetails:(NSString *)errorDetails{
    NSLog(@"%@", errorShortDescription);
    NSLog(@"%@", errorDetails);
}
-(void)errorInResponseWithBody:(NSString *)errorMessage{
    NSLog(@"%@", errorMessage);
}
-(void)responseFromServiceWasReceived:(NSString *)responseJSONAsString andResponseJSONAsData:(NSData *)responseJSONAsData{
    NSError *error;
    NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseJSONAsData
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:&error];
    if (error) {
        NSLog(@"An error occured while converting JSON data to dictionary.");
        return;
    }
    NSLog(@"%@", dictionary);
    
    NSString *kind = [dictionary objectForKey:@"kind"];
    if ([kind rangeOfString:@"channelListResponse"].location != NSNotFound){
        NSMutableArray *items = [dictionary objectForKey:@"items"];
        NSMutableDictionary *contentDetails = [items[0] objectForKey:@"contentDetails"];
        NSMutableDictionary *relatedPlaylists = [contentDetails objectForKey:@"relatedPlaylists"];
        //likes, uploads, watchHistory, favorites, watchLater
        NSString *watchHistory = [relatedPlaylists objectForKey:@"watchHistory"];
        NSLog(@"WatchHistory playListID:%@", watchHistory);
        
        //Get playlist items
        [self.youtubeAuthorizeViewController callAPI:@"https://www.googleapis.com/youtube/v3/playlistItems"
                   withHttpMethod:httpMethod_GET
               postParameterNames:[NSArray arrayWithObjects:@"part",@"playlistId",nil] postParameterValues:[NSArray arrayWithObjects:@"snippet",watchHistory,nil]];
        
    }
    
    if ([kind rangeOfString:@"playlistItemListResponse"].location != NSNotFound) {
        NSMutableArray *items = [dictionary objectForKey:@"items"];
        NSMutableArray *entries = [[NSMutableArray alloc] init];
        
        for(NSMutableDictionary *item in items){
            NSMutableDictionary *snippet = [item objectForKey:@"snippet"];
            //Snippet: desciption, thumbnails, publishedAt, channelTitle, playlistId, channelId, resourceId, title
            NSString *title = [snippet objectForKey:@"title"];
            //Thumbnails
            NSMutableDictionary *thumbnails = [snippet objectForKey:@"thumbnails"];
            NSMutableDictionary *high = [thumbnails objectForKey:@"high"];
            NSString *thumbnailHighURL = [high objectForKey:@"url"];
            
            NSLog(@"Title:%@, ThumbnailUrl:%@", title, thumbnailHighURL);
            
            //Save to Parse
            NSMutableDictionary *entry = [[NSMutableDictionary alloc] init];
            [entry setObject:title forKey:@"title"];
            [entry setObject:thumbnailHighURL forKey:@"url"];
            [entries addObject:entry];
        }
        
//        [SaveMusicFromSources saveYoutubeEntry:entries];
    }
}


#pragma mark - Facebook login
- (void)customizeFacebookLoginView:(CGRect)frame
{
    if (!_facebookLoginView) {
        _facebookLoginView = [[FBLoginView alloc] init];
        //        [[FBLoginView alloc] initWithPermissions:[NSArray arrayWithObject:@"publish_actions"]];
    }
    
    _facebookLoginView.frame = frame;
    for (id obj in _facebookLoginView.subviews)
    {
        if ([obj isKindOfClass:[UIButton class]])
        {
            UIButton * loginButton =  obj;
            [loginButton setBackgroundImage:nil forState:UIControlStateNormal];
        }
        if ([obj isKindOfClass:[UILabel class]])
        {
            UILabel * loginLabel =  obj;
            _facebookLoginLabel = loginLabel;
            [loginLabel setHidden:YES];
        }
    }
    
    _facebookLoginView.delegate = self;
}
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    [self.tableView reloadData];
}
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    [self.tableView reloadData];
}
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    PFQuery *query = [PFUser query];
    [query getObjectInBackgroundWithId:[[PFUser currentUser] objectId] block:^(PFObject *object, NSError *error) {
        if (object) {
            [object setObject:[user name]  forKey:kClassUserFacebook];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
//                    [[[UIAlertView alloc] initWithTitle: @"Congratulations" message: @"Facebook authorized successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    [[PFUser currentUser] refresh];
                    [self.tableView reloadData];
                }else{
                    [self authorizeFailed];
                }
            }];
        }
    }];
}

#pragma mark - Textfield Method


//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if ([alertView isEqual:_currentAlertView] && buttonIndex == 0) {
//        PFQuery *query = [PFUser query];
//        [query getObjectInBackgroundWithId:[[PFUser currentUser] objectId] block:^(PFObject *object, NSError *error) {
//            if(object){
//                [object setObject:_currentValueToChange forKey:_currentKey];
//                [object saveEventually:^(BOOL succeeded, NSError *error) {
//                    NSString *warningString;
//                    if (succeeded) {
//                        warningString = [NSString stringWithFormat:@"You have successfully changed %@ to %@.  Please log in again to see the update.", _currentType, _currentValueToChange];
//                        if([_currentValueToChange length] == 0){
//                            warningString = [NSString stringWithFormat:@"You have successfully deleted %@. Please log in again to see the update.", _currentType];
//                        }
//
//                        [[[UIAlertView alloc] initWithTitle: @"Success" message: warningString delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//                    }else if(error){
//                        warningString = [NSString stringWithFormat:@"You can't change %@ to %@, please try another one.", _currentType,_currentValueToChange];
//                        if([_currentValueToChange length] == 0){
//                            warningString = [NSString stringWithFormat:@"You can't deleted %@.", _currentType];
//                        }
//                        
//                        [[[UIAlertView alloc] initWithTitle: @"Error" message:warningString delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//                        _currentSender.text = [[PFUser currentUser] objectForKey: _currentKey];
//                    }
//                }];
//            }
//        }];
//    }else if([alertView isEqual:_currentAlertView] && buttonIndex == 1){
//        _currentSender.text = [[PFUser currentUser] objectForKey: _currentKey];
//    }
//    
//    //Restore DONE action
//    _rightDrawerButton.action = @selector(popCurrentView);
////}
//- (void)disableBarItem
//{
//    //Disable DONE to avoid killing current controller by mistake
//    _rightDrawerButton.action = nil;
//}
//- (void)changeTextField
//{
//    //Ignore if user not change
//    if([_currentValueToChange isEqualToString:[[PFUser currentUser] objectForKey:kClassUserUsername]]){
//        _currentSender.text = [[PFUser currentUser] objectForKey: _currentKey];
//        return;
//    }
//    //Change to nil
//    NSString *warningString = [NSString stringWithFormat:@"Are you sure to change %@ to %@?", _currentType, _currentValueToChange];
//    if([_currentValueToChange length] == 0){
//        warningString = [NSString stringWithFormat:@"Are you sure to delete %@?", _currentType];
//    }
//    
//    _currentAlertView = [[UIAlertView alloc] initWithTitle: @"Warning" message:warningString  delegate: self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
//    [_currentAlertView show];
//}
//- (void)changeUsername:(UITextField*)sender
//{
//    _currentValueToChange = sender.text;
//    _currentKey = kClassUserUsername;
//    _currentSender = sender;
//    _currentType = @"User Name";
//    [self changeTextField];
//}
//- (void)changeEmail:(UITextField*)sender
//{
//    _currentValueToChange = sender.text;
//    _currentKey = kClassUserEmail;
//    _currentSender = sender;
//    _currentType = @"Email";
//    [self changeTextField];
//}
//- (void)changePhoneNumber:(UITextField*)sender
//{
//    _currentValueToChange = sender.text;
//    _currentKey = kClassUserPhoneNumber;
//    _currentSender = sender;
//    _currentType = @"Phone Number";
//    [self changeTextField];
//}
//- (void)changeLastFM:(UITextField*)sender
//{
//    _currentValueToChange = sender.text;
//    _currentKey = kClassUserLastFM;
//    _currentSender = sender;
//    _currentType = @"LastFM Account";
//    [self changeTextField];
//}
//- (void)changeRdio:(UITextField*)sender
//{
//    _currentValueToChange = sender.text;
//    _currentKey = kClassUserRdio;
//    _currentSender = sender;
//    _currentType = @"Rdio Account";
//    [self changeTextField];
//}

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
//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    [self disableBarItem];
//}
//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    [textField resignFirstResponder];
//    //Restore DONE action
//    _rightDrawerButton.action = @selector(popCurrentView);
//}
//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    //hide the keyboard
//    [textField resignFirstResponder];
//    
//    //return NO or YES, it doesn't matter
//    return YES;
//}
//
//
//- (void)hideKeyBoard
//{
//    for (UIView *view1 in self.view.subviews){
//        for(UIView *view2 in view1.subviews){
//            if ([view2 isKindOfClass:[UITextField class]] && [view2 isFirstResponder]) {
//                UITextField *textField = (UITextField*)view2;
//                [textField resignFirstResponder];
//                return;
//            }
//        }
//    }
//}



@end
