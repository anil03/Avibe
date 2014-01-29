//
//  FriendsViewController.m
//  Beet
//
//  Created by Yuhua Mai on 12/7/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//
// UITableViewController

#import "FriendsViewController.h"

#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"

#import "MMNavigationController.h"

#import "SampleMusicViewController.h"

#import "FindFriendsViewController.h"
#import "BackgroundImageView.h"
#import "PublicMethod.h"
#import "UserViewController.h"

@interface FriendsViewController () <FindFriendsViewControllerDelegate>

@property (nonatomic, strong) UIRefreshControl *refreshControl;

//@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) NSMutableDictionary *friendsDictionary;
@property (nonatomic, strong) NSArray *alphabet;
@property (nonatomic, strong) NSString *others;
@property (nonatomic, strong) NSMutableArray *titleForSection;

@property (nonatomic, strong) UserViewController *userViewController;

@end

@implementation FriendsViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _friendsDictionary = [[NSMutableDictionary alloc] init];
        _others = @"Others";
        _alphabet = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", _others];
        
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        [self.tableView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1]];
        
        //BackgroundView
         UIView *backgroundView = [[BackgroundImageView alloc] initWithFrame:self.tableView.frame];
        self.tableView.backgroundView = backgroundView;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[self setupMenuButton];
    //Clear cache
    _userViewController = nil;
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
    _titleForSection = [[NSMutableArray alloc] init];
    int numberOfSections = 0;
    for(NSString *key in _alphabet){
        NSArray *array = [_friendsDictionary objectForKey:key];
        if ([array count] > 0) {
            numberOfSections++;
            [_titleForSection addObject:key];
        }
    }
    return numberOfSections;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _titleForSection[section];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_friendsDictionary objectForKey:_titleForSection[section]] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    
    // Configure the cell...
    cell.textLabel.text = [_friendsDictionary objectForKey:_titleForSection[indexPath.section]][indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    [cell setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4]];
//    [cell.textLabel setTextColor:[UIColor whiteColor]];
//    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    NSString *username = [_friendsDictionary objectForKey:_titleForSection[indexPath.section]][indexPath.row];
    
    _userViewController = [[UserViewController alloc] initWithUsername:username];
    _userViewController.previousViewController = self;
    
    MMNavigationController *navigationAddFriendsViewController = [[MMNavigationController alloc] initWithRootViewController:_userViewController];
    [self.mm_drawerController setCenterViewController:navigationAddFriendsViewController withCloseAnimation:YES completion:nil];
}

#pragma mark - RefreshControl Method
- (void)setupRefreshControl
{
    // Inside a Table View Controller's viewDidLoad method
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
    PFQuery *postQuery = [PFQuery queryWithClassName:kClassFriend];
    [postQuery whereKey:kClassFriendFromUsername equalTo:[[PFUser currentUser] username]];
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self sortFriend:objects];
            refresh.attributedTitle = [[PublicMethod sharedInstance] refreshFinsihedString];
            [refresh endRefreshing];
            [self.tableView reloadData];
        }
    }];
}
-(void)sortFriend:(NSArray *)objects
{
    NSMutableArray *friends = [[NSMutableArray alloc] init];
    
    
    for(PFObject *object in objects){
        [friends addObject:[object objectForKey:@"friend"]];
    }
    [friends sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    //Separate into Different Alphabet
    for(NSString *firstChar in _alphabet){
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for(NSString *string in friends){
            NSString *firstCharInString = [string substringToIndex:1];
            
            //Match "Others" or Alphabet char
            if([firstChar isEqualToString:_others] || [firstChar isEqualToString:firstCharInString] || [firstChar isEqualToString:[firstCharInString capitalizedString]]){
                [array addObject:string];
            }
        }
        [friends removeObjectsInArray:array];
        [_friendsDictionary setObject:array forKey:firstChar];
    }
}

#pragma mark - Button Handlers
-(void)setupMenuButton{
    //Navigation Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = @"Friends";
    titleLabel.textColor = [UIColor colorWithRed:3.0/255.0
                                           green:49.0/255.0
                                            blue:107.0/255.0
                                           alpha:1.0];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [titleLabel sizeToFit];
    self.mm_drawerController.navigationItem.titleView = titleLabel;
    
	MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
	[self.mm_drawerController.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
    UIBarButtonItem * rightDrawerButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFriendButtonPress)];
    [self.mm_drawerController.navigationItem setRightBarButtonItem:rightDrawerButton];
}
-(void)leftDrawerButtonPress:(id)sender{
	[self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}
-(void)addFriendButtonPress{
    FindFriendsViewController *addFriendsViewController = [[FindFriendsViewController alloc] init];
    addFriendsViewController.delegate = self;
    addFriendsViewController.friendsViewController = self.mm_drawerController.centerViewController;
    
    MMNavigationController *navigationAddFriendsViewController = [[MMNavigationController alloc] initWithRootViewController:addFriendsViewController];
    [self.mm_drawerController setCenterViewController:navigationAddFriendsViewController withCloseAnimation:YES completion:nil];
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

@end

