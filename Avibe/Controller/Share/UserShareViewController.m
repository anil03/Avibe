//
//  UserShareViewController.m
//  Avibe
//
//  Created by Yuhua Mai on 1/20/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "UserShareViewController.h"
#import "PublicMethod.h"
#import "UIViewController+MMDrawerController.h"

@interface UserShareViewController ()

@end

@implementation UserShareViewController

-(void)fetchData:(UIRefreshControl*)refresh
{
    PFQuery *postQuery = [PFQuery queryWithClassName:@"Share"];
    [postQuery whereKey:kClassShareUsername equalTo:[[PFUser currentUser] username]];
    [postQuery orderByDescending:@"updatedAt"];
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.PFObjects = objects;
            refresh.attributedTitle = [[PublicMethod sharedInstance] refreshFinsihedString];
            [self.collectionView reloadData];
            [refresh endRefreshing];
        }
    }];
}

#pragma mark - Button Handlers
-(void)setupMenuButton{
    //Navigation Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = @"My Shared Music";
    titleLabel.textColor = [UIColor colorWithRed:3.0/255.0
                                           green:49.0/255.0
                                            blue:107.0/255.0
                                           alpha:1.0];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [titleLabel sizeToFit];
    self.mm_drawerController.navigationItem.titleView = titleLabel;
    
    /*
     MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
     [self.mm_drawerController.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
     */
    UIBarButtonItem * leftDrawerButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    self.mm_drawerController.navigationItem.leftBarButtonItem = leftDrawerButton;
    
    UIBarButtonItem * rightDrawerButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(popCurrentView)];
    [self.mm_drawerController.navigationItem setRightBarButtonItem:rightDrawerButton];
}
-(void)leftDrawerButtonPress:(id)sender{
	[self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}
- (void)popCurrentView
{
    [self.mm_drawerController setCenterViewController:self.previousViewController];
}

@end
