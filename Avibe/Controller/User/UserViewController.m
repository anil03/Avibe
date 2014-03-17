//
//  UserViewController.m
//  Beet
//
//  Created by Yuhua Mai on 12/7/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//
// CustomViewController

#import "UserViewController.h"

#import "SampleMusicViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "MMNavigationController.h"
#import "UIViewController+MMDrawerController.h"
#import "YMTableViewCell.h"
#import "Setting.h"
#import "BackgroundImageView.h"
#import "PublicMethod.h"


@interface UserViewController () <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    UIColor *darkBackgroundColor;
    UIColor *titleTextColor;
    UIColor *lightBackgroundColor;
    UIColor *componentTextColor;
    UIColor *componentTextHighlightColor;
    
    float width;
    float height;
    float scrollWidth; 
	float scrollHeight;

	float barHeight;	
	float buttonWidth; 
	float buttonHeight;
	float unitHeight; 	

    float currentHeight;
    float headerViewHeight;
    float shareViewHeight;
    float historyViewHeight;
    
    int item;
}

@property UIScrollView *scrollView;
@property UIView *shareView;
@property UIView *historyView;

@property (nonatomic, strong) NSArray *PFObjectsForTableView;
@property int tableViewRows;
@property float tableViewRowHeight;

@property (nonatomic, strong) NSArray *PFObjectsForCollectionView;
@property (nonatomic, strong) NSMutableArray *albumImagesForCollectionView;
@property int collectionViewRows;
@property float collectionViewRowHeight;
@property int collectionViewColumns;

@end

@implementation UserViewController
@synthesize listenedViewController;
@synthesize userShareViewController;

