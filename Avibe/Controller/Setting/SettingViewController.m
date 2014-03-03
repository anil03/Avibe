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

#import "YoutubeAuthorizeViewController.h"
#import "FacebookAuthorizeViewController.h"
#import "Rdio/Rdio.h"
#import "AppDelegate.h"
#import "Setting.h"
#import "PublicMethod.h"
#import "BackgroundImageView.h"
#import "MMDrawerBarButtonItem.h"

//Link Facebook
#import "LinkFacebookViewController.h"
#import "SpotifyViewController.h"
#import "PandoraViewController.h"
#import "RdioViewController.h"
#import "DeezerViewController.h"
#import "EightTracksViewController.h"

@interface SettingViewController () <UITextFieldDelegate, UIAlertViewDelegate, GoogleOAuthDelegate, FBLoginViewDelegate, RdioDelegate>
{
    int leftOffset;
    int topOffset;
}

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
@property UIAlertView *rdioConfirmAlertView;
@property BOOL rdioAutorizationSucceed;
//Youtube
@property UIAlertView *youtubeConfirmAlertView;
@property BOOL youtubeAuthorized;
//Facebook
@property UIAlertView *facebookAlertView;
@property FBLoginView *facebookLoginView;
@property UILabel *facebookLoginLabel;
@property NSString *facebookCellString;
@property UIColor *facebookCellColor;

//Link Facebook
@property NSUserDefaults* defaults;
@property BOOL spotifyAuthorized;
@property BOOL pandoraAuthorized;
@property BOOL rdioAuthorized;
@property BOOL deezerAuthorized;
@property BOOL eightTracksAuthorized;

//Authorization Sources
@property (nonatomic, strong) ScrobbleAuthorizeViewController *scrobbleAuthorizeViewController;
//@property (nonatomic, strong) RdioåAuthorizeViewController *rdioAuthorizeViewController;
@property (nonatomic, strong) YoutubeAuthorizeViewController *youtubeAuthorizeViewController;
@property (nonatomic, strong) FacebookAuthorizeViewController *facebookAuthorizeViewController;

@end

@implementation SettingViewController

static NSString* const spotifyDefault = @"SpotifyAuthorized";
static NSString* const pandoraDefault = @"PandoraAuthorized";
static NSString* const rdioDefault = @"RdioAuthorized";
static NSString* const deezerDefault = @"DeezerAuthorized";
static NSString* const eightTracksDefault = @"EightTracksAuthorized";

@synthesize defaults;

