//
//  SideMenuViewController.m
//  Beet
//
//  Created by Yuhua Mai on 12/7/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "SideMenuViewController.h"
#import "MMTableViewCell.h"

#import "LiveFeedViewController.h"
#import "ShareViewController.h"
#import "ListenedViewController.h"
#import "FriendsViewController.h"
#import "UserViewController.h"

#import "MMNavigationController.h"

typedef NS_ENUM(NSInteger, BeetRow){
    BeetRow_LiveFeed,
    BeetRow_Share,
    BeetRow_Listened,
    BeetRow_Friends,
    BeetRow_User,
};

@interface SideMenuViewController ()

@property (nonatomic, strong) LiveFeedViewController *liveFeedViewController;
@property (nonatomic, strong) ShareViewController *shareViewController;
@property (nonatomic, strong) ListenedViewController *listenedViewController;
@property (nonatomic, strong) MMNavigationController *navigationListenedViewController;
@property (nonatomic, strong) FriendsViewController *friendsViewController;
@property (nonatomic, strong) UserViewController *userViewController;

@end

@implementation SideMenuViewController

@synthesize liveFeedViewController;
@synthesize shareViewController;
@synthesize listenedViewController;
@synthesize navigationListenedViewController;
@synthesize friendsViewController;
@synthesize userViewController;

-(id)initWithDefaultCenterView:(UIViewController*)controller{
    self = [super init];
    if(self){
        [self setRestorationIdentifier:@"MMExampleLeftSideDrawerController"];
        
        liveFeedViewController = (LiveFeedViewController*)controller;
        shareViewController = [[ShareViewController alloc] init];
        
        listenedViewController = [[ListenedViewController alloc] init];
        navigationListenedViewController = [[MMNavigationController alloc] initWithRootViewController:listenedViewController];
        
        friendsViewController = [[FriendsViewController alloc] init];
        userViewController = [[UserViewController alloc] init];

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

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if(section == MMDrawerSectionDrawerWidth)
        return @"Left Drawer Width";
    else if(section == MMDrawerSectionBeet)
        return @"Beet";
    else
        return [super tableView:tableView titleForHeaderInSection:section];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
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
                [cell.textLabel setText:@"Live Feed"];
                break;
            case BeetRow_Share:
                [cell.textLabel setText:@"Share"];
                break;
            case BeetRow_Listened:
                [cell.textLabel setText:@"Listened"];
                break;
            case BeetRow_Friends:
                [cell.textLabel setText:@"Friends"];
                break;
            case BeetRow_User:
                [cell.textLabel setText:@"User"];
                break;
            default:
                break;
        }
        [cell setAccessoryType:UITableViewCellAccessoryNone];
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
                [self.mm_drawerController setCenterViewController:liveFeedViewController withFullCloseAnimation:YES completion:nil];
                break;
            case BeetRow_Share:{
                [self.mm_drawerController setCenterViewController:shareViewController withFullCloseAnimation:YES completion:nil];
                break;
            }
            case BeetRow_Listened:
                [self.mm_drawerController setCenterViewController:navigationListenedViewController withFullCloseAnimation:YES completion:nil];
                break;
            case BeetRow_Friends:
                [self.mm_drawerController setCenterViewController:friendsViewController withFullCloseAnimation:YES completion:nil];
                break;
            case BeetRow_User:
                [self.mm_drawerController setCenterViewController:userViewController withFullCloseAnimation:YES completion:nil];
                break;
            default:
                break;
        }
    }
    else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

@end
