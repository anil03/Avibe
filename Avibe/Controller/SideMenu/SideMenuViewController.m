//
//  SideMenuViewController.m
//  Beet
//
//  Created by Yuhua Mai on 12/7/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "SideMenuViewController.h"
#import "MMTableViewCell.h"
#import "MMSideDrawerSectionHeaderView.h"

#import "LiveFeedViewController.h"
#import "ShareViewController.h"
#import "ListenedViewController.h"
#import "FriendsViewController.h"
#import "UserViewController.h"

#import "MyLogInViewController.h"
#import "WelcomeViewController.h"

#import "MMNavigationController.h"
#import "MyLogInViewController.h"

#import "SettingViewController.h"

#import "MMSideDrawerTableViewCell.h"

#import "PublicMethod.h"
#import "GlobalPlayer.h"

#import "UIImage+Extras.h"
#import "AutoScrollLabel.h"

typedef NS_ENUM(NSInteger, BeetRow){
    BeetRow_LiveFeed,
    BeetRow_Share,
//    BeetRow_Listened,
//    BeetRow_User,
    BeetRow_Friends,
};

@interface SideMenuViewController () <LiveFeedViewControllerDelegate, UserViewControllerDelegate, GlobalPlayerDelegate>
{
    BOOL animating;
}

@property (nonatomic, strong) LiveFeedViewController *liveFeedViewController;
@property (nonatomic, strong) ShareViewController *shareViewController;
@property (nonatomic, strong) ListenedViewController *listenedViewController;
@property (nonatomic, strong) FriendsViewController *friendsViewController;
@property (nonatomic, strong) UserViewController *userViewController;
@property SettingViewController *settingViewController;

@property (nonatomic, strong) MMNavigationController *navigationLiveFeedViewController;
@property (nonatomic, strong) MMNavigationController *navigationShareViewController;
@property (nonatomic, strong) MMNavigationController *navigationListenedViewController;
@property (nonatomic, strong) MMNavigationController *navigationFriendsViewController;
@property (nonatomic, strong) MMNavigationController *navigationUserViewController;

@property (nonatomic, strong) NSString *lastFMAccountUsername;

//Global Player
@property GlobalPlayer *globalPlayer;
@property UIView *playerView;
@property UIView *playerBackgroundView;
@property UIButton *nextSongButton;
@property UIButton *playPauseSongButton;
@property UIButton *previousSongButton;
@property UIImageView *albumImageFrame;
@property UIImageView *albumImage;
@property AutoScrollLabel *marquee;

@end

@implementation SideMenuViewController

@synthesize liveFeedViewController;
@synthesize shareViewController;
@synthesize listenedViewController;
@synthesize friendsViewController;
@synthesize userViewController;

-(id)init
{
    self = [super init];
    if (self) {
        _globalPlayer = [[PublicMethod sharedInstance] globalPlayer];
        [_globalPlayer setDelegate:self];
    }
    return self;
}

-(id)initWithDefaultCenterView:(MMNavigationController*)controller{
    self = [self init];
    if(self){
        [self setRestorationIdentifier:@"MMExampleLeftSideDrawerController"];
        self.navigationLiveFeedViewController = controller;
    }
    return self;
}

#pragma mark - View method
- (void)viewWillAppear:(BOOL)animated
{
    [self setupAlbumImage];
    [self updatePlayerInfo];
}

- (void)updatePlayerInfo
{
    _playPauseSongButton.selected = [_globalPlayer audioPlayer].playing;
    animating = _playPauseSongButton.selected;
    if (_playPauseSongButton.selected) {
        [self setupAlbumImage];
        [self startSpin];
    }else{
        [self stopSpin];
    }
}