#pragma mark - View method
- (void)viewWillAppear:(BOOL)animated
{
    [self setupBarMenuButton];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Constant
    leftOffset = 15;
    topOffset = 8;
    
    //TableView Style
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; //eliminate lines after last cell
    
    //BackgroundView
    UIView *backgroundView = [[BackgroundImageView alloc] initWithFrame:self.tableView.frame];
    [self.tableView setBackgroundView:backgroundView];
    
    //LastFM
    _receivedData = [[NSMutableData alloc] init];
    _urlConnection = [[NSURLConnection alloc] init];
    
    //Youtube
    _youtubeAuthorizeViewController = [[YoutubeAuthorizeViewController alloc] init];
    _youtubeAuthorizeViewController.previousViewController = self;
    [_youtubeAuthorizeViewController setGOAuthDelegate:self];
    [self authorizeGoogle:nil];
 
    //Facebook
    
    //Rdio
//    Rdio *rdio = [AppDelegate rdioInstance];
//    assert(rdio != nil);
//    [self setRdioAutorizationSucceed:[[PFUser currentUser] objectForKey:kClassUserRdioKey]? YES : NO];
    
    //Spotify
    defaults = [NSUserDefaults standardUserDefaults];
    self.spotifyAuthorized = [defaults boolForKey:spotifyDefault];
    self.pandoraAuthorized = [defaults boolForKey:pandoraDefault];
    self.rdioAuthorized = [defaults boolForKey:rdioDefault];
    self.deezerAuthorized = [defaults boolForKey:deezerDefault];
    self.eightTracksAuthorized = [defaults boolForKey:eightTracksDefault];
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
    YoutubeRow,
    ScrobbleRow,
    
    FacebookRow,
    SpotifyRow,
    PandoraRow,
    RdioRow,
    DeezerRow,
    EightTracksRow
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
            return 8;
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
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(250, 6, 50, 20)];
        [cell addSubview:switchView];
        [cell bringSubviewToFront:switchView];
        
        switch (indexPath.row) {
            case YoutubeRow:{
                NSString *googleUsername = [[PFUser currentUser] objectForKey:kClassUserGoogleUsername];
                _youtubeAuthorized = googleUsername? YES : NO;
                
                cell.textLabel.text = @"YouTube";
                
                switchView.on = _youtubeAuthorized;
                [switchView addTarget:self action:@selector(youtubeAuthorize) forControlEvents:UIControlEventValueChanged];
                
                //                cell.detailTextLabel.text = _youtubeAuthorized? @"Authorized✓" : @"Unauthorized✗";
                //                cell.detailTextLabel.textColor = _youtubeAuthorized? [UIColor redColor] : [UIColor grayColor];
                break;
            }
            case ScrobbleRow:{
                cell.textLabel.text = @"Last.fm";
                NSString *lastFMUser = [[PFUser currentUser] objectForKey:kClassUserLastFMUsername];
//                cell.detailTextLabel.text = lastFMUser? [lastFMUser stringByAppendingString:@"✓"] : @"Unauthorized✗";
//                cell.detailTextLabel.textColor = lastFMUser? [UIColor redColor] : [UIColor grayColor];
                switchView.on = lastFMUser? YES:NO;
                [switchView addTarget:self action:@selector(scrobbleAuthorize) forControlEvents:UIControlEventValueChanged];
                
                }
                break;
            
            
            case FacebookRow:{
                NSString *displayName = [[PFUser currentUser] objectForKey:kClassUserFacebookDisplayname];
                BOOL facebookLogIn = NO;
                if(FBSession.activeSession.state == FBSessionStateOpen
                   || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) facebookLogIn = YES;
                
                cell.textLabel.text = @"Facebook";
                
                switchView.on = facebookLogIn;
                [switchView addTarget:self action:@selector(facebookAuthroize) forControlEvents:UIControlEventValueChanged];
                
//                cell.detailTextLabel.text = facebookLogIn? [displayName stringByAppendingString:@"✓"] : @"Unauthorized✗";
//                cell.detailTextLabel.textColor = facebookLogIn? [UIColor redColor] : [UIColor grayColor];
                
                
                break;
            }
            case SpotifyRow:{
                cell.textLabel.text = @"Spotify";
                
                switchView.on = self.spotifyAuthorized;
                [switchView addTarget:self action:@selector(spotifyAuthorize) forControlEvents:UIControlEventValueChanged];
                
                break;
            }
            case PandoraRow:{
                cell.textLabel.text = @"Pandora";
                
                switchView.on = self.pandoraAuthorized;
                [switchView addTarget:self action:@selector(pandoraAuthorize) forControlEvents:UIControlEventValueChanged];
                
                break;
            }
            case RdioRow:{
//                UIImage *image = [UIImage imageNamed:@"rdio-logo.png"];
//                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(leftOffset, topOffset, 80, 28)];
//                [imageView setImage:image];
//                [cell addSubview:imageView];
//                [cell bringSubviewToFront:imageView];
                
                cell.textLabel.text = @"Rdio";
                switchView.on = self.rdioAuthorized;
                [switchView addTarget:self action:@selector(rdioAuthorize) forControlEvents:UIControlEventValueChanged];
                
                break;
            }
            case DeezerRow:{
                cell.textLabel.text = @"Deezer";
                
                switchView.on = self.deezerAuthorized;
                [switchView addTarget:self action:@selector(deezerAuthorize) forControlEvents:UIControlEventValueChanged];
                
                break;
            }
            case EightTracksRow:{
                cell.textLabel.text = @"EightTracks";
                
                switchView.on = self.eightTracksAuthorized;
                [switchView addTarget:self action:@selector(eightTrackAuthorize) forControlEvents:UIControlEventValueChanged];
                
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
        //Disable userinteraction
        return;
        
        switch (indexPath.row) {
            case ScrobbleRow:
//                [self scrobbleAuthorize];
                break;
            case RdioRow:
//                [self rdioAuthorize];
                break;
            case YoutubeRow:
//                [self youtubeAuthorize];
                break;
            case FacebookRow:{
                BOOL integratedWithParse = [[[PFUser currentUser] objectForKey:kClassUserFacebookIntegratedWithParse] boolValue];
                if (integratedWithParse) {
//                    [[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Avibe account has been linked to Facebook, can't be changed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }else{
//                    [self facebookAuthroize];
                }
                break;
            }
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
                [object removeObjectForKey:kClassUserLastFMUsername];
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
    
    //Rdio
//    if ([alertView isEqual:_rdioConfirmAlertView] && buttonIndex == 0) {
//        [AppDelegate rdioInstance].delegate = self;
//        [[AppDelegate rdioInstance] logout];
//    }
    
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

- (void)scrobbleAuthorize
{
    NSString *lastFMAccount = [[PFUser currentUser] objectForKey:kClassUserLastFMUsername];
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

- (void)facebookAuthroize
{
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        
        // If the session state is not any of the two "open" states when the button is clicked
        // Log out, clear Parse info about facebook
        PFQuery *query = [PFUser query];
        [query getObjectInBackgroundWithId:[[PFUser currentUser] objectId] block:^(PFObject *object, NSError *error) {
            if (object) {
                [object removeObjectForKey:kClassUserFacebookDisplayname];
                [object removeObjectForKey:kClassUserFacebookUsername];
                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        //                    [[[UIAlertView alloc] initWithTitle: @"Congratulations" message: @"Facebook revoked successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                        [[PFUser currentUser] refresh];
                        [self.tableView reloadData];
                    }else{
                        [self authorizeFailed];
                    }
                }];
            }
        }];
        
        
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for basic_info permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info",@"user_actions.music"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             
             // Retrieve the app delegate
             AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
             [appDelegate sessionStateChanged:session state:state error:error];
             
             if (!error) {
                 //Successfully log in with Facebook, update Parse info about Facebook
                 [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                     if (!error) {
                         NSString *username = result[@"username"];
                         NSString *displayName = result[@"name"];
                         
                         PFQuery *query = [PFUser query];
                         [query getObjectInBackgroundWithId:[[PFUser currentUser] objectId] block:^(PFObject *object, NSError *error) {
                             if (object) {
                                 if(username) [object setObject:username  forKey:kClassUserFacebookUsername];
                                 if(displayName) [object setObject:displayName forKey:kClassUserFacebookDisplayname];
                                 [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                     if (succeeded) {
                                         [[[UIAlertView alloc] initWithTitle: @"Congratulations" message: @"Facebook authorized successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                         [[PFUser currentUser] refresh];
                                         [self.tableView reloadData];
                                     }else{
                                         [self authorizeFailed];
                                     }
                                 }];
                             }
                         }];
                         
                     }
                 }];
             }else{
                 [[[UIAlertView alloc] initWithTitle: @"Error" message: @"Facebook authorized could not be finished. Please try later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
             }
             
             
             
         }];
    }
}

