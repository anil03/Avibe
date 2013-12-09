//
//  UserViewController.m
//  Beet
//
//  Created by Yuhua Mai on 12/7/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "UserViewController.h"

#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"

@interface UserViewController ()

@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *numberOfSongs;

@end

@implementation UserViewController

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
	[self setupMenuButton];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.username.text = [[PFUser currentUser] username];
    [self updateInfo];

}

- (void)updateInfo{
    PFQuery *postQuery = [PFQuery queryWithClassName:@"Song"];
    [postQuery whereKey:@"author" equalTo:[[PFUser currentUser] username]];
    // Run the query
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.numberOfSongs.text = [NSString stringWithFormat:@"Own: %d songs.", [objects count]];
        }
    }];
}

#pragma mark - Button Handlers
-(void)setupMenuButton{
	MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
	[self.mm_drawerController.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
    [self.mm_drawerController.navigationItem setRightBarButtonItem:nil];
}

-(void)leftDrawerButtonPress:(id)sender{
	[self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

@end
