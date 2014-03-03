//
//  SpotifyViewController.m
//  Avibe
//
//  Created by Yuhua Mai on 3/3/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "EightTracksViewController.h"

#import "UIViewController+MMDrawerController.h"
#import "MMNavigationController.h"

@interface EightTracksViewController ()

@end

@implementation EightTracksViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setupNavigationBar];
}

#pragma mark - Button Handlers
-(void)setupNavigationBar{
    //Navigation Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = @"Eight Tracks";
    titleLabel.textColor = [UIColor colorWithRed:3.0/255.0
                                           green:49.0/255.0
                                            blue:107.0/255.0
                                           alpha:1.0];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [titleLabel sizeToFit];
    self.mm_drawerController.navigationItem.titleView = titleLabel;
    [self.mm_drawerController.navigationController.navigationBar setBarTintColor: [ColorConstant navigationBarBackgroundColor]];
    
    //    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    UIBarButtonItem *leftDrawerButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(leftDrawerButtonPress)];
    [self.mm_drawerController.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    [self.mm_drawerController.navigationItem setRightBarButtonItem:nil];
}
-(void)leftDrawerButtonPress{
    [self.mm_drawerController setCenterViewController:[[MMNavigationController alloc] initWithRootViewController:self.delegate] withCloseAnimation:YES completion:nil];
}

@end