//Link Facebook
- (void)linkFacebookAuthorize:(BOOL)authorized identifier:(NSString*)identifier defaultKey:(NSString*)key
{
    if (!authorized) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LinkFacebookStoryboard" bundle:nil];
        LinkFacebookViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:identifier];
        viewController.delegate = self;
        
        MMNavigationController *navigationAddFriendsViewController = [[MMNavigationController alloc] initWithRootViewController:viewController];
        [self.mm_drawerController setCenterViewController:navigationAddFriendsViewController withCloseAnimation:YES completion:nil];
    }
    
    [defaults setBool:!authorized forKey:key];
}

- (void)spotifyAuthorize
{
    [self linkFacebookAuthorize:self.spotifyAuthorized identifier:@"Spotify" defaultKey:spotifyDefault];
    self.spotifyAuthorized = !self.spotifyAuthorized;
}
- (void)pandoraAuthorize
{
    [self linkFacebookAuthorize:self.pandoraAuthorized identifier:@"Pandora" defaultKey:pandoraDefault];
    self.pandoraAuthorized = !self.pandoraAuthorized;
}
- (void)rdioAuthorize
{
    [self linkFacebookAuthorize:self.rdioAuthorized identifier:@"Rdio" defaultKey:rdioDefault];
    self.rdioAuthorized = !self.rdioAuthorized;
}
- (void)deezerAuthorize
{
    [self linkFacebookAuthorize:self.deezerAuthorized identifier:@"Deezer" defaultKey:deezerDefault];
    self.deezerAuthorized = !self.deezerAuthorized;
}
- (void)eightTrackAuthorize
{
    [self linkFacebookAuthorize:self.eightTracksAuthorized identifier:@"EightTracks" defaultKey:eightTracksDefault];
    self.eightTracksAuthorized = !self.eightTracksAuthorized;
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
    NSLog(@"%ld", (long)[httpResponse statusCode]);
    
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
            [object setObject:username forKey:kClassUserLastFMUsername];
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

    //Save to Parse
    PFQuery *query = [PFUser query];
    [query getObjectInBackgroundWithId:[[PFUser currentUser] objectId] block:^(PFObject *object, NSError *error) {
        if (object) {
            [object setObject:@"Youtube"  forKey:kClassUserGoogleUsername];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
//                    [[[UIAlertView alloc] initWithTitle: @"Congratulations" message: @"Youtube authorized successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    [[PFUser currentUser] refresh];
                    [self.tableView reloadData];
                }else{
                    [self authorizeFailed];
                }
            }];
        }
    }];
}
-(void)accessTokenWasRevoked{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"Your access was revoked!"
                                                   delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    
    _youtubeAuthorized = NO;
    [self.tableView reloadData];
    
    //Remove from Parse
    PFQuery *query = [PFUser query];
    [query getObjectInBackgroundWithId:[[PFUser currentUser] objectId] block:^(PFObject *object, NSError *error) {
        if (object) {
            [object removeObjectForKey:kClassUserGoogleUsername];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    //                    [[[UIAlertView alloc] initWithTitle: @"Congratulations" message: @"Facebook revoked successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    [[PFUser currentUser] refresh];
                    [self.tableView reloadData];
                }else{
                    [self authorizeFailed];
                }
            }];
        }
    }];
}
-(void)errorOccuredWithShortDescription:(NSString *)errorShortDescription andErrorDetails:(NSString *)errorDetails{
    NSLog(@"%@", errorShortDescription);
    NSLog(@"%@", errorDetails);
}
-(void)errorInResponseWithBody:(NSString *)errorMessage{
    NSLog(@"%@", errorMessage);
}
-(void)responseFromServiceWasReceived:(NSString *)responseJSONAsString andResponseJSONAsData:(NSData *)responseJSONAsData;
{
    
}

