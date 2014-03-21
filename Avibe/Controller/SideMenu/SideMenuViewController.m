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

#import "GlobalPlayer.h"

typedef NS_ENUM(NSInteger, BeetRow){
    BeetRow_LiveFeed,
    BeetRow_Share,
//    BeetRow_Listened,
//    BeetRow_User,
    BeetRow_Friends,
};

@interface SideMenuViewController () <LiveFeedViewControllerDelegate, UserViewControllerDelegate>

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
@property UIButton *nextSong;
@property UIButton *previousSong;
@property UIButton *pauseSong;
@property UIImageView *albumImage;

@end

@implementation SideMenuViewController

@synthesize liveFeedViewController;
@synthesize shareViewController;
@synthesize listenedViewController;
@synthesize friendsViewController;
@synthesize userViewController;

-(id)initWithDefaultCenterView:(MMNavigationController*)controller{
    self = [super init];
    if(self){
        [self setRestorationIdentifier:@"MMExampleLeftSideDrawerController"];
        self.navigationLiveFeedViewController = controller;
    }
    return self;
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

#pragma mark - Footer view
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        _playerView = [[UIView alloc] init];
        [_playerView setBackgroundColor:[UIColor redColor]];
        
        _globalPlayer = [[GlobalPlayer alloc] init];
        
        float width = self.tableView.frame.size.width;
        float height = 100.0f;
        _nextSong = [[UIButton alloc] initWithFrame:CGRectMake(width/2, height-30, 30, 30)];
        [_nextSong setBackgroundColor:[UIColor blueColor]];
        [_playerView addSubview:_nextSong];
        
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

#pragma mark - UserViewController Delegate
- (void)setLastFMAccount:(NSString*)account
{
    _lastFMAccountUsername = account;
}
- (NSString*)getLastFMAccount
{
    return _lastFMAccountUsername;
}

@end