- (id)init
{
    return [self initWithUsername:[[PFUser currentUser] username]];
}
- (id)initWithUsername:(NSString*)username
{
    self = [super init];
    if(self){
        _username = username;
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
	[self setupMenuButton];
    //Clear cache
    listenedViewController = nil;
    userShareViewController = nil;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Display Name
    PFObject *user = [[PublicMethod sharedInstance] searchPFUserByUsername:_username];
    if (user) {
        _displayname = [user objectForKey:kClassUserDisplayname];
    }
    if(!_displayname) _displayname = _username;

    
    //View Parameters
    darkBackgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    titleTextColor = [UIColor whiteColor];
    lightBackgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3];
    componentTextColor = [UIColor whiteColor];
    componentTextHighlightColor = [UIColor grayColor];
    
    width = [[UIScreen mainScreen] bounds].size.width;
    height = [[UIScreen mainScreen] bounds].size.height;
    scrollWidth = width;
    scrollHeight = height*3;
    currentHeight = 0.0f;

    barHeight = 80.0f;
    buttonWidth = width;
    buttonHeight = 100.0f;
    unitHeight = 30.0f;
    item = 15;
    

    //Set up View
    self.view.backgroundColor = [[Setting sharedSetting] sharedBackgroundColor];

    //ScrollView
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [_scrollView setContentSize:CGSizeMake(scrollWidth, scrollHeight)];
    _scrollView.userInteractionEnabled = YES;
    self.view = _scrollView;
    

    
    /*Header View*/
    currentHeight = 0;
    headerViewHeight = unitHeight*4;
    [self addHeaderView];
    
    /*ShareView*/
    currentHeight += headerViewHeight;
    item = 1;
    _collectionViewColumns = 3;
    _collectionViewRows = 2;
    _collectionViewRowHeight = 130.0f;
    shareViewHeight = unitHeight*item+_collectionViewRows*_collectionViewRowHeight;
    [self addShareView];
    
    /*HistoryView*/
    currentHeight += shareViewHeight+unitHeight;
    item = 1;
    _tableViewRows = 8;
    _tableViewRowHeight = 50.0f;
    historyViewHeight = item*unitHeight+_tableViewRows*_tableViewRowHeight;
    [self addHistoryView];
    
    
    //BackgroundView
    UIView *backgroundView = [[BackgroundImageView alloc] initWithFrame:CGRectMake(0, 0, scrollWidth, headerViewHeight)];
    [_scrollView addSubview:backgroundView];
    [_scrollView sendSubviewToBack:backgroundView];
    
    [self rearrangeView];
}
- (void)rearrangeView
{
    [_shareView setFrame:CGRectMake(0, headerViewHeight, width, shareViewHeight)];
    [_historyView setFrame:CGRectMake(0, headerViewHeight+shareViewHeight, width, historyViewHeight)];
    [_scrollView setContentSize:CGSizeMake(scrollWidth, headerViewHeight+shareViewHeight+historyViewHeight)];
}
- (void)addHeaderView
{
    float currentHeightInHeaderView = 0.0f;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, currentHeight, width, headerViewHeight)];
    headerView.backgroundColor = darkBackgroundColor;
    [_scrollView addSubview:headerView];
    
    
    //Name
    UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, currentHeightInHeaderView, width, unitHeight*2)];
    usernameLabel.text = [_displayname uppercaseString];
    usernameLabel.textColor = componentTextColor;
    usernameLabel.textAlignment = NSTextAlignmentCenter;
    usernameLabel.adjustsFontSizeToFitWidth = YES;
    [headerView addSubview:usernameLabel];
    
    
    //Labels
    int buttonNumber = 3;
    currentHeightInHeaderView = unitHeight*2;
    UILabel *followingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, currentHeightInHeaderView, width/buttonNumber, unitHeight)];
    followingLabel.text = @"Following: 0";
    followingLabel.textColor = componentTextColor;
    followingLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:followingLabel];
    PFQuery *queryForFollowingNumber = [PFQuery queryWithClassName:kClassFriend];
    [queryForFollowingNumber whereKey:kClassFriendFromUsername equalTo:_username];
    [queryForFollowingNumber countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            followingLabel.text = [NSString stringWithFormat:@"Following: %d", number];
        }
    }];
    
    UILabel *shareLabel = [[UILabel alloc] initWithFrame:CGRectMake(width/buttonNumber, currentHeightInHeaderView, width/buttonNumber, unitHeight)];
    shareLabel.textColor = componentTextColor;
    shareLabel.text = @"Share: 0";
    shareLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:shareLabel];
    PFQuery *queryForShareNumber = [PFQuery queryWithClassName:kClassShare];
    [queryForShareNumber whereKey:kClassSongUsername equalTo:_username];
    [queryForShareNumber countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            shareLabel.text = [NSString stringWithFormat:@"Share: %d", number];
        }
    }];
    
    UILabel *historyLabel= [[UILabel alloc] initWithFrame:CGRectMake(width*2/buttonNumber, currentHeightInHeaderView, width/buttonNumber, unitHeight)];
    historyLabel.textColor = componentTextColor;
    historyLabel.text = @"Listened: 0";
    historyLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:historyLabel];
    PFQuery *queryForHistoryNumber = [PFQuery queryWithClassName:kClassSong];
    [queryForHistoryNumber whereKey:kClassSongUsername equalTo:_username];
    [queryForHistoryNumber countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            historyLabel.text = [NSString stringWithFormat:@"Listened: %d", number];
        }
    }];
    
}
- (void)addShareView
{
    _shareView = [[UIView alloc] initWithFrame:CGRectMake(0, currentHeight, width, shareViewHeight)];
    _shareView.backgroundColor = lightBackgroundColor;
    [_scrollView addSubview:_shareView];
    
    //Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width*3/4, unitHeight)];
    titleLabel.backgroundColor = darkBackgroundColor;
    titleLabel.text = @" Share";
    titleLabel.textColor = titleTextColor;
    titleLabel.textAlignment = NSTextAlignmentNatural;
    [_shareView addSubview:titleLabel];
    
    //Share Button
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(width*3/4, 0, width/4, unitHeight)];
    [shareButton setTitle:@"more..." forState:UIControlStateNormal];
    [shareButton setTitleColor:componentTextColor forState:UIControlStateNormal];
    [shareButton setTitleColor:componentTextHighlightColor forState:UIControlStateHighlighted];
    shareButton.backgroundColor = darkBackgroundColor;
    [shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_shareView addSubview:shareButton];
    
    //UICollectionView
    
    float cellWidth = [UIScreen mainScreen].bounds.size.width/_collectionViewColumns-1;
    float cellHeight = _collectionViewRowHeight;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(cellWidth, cellHeight)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:0.5f]; //Between items
    [flowLayout setMinimumLineSpacing:5.5f]; //Between lines
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0); //Between sections
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, unitHeight, width, _collectionViewRows*_collectionViewRowHeight) collectionViewLayout:flowLayout];
    [collectionView registerClass:[ShareCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor clearColor];
    [_shareView addSubview:collectionView];
    
    PFQuery *postQuery = [PFQuery queryWithClassName:@"Share"];
    [postQuery whereKey:kClassSongUsername equalTo:_username];
    [postQuery orderByDescending:@"updatedAt"];
    postQuery.limit = _collectionViewRows*_collectionViewColumns;
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            _PFObjectsForCollectionView = objects;
            _albumImagesForCollectionView = [[NSMutableArray alloc] init];
            for(PFObject *object in objects){
                PFFile *albumImage = [object objectForKey:@"albumImage"];
                NSData *imageData = [albumImage getData];
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                if(!image){
                    image = [UIImage imageNamed:@"default_album.png"];
                }
                [_albumImagesForCollectionView addObject:image];
            }
            
            
            int diviedFully = ([objects count]%_collectionViewColumns == 0)? 0:1;
            _collectionViewRows = (int) [objects count]/_collectionViewColumns+diviedFully;
            [collectionView setFrame:CGRectMake(0, unitHeight, width, _collectionViewRows*_collectionViewRowHeight)];
            shareViewHeight = unitHeight*1+_collectionViewRows*_collectionViewRowHeight;
            [self rearrangeView];
            [collectionView reloadData];
        }
    }];

    
}
- (void)addHistoryView
{
    
    _historyView = [[UIView alloc] initWithFrame:CGRectMake(0, currentHeight, width, historyViewHeight)];
    _historyView.backgroundColor = lightBackgroundColor;
    [_scrollView addSubview:_historyView];
    
    
    //Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width*3/4, unitHeight)];
    titleLabel.backgroundColor = darkBackgroundColor;
    titleLabel.text = @" Listen History";
    titleLabel.textColor = titleTextColor;
    titleLabel.textAlignment = NSTextAlignmentNatural;
    [_historyView addSubview:titleLabel];
    
    //Recent History Button
    UIButton *recentHistoryButton = [[UIButton alloc] initWithFrame:CGRectMake(width*3/4, 0, width/4, unitHeight)];
    recentHistoryButton.titleLabel.textAlignment = NSTextAlignmentRight;
    [recentHistoryButton setTitle:@"more..." forState:UIControlStateNormal];
    [recentHistoryButton setTitleColor:componentTextColor forState:UIControlStateNormal];
    [recentHistoryButton setTitleColor:componentTextHighlightColor forState:UIControlStateHighlighted];
    recentHistoryButton.backgroundColor = darkBackgroundColor;
    [recentHistoryButton addTarget:self action:@selector(recentHistoryButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_historyView addSubview:recentHistoryButton];
    
    //TableView
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, unitHeight, width, _tableViewRows*_tableViewRowHeight) style:UITableViewStylePlain];
    UIView *backgroundView = [[BackgroundImageView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height)];
    [tableView setBackgroundView:backgroundView];
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    tableView.dataSource = self;
    tableView.delegate = self;
    [_historyView addSubview:tableView];
    PFQuery *postQuery = [PFQuery queryWithClassName:@"Song"];
    postQuery.limit = _tableViewRows;
    [postQuery whereKey:@"user" equalTo:self.username];
    [postQuery orderByDescending:@"updatedAt"];
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            _PFObjectsForTableView = objects;
            
            _tableViewRows = (int)[objects count];
            [tableView setFrame:CGRectMake(0, unitHeight, width, _tableViewRows*_tableViewRowHeight)];
            historyViewHeight = unitHeight+_tableViewRows*_tableViewRowHeight;
          [self rearrangeView];
            [tableView reloadData];
        }
    }];
    

}