#pragma mark - Facebook login
- (void)customizeFacebookLoginView:(CGRect)frame
{
    if([_facebookLoginLabel.text rangeOfString:@"out"].location != NSNotFound){
        _facebookLoginView = [[FBLoginView alloc] init];
        [_facebookLoginView setReadPermissions:@[@"basic_info", @"user_actions.music"]];
        [self.tableView bringSubviewToFront:_facebookLoginView];
//        [_facebookLoginView setPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]];
//        [_facebookLoginView setDefaultAudience:FBSessionDefaultAudienceFriends];
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
    PFQuery *query = [PFUser query];
    [query getObjectInBackgroundWithId:[[PFUser currentUser] objectId] block:^(PFObject *object, NSError *error) {
        if (object) {
            [object removeObjectForKey:kClassUserFacebookDisplayname];
            [object removeObjectForKey:kClassUserFacebookUsername];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
//                    [[[UIAlertView alloc] initWithTitle: @"Congratulations" message: @"Facebook revoked successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    [[PFUser currentUser] refresh];
                    [self.tableView reloadData];
                }else{
                    [self authorizeFailed];
                }
            }];
        }
    }];

}
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    PFQuery *query = [PFUser query];
    [query getObjectInBackgroundWithId:[[PFUser currentUser] objectId] block:^(PFObject *object, NSError *error) {
        if (object) {
            [object setObject:[user name]  forKey:kClassUserFacebookDisplayname];
            [object setObject:[user username] forKey:kClassUserFacebookUsername];
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

#pragma mark - RdioDelegate
- (void)rdioDidAuthorizeUser:(NSDictionary *)user withAccessToken:(NSString *)accessToken
{
    NSString *key = [user objectForKey:@"key"];
    NSString *firstName = [user objectForKey:@"firstName"];
    NSString *lastName = [user objectForKey:@"lastName"];
    assert(key != nil);
    assert(firstName != nil);
    assert(lastName != nil);
    
    [self rdioAuthorizedSuccess:[NSString stringWithFormat:@"%@ %@", firstName, lastName] key:key];
}
- (void)rdioAuthorizationFailed:(NSString *)error
{
    [self rdioAuthorizedRevoke];
}
- (void)rdioAuthorizationCancelled
{
    [self rdioAuthorizedRevoke];
}
- (void)rdioDidLogout
{
    [self rdioAuthorizedRevoke];
}
- (void)rdioAuthorizedSuccess:(NSString*)username key:(NSString*)key
{
    PFQuery *query = [PFUser query];
    [query getObjectInBackgroundWithId:[[PFUser currentUser] objectId] block:^(PFObject *object, NSError *error) {
        if (object) {
            [object setObject:username forKey:kClassUserRdioDisplayname];
            [object setObject:key forKey:kClassUserRdioKey];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [[[UIAlertView alloc] initWithTitle: @"Congratulations" message: @"Rdio authorized successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    [[PFUser currentUser] refresh];
                    [self.tableView reloadData];
                }else{
                    [self authorizeFailed];
                }
            }];
        }
    }];
    
    [self setRdioAutorizationSucceed:YES];
    [self.tableView reloadData];
}
- (void)rdioAuthorizedRevoke
{
    PFQuery *query = [PFUser query];
    [query getObjectInBackgroundWithId:[[PFUser currentUser] objectId] block:^(PFObject *object, NSError *error) {
        if (object) {
            [object removeObjectForKey:kClassUserRdioDisplayname];
            [object removeObjectForKey:kClassUserRdioKey];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [[[UIAlertView alloc] initWithTitle: @"Congratulations" message: @"Rdio revoked successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    [[PFUser currentUser] refresh];
                    [self.tableView reloadData];
                }else{
                    [self authorizeFailed];
                }
            }];
        }
    }];
    [self setRdioAutorizationSucceed:NO];
    [self.tableView reloadData];
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

@end