#pragma mark - TableView Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case MMDrawerSectionAvibe:
            return 3;
        case MMDrawerSectionUser:
            return 3;
        default:
            return 0;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //custom user section
    if(section == MMDrawerSectionUser){
        MMSideDrawerSectionHeaderView * headerView;
        headerView =  [[MMSideDrawerSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 100.0)];

        
        [headerView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [headerView setTitle:[tableView.dataSource tableView:tableView titleForHeaderInSection:section]];

        //Setting View
//        UIButton *button =[[UIButton alloc] initWithFrame:CGRectMake(100, 20, 32, 32)];
//        [button setBackgroundImage:[UIImage imageNamed:@"settings-32.png"] forState:UIControlStateNormal];
//        [button setBackgroundImage:[UIImage imageNamed:@"settings-32-highlight.png"] forState:UIControlStateHighlighted];
//        [button addTarget:self
//                     action:@selector(settingButtonPressed)
//           forControlEvents:UIControlEventTouchUpInside];
//        [headerView addSubview:button];
//        [headerView bringSubviewToFront:button];
        
        return headerView;
    }else{
     return [super tableView:tableView viewForHeaderInSection:section];
    }
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if(section == MMDrawerSectionDrawerWidth)
        return @"Left Drawer Width";
    else if(section == MMDrawerSectionAvibe)
        return @"Avibe";
    else if(section == MMDrawerSectionUser){
        NSString *username = [[PFUser currentUser] username];
        if ([username length] > 10) {
            username = [[username substringToIndex:8] stringByAppendingString:@"..."];
        }
        return username;
    }
    else
        return [super tableView:tableView titleForHeaderInSection:section];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";

    MMSideDrawerTableViewCell * cell = [[MMSideDrawerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

    if(indexPath.section == MMDrawerSectionDrawerWidth){
        
        CGFloat width = [self.drawerWidths[indexPath.row] intValue];
        CGFloat drawerWidth = self.mm_drawerController.maximumLeftDrawerWidth;
        if(drawerWidth == width){
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
        else{
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        [cell.textLabel setText:[NSString stringWithFormat:@"Width %d",[self.drawerWidths[indexPath.row] intValue]]];
    }else if(indexPath.section == MMDrawerSectionAvibe){
        switch (indexPath.row) {
            case BeetRow_LiveFeed:
                [cell.button setBackgroundImage:[UIImage imageNamed:@"dj-24.png"] forState:UIControlStateNormal];
                [cell.label setText:@"Live Feed"];
                break;
            case BeetRow_Share:
                [cell.button setBackgroundImage:[UIImage imageNamed:@"sharethis-3-24.png"] forState:UIControlStateNormal];
                [cell.label setText:@"Share"];
                break;
            case BeetRow_Friends:
                [cell.button setBackgroundImage:[UIImage imageNamed:@"conference-24.png"] forState:UIControlStateNormal];
                [cell.label setText:@"Friends"];
                break;
            default:
                break;
        }
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }else if(indexPath.section == MMDrawerSectionUser){
        switch (indexPath.row) {
            case 0:
                [cell.button setBackgroundImage:[UIImage imageNamed:@"newspaper-10-24.png"] forState:UIControlStateNormal];
                [cell.label setText:@"Profile"];
                break;
            case 1:
                [cell.button setBackgroundImage:[UIImage imageNamed:@"settings-24.png"] forState:UIControlStateNormal];
                [cell.label setText:@"Setting"];
                break;
            case 2:
                [cell.button setBackgroundImage:[UIImage imageNamed:@"undo-2-24.png"] forState:UIControlStateNormal];
                [cell.label setText:@"Sign out"];
                break;
            default:
                break;
        }
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == MMDrawerSectionDrawerWidth){
        [self.mm_drawerController
         setMaximumLeftDrawerWidth:[self.drawerWidths[indexPath.row] floatValue]
         animated:YES
         completion:^(BOOL finished) {
             [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
             [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
             [tableView deselectRowAtIndexPath:indexPath animated:YES];
         }];
        
    }
    else if(indexPath.section == MMDrawerSectionAvibe){
        switch (indexPath.row) {
            case BeetRow_LiveFeed:
                [self livefeedButtonPressed];
                break;
            case BeetRow_Share:{
                [self shareButtonPressed];
                break;
            }
            case BeetRow_Friends:{
                [self friendsButtonPressed];
                break;
            }
            default:
                break;
        }
    }
    else if(indexPath.section == MMDrawerSectionUser){
        switch (indexPath.row) {
            case 0:{
                [self userButtonPressed];
                break;
            }
            case 1:{
                [self settingButtonPressed];
                break;
            }
            case 2:
            {
                [self logoutButtonPressed];
                break;
            }
            default:
                break;
        }
    }
    else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark - Button pressed
- (void)livefeedButtonPressed {
//    [self.mm_drawerController setCenterViewController:self.navigationLiveFeedViewController withFullCloseAnimation:YES completion:nil];
    [self.mm_drawerController setCenterViewController:self.navigationLiveFeedViewController withCloseAnimation:YES completion:nil];
}
- (void)shareButtonPressed {
    shareViewController = [[ShareViewController alloc] init];
    self.navigationShareViewController = [[MMNavigationController alloc] initWithRootViewController:shareViewController];
    [self.mm_drawerController setCenterViewController:self.navigationShareViewController withCloseAnimation:YES completion:nil];
}
- (void)friendsButtonPressed {
    friendsViewController = [[FriendsViewController alloc] init];
    self.navigationFriendsViewController = [[MMNavigationController alloc] initWithRootViewController:friendsViewController];
    [self.mm_drawerController setCenterViewController:self.navigationFriendsViewController withCloseAnimation:YES completion:nil];
}
- (void)userButtonPressed {
    userViewController = [[UserViewController alloc] init];
    userViewController.delegate = self;
    self.navigationUserViewController = [[MMNavigationController alloc] initWithRootViewController:userViewController];
    [self.mm_drawerController setCenterViewController:self.navigationUserViewController withCloseAnimation:YES completion:nil];
}
- (void)settingButtonPressed
{
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SettingStoryboard" bundle:nil];
//    assert(storyboard != nil);
//    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
//    
//    assert(viewController != nil);
//    _settingViewController = (SettingViewController*)viewController;
    _settingViewController = [[SettingViewController alloc] init];
    _settingViewController.previousViewController = self.mm_drawerController.centerViewController;
    
    MMNavigationController *navigationSettingViewController = [[MMNavigationController alloc] initWithRootViewController:_settingViewController];
    
    [self.mm_drawerController setCenterViewController:navigationSettingViewController withCloseAnimation:YES completion:nil];
}
- (void)logoutButtonPressed {
    //Clear Parse
    PFQuery *query = [PFUser query];
    PFObject *object  = [query getObjectWithId:[[PFUser currentUser] objectId]];
    if (object) {
        //Clear Google
        [object removeObjectForKey:kClassUserGoogleUsername];
        //Clear Facebook
        [object removeObjectForKey:kClassUserFacebookDisplayname];
        [object removeObjectForKey:kClassUserFacebookUsername];
        //Clear Rdio
        [object removeObjectForKey:kClassUserRdioKey];
        [object removeObjectForKey:kClassUserRdioDisplayname];
        //Clear Last.fm
        [object removeObjectForKey:kClassUserLastFMUsername];
        
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                //                    [[[UIAlertView alloc] initWithTitle: @"Congratulations" message: @"Facebook revoked successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                [[PFUser currentUser] refresh];
            }
        }];
    }
    
    
    
    
    UIViewController *welcomeController = [[WelcomeViewController alloc] init];
    
    //Disconnect Facebook
    [FBSession.activeSession closeAndClearTokenInformation];

    
    
    
    //Clear all controller
    liveFeedViewController = nil;
    shareViewController = nil;
    listenedViewController = nil;
    friendsViewController = nil;
    userViewController = nil;
    
    self.navigationLiveFeedViewController = nil;
    self.navigationShareViewController = nil;
    self.navigationListenedViewController = nil;
    self.navigationFriendsViewController = nil;
    self.navigationUserViewController = nil;
    
    [self.mm_drawerController.navigationController pushViewController:welcomeController animated:YES];
    
    //log out
    [PFUser logOut];
}



#pragma mark - UserViewController Delegate
- (void)setLastFMAccount:(NSString*)account
{
    _lastFMAccountUsername = account;
}
- (NSString*)getLastFMAccount
{
    return _lastFMAccountUsername;
}

#pragma mark - Global Player Footer view
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        
        
        float width = self.tableView.frame.size.width;
        float height = 100.0f;
        float buttonHeight = 25.0f;
        
        _playerView = [[UIView alloc] init];
//        [_playerView setBackgroundColor:[UIColor redColor]];
        
        _playerBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, width, 60)];
        [_playerBackgroundView setBackgroundColor:[ColorConstant sideMenuHeaderBackgroundColor]];
        [_playerView addSubview:_playerBackgroundView];
        
        
        //Album Image
        _albumImageFrame = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [_albumImageFrame setImage:[UIImage imageNamed:@"circle-dashed-4-48-highlight.png"]];
        [_playerBackgroundView addSubview:_albumImageFrame];
        
        
        //AutoScrollLabel
         _marquee = [[AutoScrollLabel alloc] initWithFrame:CGRectMake(70, 0, width-70-10, 30)];
        [_playerBackgroundView addSubview:_marquee];
        [_marquee setScrollSpeed:20.0];
        [_marquee setFont:[UIFont systemFontOfSize:12.0]];
//        _marquee.text = @"My long text";
        [_marquee readjustLabels];
        [_marquee scroll];
        
        //Control Button
        _previousSongButton = [[UIButton alloc] initWithFrame:CGRectMake(60, buttonHeight, 32, 32)];
        [_previousSongButton setBackgroundImage:[UIImage imageNamed:@"arrow-89-32.png"] forState:UIControlStateNormal];
        [_nextSongButton setBackgroundImage:[UIImage imageNamed:@"arrow-89-32-highlight.png"] forState:UIControlStateHighlighted];
        [_previousSongButton addTarget:self action:@selector(playPreviousSong) forControlEvents:UIControlEventTouchUpInside];
        [_playerBackgroundView addSubview:_previousSongButton];
        
        
        _playPauseSongButton = [[UIButton alloc] initWithFrame:CGRectMake(95, buttonHeight, 32, 32)];
        [_playPauseSongButton setBackgroundImage:[UIImage imageNamed:@"play-32.png"] forState:UIControlStateNormal];
        [_playPauseSongButton setBackgroundImage:[UIImage imageNamed:@"pause-32.png"] forState:UIControlStateSelected];
        [_playPauseSongButton addTarget:self action:@selector(playPauseSong) forControlEvents:UIControlEventTouchUpInside];
        [_playerBackgroundView addSubview:_playPauseSongButton];
        
        
        _nextSongButton = [[UIButton alloc] initWithFrame:CGRectMake(130, buttonHeight, 32, 32)];
        [_nextSongButton setBackgroundImage:[UIImage imageNamed:@"arrow-24-32.png"] forState:UIControlStateNormal];
        [_nextSongButton setBackgroundImage:[UIImage imageNamed:@"arrow-24-32-highlight.png"] forState:UIControlStateHighlighted];
        [_nextSongButton addTarget:self action:@selector(playNextSong) forControlEvents:UIControlEventTouchUpInside];
        [_playerBackgroundView addSubview:_nextSongButton];
        
        
        return _playerView;
    }
    
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        return 130.0f;
    }
    return 0.0;
}