#pragma mark - UICollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
	return [_PFObjectsForCollectionView count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
	static NSString *identifier = @"Cell";
	
	ShareCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
	cell.backgroundColor = [UIColor grayColor];
    
    PFObject *song = [_PFObjectsForCollectionView objectAtIndex:indexPath.row];
    NSString *title = [song objectForKey:@"title"];
    NSString *artist = [song objectForKey:@"artist"];
    //    NSString *album = [song objectForKey:@"album"];
    NSString *user = [song objectForKey:@"user"];
    
    
    cell.titleLabel.text = [NSString stringWithFormat:@"%@ share \"%@\" by %@", user, title, artist];
    
    UIImage *image = [_albumImagesForCollectionView objectAtIndex:indexPath.row];
    if (!image) {
        image = [UIImage imageNamed:@"default_album.png"];
    }
    cell.backgroundView = [[UIImageView alloc] initWithImage:image];
    
	
	return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%ld", (long)indexPath.row);
    
    PFObject *song = [_PFObjectsForCollectionView objectAtIndex:indexPath.row];
    NSString *title = [song objectForKey:@"title"];
    NSString *album = [song objectForKey:@"album"];
    NSString *artist = [song objectForKey:@"artist"];
    if(!title) title = @"N/A";
    if(!album) album = @"N/A";
    if(!artist) artist = @"N/A";
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjects:@[title, album, artist] forKeys:@[@"title", @"album", @"artist"]];
    
    //Switch to Youtube
    SampleMusicViewController *controller = [[SampleMusicViewController alloc] initWithDictionary:dictionary];
    controller.delegate = self;
    MMNavigationController *navigationController = [[MMNavigationController alloc] initWithRootViewController:controller];
    [self.mm_drawerController setCenterViewController:navigationController withFullCloseAnimation:YES completion:nil];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_PFObjectsForTableView count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _tableViewRowHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFObject *song = [_PFObjectsForTableView objectAtIndex:indexPath.row];
    NSString *title = [song objectForKey:kClassSongTitle];
