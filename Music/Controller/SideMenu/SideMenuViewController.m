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

typedef NS_ENUM(NSInteger, BeetRow){
    BeetRow_LiveFeed,
    BeetRow_Share,
    BeetRow_Listened,
//    BeetRow_User,
    BeetRow_Friends,
};

@interface SideMenuViewController () <LiveFeedViewControllerDelegate, UserViewControllerDelegate>

@property (nonatomic, strong) LiveFeedViewController *liveFeedViewController;
@property (nonatomic, strong) ShareViewController *shareViewController;
@property (nonatomic, strong) ListenedViewController *listenedViewController;
@property (nonatomic, strong) FriendsViewController *friendsViewController;
@property (nonatomic, strong) UserViewController *userViewController;

@property (nonatomic, strong) MMNavigationController *navigationLiveFeedViewController;
@property (nonatomic, strong) MMNavigationController *navigationShareViewController;
@property (nonatomic, strong) MMNavigationController *navigationListenedViewController;
@property (nonatomic, strong) MMNavigationController *navigationFriendsViewController;
@property (nonatomic, strong) MMNavigationController *navigationUserViewController;

@property (nonatomic, strong) NSString *lastFMAccountUsername;

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

        shareViewController = [[ShareViewController alloc] init];
        self.navigationShareViewController = [[MMNavigationController alloc] initWithRootViewController:shareViewController];

//        listenedViewController = [[ListenedViewController alloc] init];
        listenedViewController = [[ListenedViewController alloc] initWithCollectionViewLayout:nil];
        self.navigationListenedViewController = [[MMNavigationController alloc] initWithRootViewController:listenedViewController];
        
        friendsViewController = [[FriendsViewController alloc] init];
        self.navigationFriendsViewController = [[MMNavigationController alloc] initWithRootViewController:friendsViewController];

        userViewController = [[UIStoryboard storyboardWithName:@"User" bundle:nil] instantiateViewControllerWithIdentifier:@"UserViewController"];
        userViewController.delegate = self;
        self.navigationUserViewController = [[MMNavigationController alloc] initWithRootViewController:userViewController];


    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"Left will appear");
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"Left did appear");
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"Left will disappear");
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    NSLog(@"Left did disappear");
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self setTitle:@"Left Drawer"];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //custom user section
    if(section == MMDrawerSectionUser){
        MMSideDrawerSectionHeaderView * headerView;
        if(OSVersionIsAtLeastiOS7()){
            headerView =  [[MMSideDrawerSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 56.0)];
        }
        else {
            headerView =  [[MMSideDrawerSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 23.0)];
        }
        [headerView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [headerView setTitle:[tableView.dataSource tableView:tableView titleForHeaderInSection:section]];
        
        UIButton *button =[[UIButton alloc] initWithFrame:CGRectMake(100, 20, 32, 32)];
        [button setBackgroundImage:[UIImage imageNamed:@"settings-32.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"settings-32-highlight.png"] forState:UIControlStateHighlighted];
        [button addTarget:self
                     action:@selector(setting)
           forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:button];
        [headerView bringSubviewToFront:button];
        
        return headerView;
    }else{
     return [super tableView:tableView viewForHeaderInSection:section];
    }
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if(section == MMDrawerSectionDrawerWidth)
        return @"Left Drawer Width";
    else if(section == MMDrawerSectionBeet)
        return @"Beet";
    else if(section == MMDrawerSectionUser){
        return [[[PFUser currentUser] username] uppercaseString];
    }
    else
        return [super tableView:tableView titleForHeaderInSection:section];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    cell.backgroundColor = ([indexPath row]%2)?[UIColor lightGrayColor]:[UIColor whiteColor];
    
//    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//    [button setBackgroundColor:[UIColor redColor]];
//    button.enabled = NO;
//    [cell addSubview:button];
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
    }else if(indexPath.section == MMDrawerSectionBeet){
        switch (indexPath.row) {
            case BeetRow_LiveFeed:
                [cell.button setBackgroundImage:[UIImage imageNamed:@"dj-24.png"] forState:UIControlStateNormal];
                [cell.label setText:@"Live Feed"];
                break;
            case BeetRow_Share:
                [cell.button setBackgroundImage:[UIImage imageNamed:@"sharethis-3-24.png"] forState:UIControlStateNormal];
                [cell.label setText:@"Share"];
                break;
            case BeetRow_Listened:
                [cell.button setBackgroundImage:[UIImage imageNamed:@"music-record-24.png"] forState:UIControlStateNormal];
                [cell.label setText:@"Listened"];
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
    else if(indexPath.section == MMDrawerSectionBeet){
        switch (indexPath.row) {
            case BeetRow_LiveFeed:
                [self.mm_drawerController setCenterViewController:self.navigationLiveFeedViewController withFullCloseAnimation:YES completion:nil];
                break;
            case BeetRow_Share:{
                [self.mm_drawerController setCenterViewController:self.navigationShareViewController withFullCloseAnimation:YES completion:nil];
                break;
            }
            case BeetRow_Listened:
                [self.mm_drawerController setCenterViewController:self.navigationListenedViewController withFullCloseAnimation:YES completion:nil];
                break;
            case BeetRow_Friends:
                [self.mm_drawerController setCenterViewController:self.navigationFriendsViewController withFullCloseAnimation:YES completion:nil];
                break;
            default:
                break;
        }
    }
    else if(indexPath.section == MMDrawerSectionUser){
        switch (indexPath.row) {
            case 0:
                [self.mm_drawerController setCenterViewController:self.navigationUserViewController withFullCloseAnimation:YES completion:nil];
                break;
            case 1:
            {
                //log out
                [PFUser logOut];
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                WelcomeViewController *welcomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"WelComeViewController"];
                
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
                
                [self.mm_drawerController.navigationController pushViewController:welcomeViewController animated:YES];
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


#pragma mark - UserViewController Delegate
- (void)setLastFMAccount:(NSString*)account
{
    _lastFMAccountUsername = account;
}
- (NSString*)getLastFMAccount
{
    return _lastFMAccountUsername;
}

#pragma mark - Setting
- (void)setting
{
//    NSLog(@"Press Setting");
    
    SettingViewController *settingViewController = [[UIStoryboard storyboardWithName:@"SettingStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingViewController"];
    settingViewController.previousViewController = self.mm_drawerController.centerViewController;
    
    MMNavigationController *navigationSettingViewController = [[MMNavigationController alloc] initWithRootViewController:settingViewController];
    
    [self.mm_drawerController setCenterViewController:navigationSettingViewController withCloseAnimation:YES completion:nil];
}

@end
