//
//  LiveFeedViewController.m
//  Beet
//
//  Created by Yuhua Mai on 12/7/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//
// SpreadSheet Like UICollectionViewController

#import "LiveFeedViewController.h"

#import "MMExampleDrawerVisualStateManager.h"
#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "MMLogoView.h"
#import "MMCenterTableViewCell.h"
#import "MMExampleLeftSideDrawerViewController.h"
#import "MMExampleRightSideDrawerViewController.h"
#import "MMNavigationController.h"

#import <QuartzCore/QuartzCore.h>

#import <MediaPlayer/MediaPlayer.h>
#import <Parse/Parse.h>

#import "AppDelegate.h"
#import "ITuneMusicViewController.h"
#import "SampleMusicViewController.h"

#import "Song.h"

#import "YMTableViewCell.h"
#import "YMGenericCollectionViewCell.h"
#import "YMGenericCollectionReusableHeaderView.h"
#import "YMGenericCollectionViewFlowLayout.h"

#import "Setting.h"
#import "PublicMethod.h"

#import "BackgroundImageView.h"
#import "SampleMusicSourceView.h"
#import "UserViewController.h"
#import "SaveMusicFromSources.h"

typedef NS_ENUM(NSInteger, MMCenterViewControllerSection){
    MMCenterViewControllerSectionLeftViewState,
    MMCenterViewControllerSectionLeftDrawerAnimation,
    MMCenterViewControllerSectionRightViewState,
    MMCenterViewControllerSectionRightDrawerAnimation,
};

@interface LiveFeedViewController() <SampleMusicSourceViewDelegate, UIWebViewDelegate, UIAlertViewDelegate>
{
    int columnNumber;
}

@property (weak, atomic) UIViewController *viewController;
@property (nonatomic, strong) UserViewController *userViewController;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *CurrPlaying;

//Switch To iTune
@property (nonatomic, strong) UIAlertView *alertBeforeSwitchToITune;
@property (nonatomic, strong) NSURL* iTuneUrl;

@property (nonatomic, strong) NSMutableArray *XMLData;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSArray *PFObjects;
@property (nonatomic, strong) SaveMusicFromSources *saveMusicEntries;
@end

@implementation LiveFeedViewController

