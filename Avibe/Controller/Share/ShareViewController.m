//
//  ShareViewController.m
//  Avibe
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

#import "ITuneMusicViewController.h"
#import "SampleMusicViewController.h"
#import "Setting.h"
#import "PublicMethod.h"
#import "SampleMusic.h"

#import "FilterFriendViewController.h"

/**
 * Share view fetch all shared musics of all friends.
 * Music can be shared within sample music view.
 */

@interface ShareViewController () <FilterFriendViewControllerDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@property (nonatomic, strong) NSArray *songs;

@property (nonatomic)  FilterFriendViewController *filterFriendViewController;

@end

@implementation ShareViewController

@synthesize songs = _songs;

#pragma mark - Getter and Setter
- (FilterFriendViewController *)filterFriendViewController
{
    if (!_filterFriendViewController) {
        _filterFriendViewController = [[FilterFriendViewController alloc] init];
        _filterFriendViewController.delegate = self;
    }
    return _filterFriendViewController;
}


- (id)init
{
    _username = [[PFUser currentUser] username];
    
    _column = 3;
    _row = 5;
    float cellWidth = [UIScreen mainScreen].bounds.size.width/_column-1;
    float cellHeight = [UIScreen mainScreen].bounds.size.height/_row;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(cellWidth, cellHeight)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:0.5f]; //Between items
    [flowLayout setMinimumLineSpacing:5.5f]; //Between lines
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0); //Between sections
    flowLayout.headerReferenceSize = CGSizeMake(50, 25); //set header
    
    self = [super initWithCollectionViewLayout:flowLayout];
    
    if (self) {
        [self.collectionView registerClass:[ShareCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
        
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.backgroundColor = [UIColor blackColor];
        [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
        
        //BackgroundView
        dispatch_async(kBgQueue, ^{
            UIView *backgroundView = [[BackgroundImageView alloc] initWithFrame:self.collectionView.frame];
            self.collectionView.backgroundView = backgroundView;
        });
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
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        
        UICollectionReusableView *headerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        [headerview setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.9]];
        
        UIButton *button = [[UIButton alloc] initWithFrame:headerview.frame];
        [button setTitle:@"Play All" forState:UIControlStateNormal];
        [[button titleLabel] setFont:[UIFont systemFontOfSize:14.0f]];
        [button addTarget:self action:@selector(playAllMusicForShare) forControlEvents:UIControlEventTouchUpInside];
        [headerview addSubview:button];
        reusableview = headerview;
    }
    
    return reusableview;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
	static NSString *identifier = @"Cell";
	
	ShareCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
	cell.backgroundColor = [UIColor grayColor];
    
    PFObject *song = [_PFObjects objectAtIndex:indexPath.row];
    NSString *title = [song objectForKey:@"title"];
//    NSString *artist = [song objectForKey:@"artist"];
//    NSString *album = [song objectForKey:@"album"];
    NSString *user = [song objectForKey:@"user"];
    
    
    cell.titleLabel.text = [NSString stringWithFormat:@"%@ share \"%@\"", user, title];

    UIImage *image = [_albumImages objectAtIndex:indexPath.row];
    if (!image) {
        image = [UIImage imageNamed:@"default_album.png"];
    }
    cell.backgroundView = [[UIImageView alloc] initWithImage:image];
    
	
	return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%ld", (long)indexPath.row);
    
    PFObject *song = [_PFObjects objectAtIndex:indexPath.row];
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
        
        [self fetchDataWithFriendsArray:friendUsernameArray];
    }];
}
- (void)fetchDataWithFriendsArray:(NSArray*)friendUsernameArray
{
    PFQuery *postQuery = [PFQuery queryWithClassName:@"Share"];
    [postQuery whereKey:kClassSongUsername notEqualTo:[[PFUser currentUser] username]];
    [postQuery whereKey:kClassSongUsername containedIn:friendUsernameArray];
    [postQuery orderByDescending:@"updatedAt"];
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            _PFObjects = objects;
            _albumImages = [[NSMutableArray alloc] init];
            for(PFObject *object in objects){
                PFFile *albumImage = [object objectForKey:@"albumImage"];
                NSData *imageData = [albumImage getData];
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                if(!image){
                    image = [UIImage imageNamed:@"default_album.png"];
                }
                [_albumImages addObject:image];
            }
            
            
            self.refreshControl.attributedTitle = [[PublicMethod sharedInstance] refreshFinsihedString];
            [self.collectionView reloadData];
            [self.refreshControl endRefreshing];
            
            [self updateGlobalPlayer];
        }
    }];
}
- (void)updateGlobalPlayer
{
    GlobalPlayer *globalPlayer = [[PublicMethod sharedInstance] globalPlayer];
    [globalPlayer clearPlaylist];
    
    for(PFObject *object in _PFObjects){
        NSString *md5 = object[kClassSongMD5];
        NSString *title = object[kClassSongTitle];
        NSString *album = object[kClassSongAlbum];
        NSString *artist = object[kClassSongArtist];
        NSString *albumUrl = object[kClassSongAlbumURL];
        NSString *dataUrl = object[kClassSongDataURL];
        
        if(!md5){
            NSString *stringForMD5 = [NSString stringWithFormat:@"%@%@%@%@",title,artist,album,[[PFUser currentUser]username]];
            md5 = [[PublicMethod sharedInstance] handleStringToMD5:stringForMD5];
        }
            
        [globalPlayer insertMd5:md5];
        [globalPlayer insertBasicInfoByMd5:md5 title:title album:album artist:artist];
        [globalPlayer insertAlbumUrlByMd5:md5 albumUrl:albumUrl];
        [globalPlayer insertDataUrlByMd5:md5 dataUrl:dataUrl];
    }
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
    
    UIBarButtonItem * rightDrawerButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(rightDrawerButtonPress)];
	[self.mm_drawerController.navigationItem setRightBarButtonItem:rightDrawerButton animated:YES];}

-(void)leftDrawerButtonPress:(id)sender{
	[self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)rightDrawerButtonPress{
	MMNavigationController *navigationController = [[MMNavigationController alloc] initWithRootViewController:self.filterFriendViewController];
    [self.mm_drawerController setCenterViewController:navigationController];
}

#pragma mark - FilterFriendViewController delegate method
- (void)updateWithSelectedFriendsArrayWithUsername:(NSArray *)firendsArrayWithUsername
{
    [self fetchDataWithFriendsArray:firendsArrayWithUsername];
}

#pragma mark - Global player 
- (void)playAllMusicForShare
{
    NSLog(@"Play all music for share.");
    GlobalPlayer *globalPlayer = [[PublicMethod sharedInstance] globalPlayer];
#pragma mark - TODO should play from beginning
    [globalPlayer playPauseSong];
}

@end