#pragma mark - Global Player Function
- (void)playPreviousSong
{
    NSLog(@"Previous song...");
    [_globalPlayer playPreviousSong];
}
- (void)playPauseSong
{
    NSLog(@"Play/Pause song...");
    
    [_globalPlayer playPauseSong];
    
    _playPauseSongButton.selected = [_globalPlayer audioPlayer].playing;
    if (_playPauseSongButton.selected) {
        [self setupAlbumImage];
        [self startSpin];
    }else{
        [self stopSpin];
    }
    
}
- (void)playNextSong
{
    NSLog(@"Next song...");
    [_globalPlayer playNextSong];
}

- (void) spinWithOptions: (UIViewAnimationOptions) options {
    // this spin completes 360 degrees every 2 seconds
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: options
                     animations: ^{
                         self.albumImageFrame.transform = CGAffineTransformRotate(self.albumImageFrame.transform, M_PI / 2);
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
                             if (animating) {
                                 // if flag still set, keep spinning with constant speed
                                 [self spinWithOptions: UIViewAnimationOptionCurveLinear];
                             } else if (options != UIViewAnimationOptionCurveEaseOut) {
                                 // one last spin, with deceleration
                                 [self spinWithOptions: UIViewAnimationOptionCurveEaseOut];
                             }
                         }
                     }];
}

