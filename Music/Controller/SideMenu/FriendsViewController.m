//
//  FriendsViewController.m
//  Beet
//
//  Created by Yuhua Mai on 12/7/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "FriendsViewController.h"

#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"

#import "SampleMusicViewController.h"

#import "Cell.h"

@interface FriendsViewController ()

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSArray *friends;

@end

@implementation FriendsViewController

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
    [self.tableView registerClass:[Cell class] forCellReuseIdentifier:@"Cell"];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleBordered target:self action:@selector(addFriend:)];
    self.mm_drawerController.navigationItem.rightBarButtonItem = barButton;
    
	[self setupRefreshControl];
    [self refreshView:self.refreshControl];
}

#pragma mark Bar Button
- (IBAction)addFriend:(id)sender {
   PFObject *songRecord = [PFObject objectWithClassName:@"Friend"];
    [songRecord setObject:[[PFUser currentUser] username] forKey:@"user"];
    [songRecord setObject:@"myhgew3" forKey:@"friend"];
    [songRecord saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Save Friends Succeed!");
        }
    }];
    
    [self.tableView reloadData];
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
    return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject *friend = [self.friends objectAtIndex:indexPath.row];
    cell.textLabel.text = [friend objectForKey:@"friend"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    SampleMusicViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SampleMusicViewController"];
//    controller.pfObject = [self.friends objectAtIndex:indexPath.row];
//    //    controller.delegate = self;
//    
//    [self.mm_drawerController setCenterViewController:controller withFullCloseAnimation:YES completion:nil];
    
    //    [self performSegueWithIdentifier:@"SampleMusicSegue" sender:[_songs objectAtIndex:indexPath.row]];
}

#pragma mark - RefreshControl Method
- (void)setupRefreshControl
{
    // Inside a Table View Controller's viewDidLoad method
	UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
	refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
	[refresh addTarget:self
                action:@selector(refreshView:)
      forControlEvents:UIControlEventValueChanged];
	self.refreshControl = refresh;
    
    [self.refreshControl addTarget:self
                            action:@selector(refreshView:)
                  forControlEvents:UIControlEventValueChanged];
}


-(void)refreshView:(UIRefreshControl *)refresh {
	refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    
    // custom refresh logic would be placed here...
    [self fetchData:refresh];
    
    
}

-(void)fetchData:(UIRefreshControl*)refresh
{
    //Create query for all Post object by the current user
    PFQuery *postQuery = [PFQuery queryWithClassName:@"Friend"];
    [postQuery whereKey:@"user" equalTo:[[PFUser currentUser] username]];
    // Run the query
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //Save results and update the table
            self.friends = objects;
            [self.tableView reloadData];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMM d, h:mm a"];
            NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",[formatter stringFromDate:[NSDate date]]];
            refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
            [refresh endRefreshing];
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

