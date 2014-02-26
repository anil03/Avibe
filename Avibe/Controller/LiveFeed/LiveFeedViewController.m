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

//Youtube
#import "YoutubeAuthorizeViewController.h"

typedef NS_ENUM(NSInteger, MMCenterViewControllerSection){
    MMCenterViewControllerSectionLeftViewState,
    MMCenterViewControllerSectionLeftDrawerAnimation,
    MMCenterViewControllerSectionRightViewState,
    MMCenterViewControllerSectionRightDrawerAnimation,
};

@interface LiveFeedViewController() <SampleMusicSourceViewDelegate, UIWebViewDelegate, UIAlertViewDelegate, GoogleOAuthDelegate>
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

//Youtube Auth
@property (nonatomic, strong) YoutubeAuthorizeViewController *youtubeAuthorizeViewController;

//Select Music to SampleMusic
@property (nonatomic, strong) MMNavigationController *navigationControllerForSampleMusic;
@property (nonatomic, strong) SampleMusicViewController *sampleMusicViewController;

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
    
    /**
     * Prepare for PFUserArray in Public Method
     * Written here depend on LiveFeed is the first view 
     * after logged in
     */
    PFQuery *queryForUsers = [PFUser query];
#warning Long time pending
    NSArray *userArray = [queryForUsers findObjects];
    if(userArray) [[PublicMethod sharedInstance].pfUserArray addObjectsFromArray:userArray];
    
    

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
            //Search displayname by username
            NSString *username = [song objectForKey:kClassSongUsername];
            PFObject *userObject = [[PublicMethod sharedInstance] searchPFUserByUsername:username];
            NSString *displayname;
            if (userObject) {
               displayname = [userObject objectForKey:kClassUserDisplayname];
            }
            if (displayname) {
                username = displayname;
            }
            
            //Display friend
            NSString *info;
            NSString *source = [song objectForKey:kClassSongSource];
            if (source) {
                info = [username stringByAppendingFormat:@"\n%@", source];
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
            cell.label.text = [song objectForKey:kClassSongArtist];
            break;
        }
        case 3:{
            cell.label.text = [song objectForKey:kClassSongAlbum];
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
    
    //Deal with nil/empty text
    if(!cell.label.text) return;
    NSString *text = [cell.label.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([text isEqualToString:@""]) return;
    
    
    NSLog(@"indexPath:%d", indexPath.row);
    
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
            //Switch to Youtube
            int index = indexPath.row/columnNumber;
            PFObject *object = _PFObjects[index];
            _sampleMusicViewController = [[SampleMusicViewController alloc] initWithPFObject:object];
            _sampleMusicViewController.delegate = self;
            _navigationControllerForSampleMusic = [[MMNavigationController alloc] initWithRootViewController:_sampleMusicViewController];
            [self.mm_drawerController setCenterViewController:_navigationControllerForSampleMusic withFullCloseAnimation:YES completion:nil];
            break;
        }
        case 2:{
            [self openiTuneStore:cell.label.text];
//            NSLog(@"Album");
            break;
        }
        case 3:{
            [self openiTuneStore:cell.label.text];
//            NSLog(@"Artist");
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



#pragma mark - Google OAuth
-(void)saveYoutubeMusic{
    NSString *key = [[PFUser currentUser] objectForKey:kClassUserGoogleUsername];
    
    if (key) {
        _youtubeAuthorizeViewController = [[YoutubeAuthorizeViewController alloc] init];
        _youtubeAuthorizeViewController.previousViewController = self;
        [_youtubeAuthorizeViewController setGOAuthDelegate:self];
        //    }
        
        //    if (!_youtubeAuthorized) {
        MMNavigationController *navigationAddFriendsViewController = [[MMNavigationController alloc] initWithRootViewController:_youtubeAuthorizeViewController];
        [self.mm_drawerController setCenterViewController:navigationAddFriendsViewController withCloseAnimation:YES completion:nil];
        
        
        [self authorizeGoogle:nil];
    }
}

- (void)authorizeGoogle:(UIView*)view {
    //    [_googleOAuth authorizeUserWithClienID:@"746869634473-hl2v6kv6e65r1ak0u6uvajdl5grrtsgb.apps.googleusercontent.com"
    //                           andClientSecret:@"_FsYBVXMeUD9BGzNmmBvE9Q4"
    //                             andParentView:self.view
    //                                 andScopes:[NSArray arrayWithObjects:@"https://www.googleapis.com/auth/userinfo.profile", nil]
    //     ];
    [self.youtubeAuthorizeViewController authorizeUserWithClienID:@"4881560502-uteihtgcnas28bcjmnh0hfrbk4chlmsa.apps.googleusercontent.com"
                                                  andClientSecret:@"R02t8Pk-59eEYy-B359-gvOY"
                                                    andParentView:view
                                                        andScopes:[NSArray arrayWithObjects:@"https://www.googleapis.com/auth/youtube", @"https://www.googleapis.com/auth/youtube.readonly",@"https://www.googleapis.com/auth/youtubepartner",@"https://www.googleapis.com/auth/youtubepartner-channel-audit", nil]
     ];
}
- (void)revokeAccess{
    return;
}

-(void)authorizationWasSuccessful{
//    _youtubeAuthorized = YES;
//    [self.tableView reloadData];
    
    [self.youtubeAuthorizeViewController callAPI:@"https://www.googleapis.com/youtube/v3/channels"
               withHttpMethod:httpMethod_GET
           postParameterNames:[NSArray arrayWithObjects:@"part",@"mine",nil] postParameterValues:[NSArray arrayWithObjects:@"contentDetails",@"true",nil]];
}
-(void)accessTokenWasRevoked{
    return;
}
-(void)errorOccuredWithShortDescription:(NSString *)errorShortDescription andErrorDetails:(NSString *)errorDetails{
    NSLog(@"%@", errorShortDescription);
    NSLog(@"%@", errorDetails);
}
-(void)errorInResponseWithBody:(NSString *)errorMessage{
    NSLog(@"%@", errorMessage);
}
-(void)responseFromServiceWasReceived:(NSString *)responseJSONAsString andResponseJSONAsData:(NSData *)responseJSONAsData{
    NSError *error;
    NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseJSONAsData
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:&error];
    if (error) {
        NSLog(@"An error occured while converting JSON data to dictionary.");
        return;
    }
//    NSLog(@"%@", dictionary);
    
    NSString *kind = [dictionary objectForKey:@"kind"];
    if ([kind rangeOfString:@"channelListResponse"].location != NSNotFound){
        NSMutableArray *items = [dictionary objectForKey:@"items"];
        NSMutableDictionary *contentDetails = [items[0] objectForKey:@"contentDetails"];
        NSMutableDictionary *relatedPlaylists = [contentDetails objectForKey:@"relatedPlaylists"];
        //likes, uploads, watchHistory, favorites, watchLater
        NSString *watchHistory = [relatedPlaylists objectForKey:@"watchHistory"];
        NSLog(@"WatchHistory playListID:%@", watchHistory);
        
        //Get playlist items
        [self.youtubeAuthorizeViewController callAPI:@"https://www.googleapis.com/youtube/v3/playlistItems"
                   withHttpMethod:httpMethod_GET
               postParameterNames:[NSArray arrayWithObjects:@"part",@"playlistId",nil] postParameterValues:[NSArray arrayWithObjects:@"snippet",watchHistory,nil]];
        
    }
    
    if ([kind rangeOfString:@"playlistItemListResponse"].location != NSNotFound) {
        NSMutableArray *items = [dictionary objectForKey:@"items"];
        
        NSMutableArray *videoIds = [[NSMutableArray alloc] init];
        
        for(NSMutableDictionary *item in items){
            NSMutableDictionary *snippet = [item objectForKey:@"snippet"];
            //Snippet: desciption, thumbnails, publishedAt, channelTitle, playlistId, channelId, resourceId, title
            //            NSString *title = [snippet objectForKey:@"title"];
            //Thumbnails
            NSMutableDictionary *thumbnails = [snippet objectForKey:@"thumbnails"];
            NSMutableDictionary *high = [thumbnails objectForKey:@"high"];
            NSString *thumbnailHighURL = [high objectForKey:@"url"];
            NSString *videoId;
            if (snippet && snippet[@"resourceId"]) {
                videoId = snippet[@"resourceId"][@"videoId"];
            }
            
            //            NSLog(@"Title:%@, ThumbnailUrl:%@", title, thumbnailHighURL);
            
            //Get VideoId type
            if (videoId) {
                [videoIds addObject:videoId];
            }
        }
        
        NSString *videoIdCall = [videoIds componentsJoinedByString:@","];
        //Call API for Video categoryId
        if (videoIdCall) {
            [self.youtubeAuthorizeViewController callAPI:@"https://www.googleapis.com/youtube/v3/videos"
                       withHttpMethod:httpMethod_GET
                   postParameterNames:[NSArray arrayWithObjects:@"part",@"id",nil] postParameterValues:[NSArray arrayWithObjects:@"snippet",videoIdCall,nil]];
        }
    }
    
    if ([kind rangeOfString:@"videoListResponse"].location != NSNotFound){
        NSMutableArray *entries = [[NSMutableArray alloc] init];
        
        NSMutableArray *items = [dictionary objectForKey:@"items"];
        
        for(NSMutableDictionary *item in items){
            NSMutableDictionary *snippet = [item objectForKey:@"snippet"];
            NSString *categoryId = snippet[@"categoryId"];
            
            if ([categoryId isEqualToString:@"10"]) {
                NSString *title;
                if (snippet) {
                    title = snippet[@"title"];
                }
                NSString *thumbnailUrl;
                if (snippet && snippet[@"thumbnails"] && snippet[@"thumbnails"][@"high"]) {
                    thumbnailUrl = snippet[@"thumbnails"][@"high"][@"url"];
                }
                
                //Save to Parse
                NSMutableDictionary *entry = [[NSMutableDictionary alloc] init];
                if(title) [entry setObject:title forKey:@"title"];
                if(thumbnailUrl) [entry setObject:thumbnailUrl forKey:@"url"];
                [entries addObject:entry];
            }
        }
        
        [SaveMusicFromSources saveYoutubeEntry:entries];
        
    }
}

#pragma mark - View set up & button
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationPortrait | UIInterfaceOrientationPortraitUpsideDown;
}

@end