#pragma mark - Init method
- (id)initWithSelf:(UIViewController*)controller
{
    self.viewController = controller;
    return [self init];
}
- (id)init
{
    columnNumber = 4;
    
    UICollectionViewFlowLayout *flowLayout = [[YMGenericCollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(([UIScreen mainScreen].bounds.size.width-25)/4, 30)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:5.0f]; //Between items
    [flowLayout setMinimumLineSpacing:10.0f]; //Between lines
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 5, 5); //Between sections
    flowLayout.headerReferenceSize = CGSizeMake(50, 20); //set header
    
    self = [super initWithCollectionViewLayout:flowLayout];
    
    if (self) {
        [self setRestorationIdentifier:@"MMExampleCenterControllerRestorationKey"];
        
        //UICollectionview
        [self.collectionView registerClass:[YMGenericCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
        [self.collectionView registerClass:[YMGenericCollectionReusableHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
        [self.collectionView registerClass:[YMGenericCollectionReusableHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
        self.collectionView.delegate=self;
        self.collectionView.dataSource=self;
        
        //BackgroundView
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_apply(1, queue, ^(size_t i) {
            UIView *backgroundView = [[BackgroundImageView alloc] initWithFrame:self.collectionView.frame];
            self.collectionView.backgroundView = backgroundView;
        });
        
    }
    
    return self;
}

#pragma mark - View method
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupBarMenuButton];
    
    /**
     * Automatically refresh in certain interval
     * Unit - second
     * Or the tableview is empty
     */
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastUpdatedDate = [defaults objectForKey:kKeyLastUpdatedDate];
    NSTimeInterval actualInterval = [lastUpdatedDate timeIntervalSinceNow];
    NSTimeInterval interval = 3.0;
    if (abs(actualInterval) > interval || !_PFObjects) {
        assert(_refreshControl != nil);
        [self refreshView:_refreshControl];
//        [self saveYoutubeMusic];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Setup Refresh Control
    [self setupRefreshControl];
}

#pragma mark - UIColectionView data source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
	return [self.PFObjects count]*4;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
	static NSString *identifier = @"Cell";
	
	YMGenericCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.label.adjustsFontSizeToFitWidth = YES;
    cell.label.textColor = [UIColor whiteColor];
    
    //Data source
    int index = indexPath.row/columnNumber;
    cell.label.numberOfLines = 2;
    
    PFObject *song = [self.PFObjects objectAtIndex:index];
    
    switch (indexPath.row%columnNumber) {
        case 0:{
            NSString *info = [song objectForKey:kClassSongUsername];
//            info = [info stringByAppendingString:[NSString stringWithFormat:@"%@", [song createdAt]]];
            NSString *source = [song objectForKey:kClassSongSource];
            if (source) {
                info = [info stringByAppendingFormat:@"\n%@", source];
            }
            cell.label.text = info;
            cell.label.lineBreakMode = NSLineBreakByWordWrapping;
            cell.label.numberOfLines = 2;
            break;
        }
        case 1:{
            cell.label.numberOfLines = 2;
            cell.label.text = [song objectForKey:kClassSongTitle];
            break;
        }
        case 2:{
            cell.label.text = [song objectForKey:kClassSongAlbum];
            break;
        }
        case 3:{
            cell.label.text = [song objectForKey:kClassSongArtist];
            break;
        }
        
        default:
            break;
    }
    
	return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
   UICollectionReusableView *reusableview = nil;

   if (kind == UICollectionElementKindSectionHeader) {

       UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
       reusableview = footerview;
   }
   if (kind == UICollectionElementKindSectionFooter) {
       UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
       reusableview = footerview;
   }

   return reusableview;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    YMGenericCollectionViewCell *cell = (YMGenericCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    //Deal with NULL text
    if (!cell.label.text) {
        return;
    }
    
    NSLog(@"indexPath:%d", indexPath.row);
    
    MMNavigationController *navigationController;
    switch (indexPath.row%columnNumber) {
        case 0:{
//            NSLog(@"User Name");
            _userViewController = [[UserViewController alloc] initWithUsername:cell.label.text];
            _userViewController.previousViewController = self;
            
            MMNavigationController *navigationAddFriendsViewController = [[MMNavigationController alloc] initWithRootViewController:_userViewController];
            [self.mm_drawerController setCenterViewController:navigationAddFriendsViewController withCloseAnimation:YES completion:nil];
            break;
        }
        case 1:{
//            NSLog(@"Title");
//            YMGenericCollectionViewCell *cellTitle = cell;
//            YMGenericCollectionViewCell *cellAlbum = (YMGenericCollectionViewCell*)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]];
//            YMGenericCollectionViewCell *cellArtist = (YMGenericCollectionViewCell*)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row+2 inSection:indexPath.section]];
//            NSString *title = cellTitle.label.text? cellTitle.label.text:@" ";
//            NSString *album = cellAlbum.label.text? cellAlbum.label.text:@" ";
//            NSString *artist = cellArtist.label.text? cellArtist.label.text:@" ";
//            
//            NSDictionary *dictionary = [[NSDictionary alloc] initWithObjects:@[title, album, artist] forKeys:@[@"title", @"album", @"artist"]];
            
            //Switch to Youtube
//            SampleMusicViewController *controller = [[SampleMusicViewController alloc] initWithDictionary:dictionary];
            int index = indexPath.row/columnNumber;
            PFObject *object = _PFObjects[index];
            SampleMusicViewController *controller = [[SampleMusicViewController alloc] initWithPFObject:object];
            controller.delegate = self;
            navigationController = [[MMNavigationController alloc] initWithRootViewController:controller];
            [self.mm_drawerController setCenterViewController:navigationController withFullCloseAnimation:YES completion:nil];
            break;
        }
        case 2:{
            [self openiTuneStore:cell.label.text];
            NSLog(@"Album");
            break;
        }
        case 3:{
            [self openiTuneStore:cell.label.text];
            NSLog(@"Artist");
            break;
        }
        default:
            break;
    }
}

#pragma mark - Switch To iTune Store
- (void)openiTuneStore:(NSString*)searchInfo
{
    NSString *searchTitle = [searchInfo stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *stringURL = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&limit=1", searchTitle];
    NSURL *searchURL = [NSURL URLWithString:[stringURL stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    //Download Music
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        searchURL];
        [self performSelectorOnMainThread:@selector(fetchedData:)
                               withObject:data waitUntilDone:YES];
    });
}
- (void)fetchedData:(NSData *)responseData
{
    if (!responseData) {
        [self fetchedDataWithError];
        return;
    }
    
    NSError* error = nil;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    NSArray* results = [json objectForKey:@"results"];
    if([results count] == 0){
        [self fetchedDataWithError];
        return;
    }
    NSLog(@"results: %@", results);
    
    NSDictionary* result = [results objectAtIndex:0];
    NSString *collectionString = [result objectForKey:@"collectionViewUrl"];
    NSString *artistName = [result objectForKey:@"artistName"];
    NSString *collectionName = [result objectForKey:@"collectionName"];
    NSString *trackName = [result objectForKey:@"trackName"];

    /*Remove https://itunes.apple.com/us/album/1901/id315002203?i=315002383&uo=4 & sign*/
//    for(int i = [collectionString length]-1; i >= 0 ; i--){
//        char c = [collectionString characterAtIndex:i];
//        if(c=='&'){
//            collectionString = [collectionString substringToIndex:i];
//            break;
//        }
//    }
    
    collectionString = [collectionString stringByAppendingString:[NSString stringWithFormat:@"&at=%@", kAffiliateProgramToken]];
    NSLog(@"iTuneUrl:%@", collectionString);
    
    _iTuneUrl = [NSURL URLWithString:collectionString];
    NSString *alertString = [NSString stringWithFormat:@"You are about to switch to iTune for the song %@ in %@ by %@.", trackName, collectionName, artistName];
    
    //Before Switch Webview
    _alertBeforeSwitchToITune = [[UIAlertView alloc] initWithTitle: @"Reminder" message:alertString delegate: self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
    [_alertBeforeSwitchToITune show];
}
- (void)fetchedDataWithError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Sorry, can't find the sample song." delegate:self.delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - AlertView delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Switch Webview
    if([alertView isEqual:_alertBeforeSwitchToITune] && buttonIndex == 0){
        [[UIApplication sharedApplication] openURL:_iTuneUrl];
    }
}

#pragma mark - SampleMusicSource Delegate
- (void)listenSampleMusic:(NSString *)source
{
    NSLog(@"Source:%@", source);
}
-(void)fetchData:(UIRefreshControl*)refresh
{
    PFQuery *friendQuery = [PFQuery queryWithClassName:kClassFriend];
    [friendQuery whereKey:kClassFriendFromUsername equalTo:[[PFUser currentUser] username]];
    [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *friendObjects, NSError *error) {
        NSMutableArray *friendArray = [[NSMutableArray alloc] init];
        for(PFObject *friendObject in friendObjects){
            NSString *friend = [friendObject objectForKey:kClassFriendToUsername];
            if(friend){
                [friendArray addObject:friend];
            }
        }
        
        PFQuery *songQuery = [PFQuery queryWithClassName:kClassSong];
        songQuery.limit = 100;
        [songQuery whereKey:kClassSongUsername containedIn:friendArray];
        [songQuery orderByDescending:kClassGeneralCreatedAt]; //Get latest song
        [songQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.PFObjects = objects;
                
                refresh.attributedTitle = [[PublicMethod sharedInstance] refreshFinsihedString];
                [refresh endRefreshing];
                
                
                [self.collectionView reloadData];
            }else{
                NSLog(@"Error In Fetch Data: %@", error);
            }
        }];
    }];
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
    refresh.tintColor = [UIColor whiteColor];
    
    _saveMusicEntries = [[SaveMusicFromSources alloc] init];
    [_saveMusicEntries saveMusic];
    
    [self fetchData:self.refreshControl];
}

#pragma mark - Button Handlers
-(void)setupBarMenuButton{
    //Navigation Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = @"Live Feed";
    titleLabel.textColor = [UIColor colorWithRed:3.0/255.0
     green:49.0/255.0
     blue:107.0/255.0
     alpha:1.0];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [titleLabel sizeToFit];
    self.mm_drawerController.navigationItem.titleView = titleLabel;
    [self.mm_drawerController.navigationController.navigationBar setBarTintColor: [[Setting sharedSetting] barTintColor]];

    
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.mm_drawerController.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
//    UIBarButtonItem *rightDrawerButton = [[UIBarButtonItem alloc] initWithTitle:@"Youtube" style:UIBarButtonItemStyleBordered target:self action:@selector(rightDrawerButtonPress:)];
//    [self.mm_drawerController.navigationItem setRightBarButtonItem:rightDrawerButton animated:YES];
}
-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)saveYoutubeMusic{
    [[PublicMethod sharedInstance] authorizeGoogle:self.collectionView];
}

@end