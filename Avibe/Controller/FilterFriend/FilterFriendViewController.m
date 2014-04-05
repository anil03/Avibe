//
//  FilterFriendViewController.m
//  Avibe
//
//  Created by Yuhua Mai on 3/27/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "FilterFriendViewController.h"

#import "UIViewController+MMDrawerController.h"
#import "MMNavigationController.h"
#import "ShareViewController.h"
#import "PublicMethod.h"

@interface FilterFriendViewController ()

//NavigationBar
@property UILabel *navigationBarTitleLabel;

@property NSArray *friendsArray;
@property NSMutableDictionary *selectedFriendDictionary;

@end

@implementation FilterFriendViewController


- (void)viewWillAppear:(BOOL)animated
{
    [self setupNavigationBar];
}
- (void)viewWillDisappear:(BOOL)animated
{
    NSMutableArray *selectedFriendUsernameArray = [[NSMutableArray alloc] init];
    for(id key in _selectedFriendDictionary){
        BOOL selected = [_selectedFriendDictionary[key] boolValue];
        int index = [key intValue];
        if (selected) {
            [selectedFriendUsernameArray addObject:_friendsArray[index][kClassFriendToUsername]];
        }
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(updateWithSelectedFriendsArrayWithUsername:)]){
        [self.delegate updateWithSelectedFriendsArrayWithUsername:selectedFriendUsernameArray];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.tableView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1]];
    
    //BackgroundView
    UIView *backgroundView = [[BackgroundImageView alloc] initWithFrame:self.tableView.frame];
    self.tableView.backgroundView = backgroundView;

    
    //Refresh control
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self action:@selector(updateContent) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    [self updateContent];
}
- (void)startRefresh{
    [self.refreshControl beginRefreshing];
}
- (void)stopRefresh {
    [self.refreshControl endRefreshing];
}

/**
 * Find friend of current username in Friend class
 */
- (void)updateContent
{
    PFQuery *postQuery = [PFQuery queryWithClassName:kClassFriend];
    [postQuery whereKey:kClassFriendFromUsername equalTo:[[PFUser currentUser] username]];
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            _friendsArray = objects;
            [self stopRefresh];
            
            _selectedFriendDictionary = [[NSMutableDictionary alloc] init];
            for(int i=0; i < [objects count]; i++){
                NSString *key = [NSString stringWithFormat:@"%ld",(long)i];
                [_selectedFriendDictionary setObject:@"1" forKey:key];
            }
            
            [self.tableView reloadData];
        }
    }];
}

- (void)toggleSelectedFriend
{
    for(int i=0; i < [_selectedFriendDictionary count]; i++){
        //Selected row
        NSString *key = [NSString stringWithFormat:@"%ld",(long)i];
        BOOL showCheckmark =  [[_selectedFriendDictionary valueForKey:key] boolValue];
        
        if (showCheckmark == YES){
            [_selectedFriendDictionary setObject:@"0" forKey:key];
        }else{
            [_selectedFriendDictionary setObject:@"1" forKey:key];
        }
    }
    [self.tableView reloadData];
}

#pragma mark - Tableview Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_friendsArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    
    //Search for displayname, if doesn't exist, use username
    NSString *username = _friendsArray[indexPath.row][kClassFriendToUsername];
    NSString *displayname;
    
    PFObject *userObject = [[PublicMethod sharedInstance] searchPFUserByUsername:username];
    if (userObject) {
        displayname = [userObject objectForKey:kClassUserDisplayname];
    }
    //If no displyname then use username
    if (!displayname) {
        displayname = username;
    }
    
    cell.textLabel.text = displayname;
    cell.detailTextLabel.text = @"detail";
    
    //Selected row
    NSString *key = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    BOOL showCheckmark =  [[_selectedFriendDictionary valueForKey:key] boolValue];
    
    if (showCheckmark == YES){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected row %ld",(long)indexPath.row);
    
    NSString *key = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
//    id object = _selectedFriendDictionary[key];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [_selectedFriendDictionary setObject:@"1" forKey:key];
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
//        [_selectedFriendDictionary removeObjectForKey:key];
        [_selectedFriendDictionary setObject:@"0" forKey:key];
    }
    
    //slow-motion selection animation.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Deselected row %ld",(long)indexPath.row);

}
#pragma mark - UITableView edit mode
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Button Handlers
-(void)setupNavigationBar{
    //Navigation Title
    _navigationBarTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    _navigationBarTitleLabel.text = @"Filter Friends to Share";
    _navigationBarTitleLabel.textColor = [UIColor colorWithRed:3.0/255.0
                                                         green:49.0/255.0
                                                          blue:107.0/255.0
                                                         alpha:1.0];
    [_navigationBarTitleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    //    [_navigationBarTitleLabel sizeToFit];
    self.mm_drawerController.navigationItem.titleView = _navigationBarTitleLabel;
    
    UINavigationBar *navigationBar = self.mm_drawerController.navigationController.navigationBar;
    [navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    navigationBar.shadowImage = [UIImage new];
    navigationBar.translucent = YES;
    
    //    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    UIBarButtonItem *leftDrawerButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(leftDrawerButtonPress)];
    [self.mm_drawerController.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    UIBarButtonItem *rightDrawerButton = [[UIBarButtonItem alloc] initWithTitle:@"Toggle" style:UIBarButtonItemStylePlain target:self action:@selector(toggleSelectedFriend)];
    [self.mm_drawerController.navigationItem setRightBarButtonItem:rightDrawerButton];
}
-(void)leftDrawerButtonPress{
    if (self.delegate && [self.delegate isKindOfClass:[ShareViewController class]]) {
        ShareViewController *controller = (ShareViewController *) self.delegate;
        [self.mm_drawerController setCenterViewController:[[MMNavigationController alloc] initWithRootViewController:controller] withCloseAnimation:YES completion:nil];
    }
}


@end
