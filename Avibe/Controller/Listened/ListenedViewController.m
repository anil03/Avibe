//
//  ListenedViewController.m
//  Beet
//
//  Created by Yuhua Mai on 12/7/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//
// UITableViewController

#import "ListenedViewController.h"

#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"

#import "SampleMusicViewController.h"
#import "BackgroundImageView.h"
#import "YMGenericCollectionViewCell.h"
#import "PublicMethod.h"
#import "Setting.h"


@interface ListenedViewController ()

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSArray *songs;

@end

@implementation ListenedViewController

@synthesize songs = _songs;

- (id)init
{
    self = [super init];
    if (self) {
        //BackgroundView
        UIView *backgroundView = [[BackgroundImageView alloc] initWithFrame:self.tableView.frame];
        self.tableView.backgroundView = backgroundView;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupMenuButton];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self setupRefreshControl];
    [self refreshView:self.refreshControl];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.PFObjects count];
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
//    PFObject *song = [_songs objectAtIndex:indexPath.row];
//    cell.textLabel.text = [song objectForKey:@"title"];
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", [song objectForKey:@"title"], [song objectForKey:@"album"]];
//    
//    return cell;
//}




#pragma mark - RefreshControl Method
- (void)setupRefreshControl
{
	UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
	refresh.attributedTitle = [[PublicMethod sharedInstance] refreshBeginString];
	[refresh addTarget:self
		action:@selector(refreshView:)
		forControlEvents:UIControlEventValueChanged];
	self.refreshControl = refresh;
    
    [self.refreshControl addTarget:self
                           action:@selector(refreshView:)
                           forControlEvents:UIControlEventValueChanged];
}

-(void)refreshView:(UIRefreshControl *)refresh {
	refresh.attributedTitle = [[PublicMethod sharedInstance] refreshUpdatingString];
    [self fetchData:refresh];
}

-(void)fetchData:(UIRefreshControl*)refresh
{
    //Create query for all Post object by the current user
    PFQuery *postQuery = [PFQuery queryWithClassName:@"Song"];
    postQuery.limit = 15;
    [postQuery whereKey:@"user" equalTo:[[PFUser currentUser] username]];
    [postQuery orderByDescending:@"updatedAt"];
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.PFObjects = objects;
            [self.tableView reloadData];
            
            refresh.attributedTitle = [[PublicMethod sharedInstance] refreshFinsihedString];
            [refresh endRefreshing];
        }
    }];
}

#pragma mark - Button Handlers
-(void)setupMenuButton{
    //Navigation Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = @"Listen History";
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