- (void) startSpin {
    _marquee.text = [_globalPlayer currentTitle];
    
    if (!animating) {
        animating = YES;
        [self spinWithOptions: UIViewAnimationOptionCurveEaseIn];
    }
}

- (void) stopSpin {
    // set the flag to stop spinning after one last 90 degree increment
    animating = NO;
}

- (void)setupAlbumImage
{
    UIImage *image = [_globalPlayer currentImage];
    CGSize maskSize = _albumImageFrame.frame.size;
    maskSize.height -= 5;
    maskSize.width -= 5;
    image = [image imageByScalingProportionallyToSize:maskSize];
    
    _albumImage = [[UIImageView alloc] initWithImage:image];
    _albumImage.center = _albumImageFrame.center;
    _albumImage.layer.cornerRadius = roundf(_albumImage.frame.size.width/2.0);
    _albumImage.layer.masksToBounds = YES;
    
    // make new layer to contain shadow and masked image
    CALayer* containerLayer = [CALayer layer];
    containerLayer.shadowColor = [UIColor blackColor].CGColor;
    containerLayer.shadowRadius = 10.f;
    containerLayer.shadowOffset = CGSizeMake(0.f, 5.f);
    containerLayer.shadowOpacity = 1.f;
    
    // add masked image layer into container layer so that it's shadowed
    [containerLayer addSublayer:_albumImage.layer];
    
    // add container including masked image and shadow into view
    [self.view.layer addSublayer:containerLayer];
    
    [_albumImageFrame addSubview:_albumImage];
}

#pragma mark - Global player delegate
- (void)prepareCurrentSongSucceed
{
    [_globalPlayer playPauseSong];
    
    _playPauseSongButton.selected = [_globalPlayer audioPlayer].playing;
    if (_playPauseSongButton.selected) {
        [self setupAlbumImage];
        [self startSpin];
    }else{
        [self stopSpin];
    }
}
- (void)prepareCurrentSongFailed
{
    
}
- (void)playCurrentSongFinished
{
    [_globalPlayer playNextSong];
}

@end
