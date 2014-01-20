//
//  ShareViewController.m
//  Beet
//
//  Created by Yuhua Mai on 12/7/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//
// UICollectionViewController

#import "ShareViewController.h"

#import "YMGenericCollectionViewCell.h"

#import "MMDrawerBarButtonItem.h"
#import "MMNavigationController.h"
#import "UIViewController+MMDrawerController.h"

#import "SampleMusicViewController.h"
#import "SampleMusicYoutubeViewController.h"
#import "Setting.h"
#import "PublicMethod.h"
#import "SampleMusic_iTune.h"


@interface ShareViewController ()

@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@property (nonatomic, strong) NSArray *songs;



@end

@implementation ShareViewController

@synthesize songs = _songs;

- (id)init
{
    _username = [[PFUser currentUser] username];
    
    _column = 2;
    _row = 4;
    float cellWidth = [UIScreen mainScreen].bounds.size.width/_column-1;
    float cellHeight = [UIScreen mainScreen].bounds.size.height/_row;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(cellWidth, cellHeight)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:0.5f]; //Between items
    [flowLayout setMinimumLineSpacing:5.5f]; //Between lines
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0); //Between sections
    
    self = [super initWithCollectionViewLayout:flowLayout];
    
    if (self) {
        [self.collectionView registerClass:[ShareCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
        
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.backgroundColor = [UIColor blackColor];
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
    
    //UICollectionview
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
	
    //Setup Refresh Control
    [self setupRefreshControl];
    [self refreshView:self.refreshControl];
    
    //Spinner
    _spinner = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _spinner.center = CGPointMake(160, 240);
    _spinner.hidesWhenStopped = YES;
    [self.view addSubview:_spinner];
}

#pragma mark - UICollection view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
	return [_PFObjects count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
	static NSString *identifier = @"Cell";
	
	ShareCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
	cell.backgroundColor = [UIColor grayColor];
    
    PFObject *song = [_PFObjects objectAtIndex:indexPath.row];
    NSString *title = [song objectForKey:@"title"];
    NSString *artist = [song objectForKey:@"artist"];
//    NSString *album = [song objectForKey:@"album"];
    NSString *user = [song objectForKey:@"user"];
    PFFile *albumImage = [song objectForKey:@"albumImage"];
    
    cell.titleLabel.text = [NSString stringWithFormat:@"%@ share \"%@\" by %@", user, title, artist];

    NSData *imageData = [albumImage getData];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    if (!image) {
        image = [UIImage imageNamed:@"default_album.png"];
    }
    cell.backgroundView = [[UIImageView alloc] initWithImage:image];
    
	
	return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%d", indexPath.row);
    
    PFObject *song = [_PFObjects objectAtIndex:indexPath.row];
    NSString *title = [song objectForKey:@"title"];
    NSString *album = [song objectForKey:@"album"];
    NSString *artist = [song objectForKey:@"artist"];
    if(!title) title = @"N/A";
    if(!album) album = @"N/A";
    if(!artist) artist = @"N/A";

    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjects:@[title, album, artist] forKeys:@[@"title", @"album", @"artist"]];
    
    //Switch to Youtube
    SampleMusicYoutubeViewController *controller = [[SampleMusicYoutubeViewController alloc] initWithDictionary:dictionary];
    controller.delegate = self;
    MMNavigationController *navigationController = [[MMNavigationController alloc] initWithRootViewController:controller];
    [self.mm_drawerController setCenterViewController:navigationController withFullCloseAnimation:YES completion:nil];
}


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
    
    [self.collectionView addSubview:self.refreshControl];
}
-(void)refreshView:(UIRefreshControl *)refresh {
	refresh.attributedTitle = [[PublicMethod sharedInstance] refreshUpdatingString];
	[self fetchData:refresh];
}
/**
 * Query Friend Array for current user
 * Query Share music for current user's friend, not include current user
 */
-(void)fetchData:(UIRefreshControl*)refresh
{
    PFQuery *friendQuery = [PFQuery queryWithClassName:@"Friend"];
    [friendQuery whereKey:kClassFriendFromUsername equalTo:[[PFUser currentUser] username]];
    [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *friendArray, NSError *error) {
        NSMutableArray *friendUsernameArray = [[NSMutableArray alloc] init];
        for(PFObject *object in friendArray){
            NSString *friendUsername = [object objectForKey:kClassFriendToUsername];
            [friendUsernameArray addObject:friendUsername];
        }
        
        PFQuery *postQuery = [PFQuery queryWithClassName:@"Share"];
        [postQuery whereKey:kClassShareUsername notEqualTo:[[PFUser currentUser] username]];
        [postQuery whereKey:kClassShareUsername containedIn:friendUsernameArray];
        [postQuery orderByDescending:@"updatedAt"];
        [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                _PFObjects = objects;
                refresh.attributedTitle = [[PublicMethod sharedInstance] refreshFinsihedString];
                [self.collectionView reloadData];
                [refresh endRefreshing];
            }
        }];
    }];
}

#pragma mark - Button Handlers
-(void)setupMenuButton{
    //Navigation Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = @"Share";
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

@end