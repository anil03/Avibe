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

#import "ITuneMusicViewController.h"

#import "FindFriendsViewController.h"
#import "BackgroundImageView.h"
#import "PublicMethod.h"
#import "UserViewController.h"

@interface FriendsViewController () <FindFriendsViewControllerDelegate>

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSMutableDictionary *friendsDictionarySortByAlphabet;

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
        _friendsDictionarySortByAlphabet = [[NSMutableDictionary alloc] init];
        
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
/**
 * Setup those sections with friend in it
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    _titleForSection = [[NSMutableArray alloc] init];
    int numberOfSections = 0;
    for(NSString *key in _alphabet){
        NSArray *array = [_friendsDictionarySortByAlphabet objectForKey:key];
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
    return [[_friendsDictionarySortByAlphabet objectForKey:_titleForSection[section]] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];

    cell.textLabel.text = [_friendsDictionarySortByAlphabet objectForKey:_titleForSection[indexPath.section]][indexPath.row][kClassUserDisplayname];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString *displayname = [_friendsDictionarySortByAlphabet objectForKey:_titleForSection[indexPath.section]][indexPath.row][kClassUserDisplayname];
    NSString *username = [_friendsDictionarySortByAlphabet objectForKey:_titleForSection[indexPath.section]][indexPath.row][kClassUserUsername];
    
    _userViewController = [[UserViewController alloc] initWithUsername:username];
    _userViewController.previousViewController = self;
    
    MMNavigationController *navigationAddFriendsViewController = [[MMNavigationController alloc] initWithRootViewController:_userViewController];
    [self.mm_drawerController setCenterViewController:navigationAddFriendsViewController withCloseAnimation:YES completion:nil];
}

#pragma mark - TODO
//choose friend and DONE button return
//then update share page

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
/**
 * Find friend of current username in Friend class
 */
-(void)fetchData:(UIRefreshControl*)refresh
{
    PFQuery *postQuery = [PFQuery queryWithClassName:kClassFriend];
    [postQuery whereKey:kClassFriendFromUsername equalTo:[[PFUser currentUser] username]];
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self setupFriendsArray:objects];
            refresh.attributedTitle = [[PublicMethod sharedInstance] refreshFinsihedString];
            [refresh endRefreshing];
            [self.tableView reloadData];
        }
    }];
}
/**
 * Save Dictionary friend with username & displayname
 */
-(void)setupFriendsArray:(NSArray *)objects
{
    NSMutableArray *friends = [[NSMutableArray alloc] init];
    
    for(PFObject *object in objects){
        //Set up display name from username
        //Get username from friendsDictionary, then search displayname by username
        
        NSString *username = [object objectForKey:kClassFriendToUsername];
        NSString *displayname;
        
        PFObject *userObject = [[PublicMethod sharedInstance] searchPFUserByUsername:username];
        if (userObject) {
            displayname = [userObject objectForKey:kClassUserDisplayname];
        }
        //If no displyname then use username
        if (!displayname) {
            displayname = username;
        }
        
        NSDictionary *friend = [[NSDictionary alloc] initWithObjects:@[username,displayname] forKeys:@[kClassUserUsername,kClassUserDisplayname]];
        
        //Add displayname to friends array
        [friends addObject:friend];
    }
    
    [self sortFriendsArray:friends];
}
/**
 * Sort friends array
 * friends[username(key)-displayname(value),...]
 */
- (void)sortFriendsArray:(NSMutableArray*)friends
{
    //Separate into Different Alphabet, A,B,C,D,....,Others
    for(NSString *firstChar in _alphabet){
        NSMutableArray *friendArrayWithUsernameAndDisplayname = [[NSMutableArray alloc] init];
        for(NSDictionary *friend in friends){
            NSString *displayname = friend[kClassUserDisplayname];
            NSString *firstCharInString = [displayname substringToIndex:1];
            
            //Match "Others" or Alphabet char
            if([firstChar isEqualToString:firstCharInString] ||
               [firstChar isEqualToString:[firstCharInString capitalizedString]]){
                [friendArrayWithUsernameAndDisplayname addObject:friend];
            }
        }
        [friends removeObjectsInArray:friendArrayWithUsernameAndDisplayname];
        [_friendsDictionarySortByAlphabet setObject:friendArrayWithUsernameAndDisplayname forKey:firstChar];
    }
    
    //Others should be left in the friends after deleting A,B,C,.....Z
    [_friendsDictionarySortByAlphabet setObject:friends forKey:_others];
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