//    NSString *album = [song objectForKey:kClassSongAlbum];
    NSString *artist = [song objectForKey:kClassSongArtist];
//    NSString *user = [song objectForKey:kClassSongUsername];

    cell.backgroundColor = lightBackgroundColor;
    cell.textLabel.text = title;
    cell.detailTextLabel.text = artist;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *song = [_PFObjectsForTableView objectAtIndex:indexPath.row];
//    NSString *title = [song objectForKey:kClassSongTitle] ? [song objectForKey:kClassSongTitle] : @"N/A";
//    NSString *album = [song objectForKey:kClassSongAlbum] ? [song objectForKey:kClassSongAlbum] : @"N/A";
//    NSString *artist = [song objectForKey:kClassSongArtist] ? [song objectForKey:kClassSongArtist] : @"N/A";
//    
//    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjects:@[title, album, artist] forKeys:@[@"title", @"album", @"artist"]];
    
    SampleMusicViewController *controller = [[SampleMusicViewController alloc] initWithPFObject:song]; //initWithDictionary:dictionary];
    controller.delegate = self;
    MMNavigationController *navigationController = [[MMNavigationController alloc] initWithRootViewController:controller];
    [self.mm_drawerController setCenterViewController:navigationController withFullCloseAnimation:YES completion:nil];
}

#pragma mark - Button Pressed
- (void)recentHistoryButtonPressed
{
    listenedViewController = [[ListenedViewController alloc] initWithUsername:_username];
    listenedViewController.previousViewController = self;
    
    MMNavigationController *navigationAddFriendsViewController = [[MMNavigationController alloc] initWithRootViewController:listenedViewController];
    [self.mm_drawerController setCenterViewController:navigationAddFriendsViewController withCloseAnimation:YES completion:nil];
}
- (void)shareButtonPressed
{
    userShareViewController = [[UserShareViewController alloc] initWithUsername:_username];
    userShareViewController.previousViewController = self;
    
    MMNavigationController *navigationAddFriendsViewController = [[MMNavigationController alloc] initWithRootViewController:userShareViewController];
    [self.mm_drawerController setCenterViewController:navigationAddFriendsViewController withCloseAnimation:YES completion:nil];
}

#pragma mark - Button Handlers
-(void)setupMenuButton{
    //Navigation Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    NSString *titleText = _displayname;
    int titleLength = 8;
    if([titleText length] > titleLength) titleText = [[titleText substringToIndex:titleLength]  stringByAppendingString:@"..."];
    titleLabel.text = [NSString stringWithFormat:@"%@'s Profile", titleText];
    titleLabel.textColor = [UIColor colorWithRed:3.0/255.0
                                           green:49.0/255.0
                                            blue:107.0/255.0
                                           alpha:1.0];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [titleLabel sizeToFit];
    self.mm_drawerController.navigationItem.titleView = titleLabel;
    
    
	MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
	[self.mm_drawerController.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
    [self.mm_drawerController.navigationItem setRightBarButtonItem:nil];
}

-(void)leftDrawerButtonPress:(id)sender{
	[self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

#pragma mark - Call UserViewController Delegate
- (void)callUserViewController:(NSString*)input
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(setLastFMAccount:)]){
        [self.delegate setLastFMAccount:input];
    }
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //hide the keyboard
    [self callUserViewController:textField.text];
    [textField resignFirstResponder];
    
    //return NO or YES, it doesn't matter
    return YES;
}

#pragma mark - Touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UIView * txt in self.view.subviews){
        if ([txt isKindOfClass:[UITextField class]] && [txt isFirstResponder]) {
            UITextField *textField = (UITextField*)txt;
            [self callUserViewController:textField.text];
            [txt resignFirstResponder];
        }
    }
}

@end
