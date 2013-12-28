//
//  AddFriendsViewController.m
//  Beet
//
//  Created by Yuhua Mai on 12/27/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "AddFriendsViewController.h"

#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"


@interface AddFriendsViewController ()

@end

@implementation AddFriendsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{    

}

- (void)viewDidLoad
{
    [super viewDidLoad];

//    [self setupBarMenuButton];

}

-(void)setupBarMenuButton{
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.mm_drawerController.navigationController.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
    UIBarButtonItem * rightDrawerButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(popCurrentView)];
    self.mm_drawerController.navigationController.navigationItem.rightBarButtonItem = rightDrawerButton;
//    [self.mm_drawerController.navigationController.navigationItem setRightBarButtonItem:rightDrawerButton];
}

-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)popCurrentView
{
    [self.mm_drawerController.navigationController popViewControllerAnimated:YES];
}

@end
