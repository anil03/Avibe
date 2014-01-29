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
#import "SampleMusicViewController.h"
#import "SampleMusicYoutubeViewController.h"

#import "Song.h"

#import "YMGenericTableViewCell.h"
#import "YMGenericCollectionViewCell.h"
#import "YMGenericCollectionReusableHeaderView.h"
#import "YMGenericCollectionViewFlowLayout.h"

#import "Setting.h"
#import "PublicMethod.h"

#import "BackgroundImageView.h"
#import "SampleMusicSourceView.h"
#import "UserViewController.h"
#import "SaveMusicEntries.h"

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
@property (nonatomic, strong) SaveMusicEntries *saveMusicEntries;
@end

@implementation LiveFeedViewController

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupBarMenuButton];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    
    //Setup Refresh Control
    [self setupRefreshControl];
    [self refreshView:self.refreshControl];


}

#pragma mark - Table view data source
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //Deleting, dosomething
        
    }
}

//#pragma mark Segue
//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([[segue identifier] isEqualToString:@"SampleMusicSegue"])
//    {
//        // Get reference to the destination view controller
//        SampleMusicViewController *controller = [segue destinationViewController];
//        //        controller.song = [[Song alloc] init];
//        controller.pfObject = sender;
//        
//        //        controller.song.title = [sender objectForKey:@"title"];
//        //        controller.song.album = [sender objectForKey:@"album"];
//        //        controller.song.artist = [sender objectForKey:@"artist"];
//        
//        
//    }
//}

#pragma mark - UICollection view data source

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
    
//    UIButton *button = [[UIButton alloc] initWithFrame:cell.frame];
//    button.backgroundColor = [UIColor greenColor];
//    [cell addSubview:button];
//    [cell bringSubviewToFront:button];
    
    //Gesture
//    UITapGestureRecognizer *touchOnView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchView:)];
//    [touchOnView setNumberOfTapsRequired:1];
//    [touchOnView setNumberOfTouchesRequired:1];
//    [cell addGestureRecognizer:touchOnView];
    
	
    //Data source
    int index = indexPath.row/columnNumber;
    
    PFObject *song = [self.PFObjects objectAtIndex:index];
    
    switch (indexPath.row%columnNumber) {
        case 0:{
            cell.label.text = [song objectForKey:@"user"];
            break;
        }
        case 1:{
            cell.label.text = [song objectForKey:@"title"];
            break;
        }
        case 2:{
            cell.label.text = [song objectForKey:@"album"];
            break;
        }
        case 3:{
            cell.label.text = [song objectForKey:@"artist"];
            break;
        }
        
        default:
            break;
    }
    
    //Deal with NULL text
    if (!cell.label.text) {
        cell.label.text = @"N/A";
    }
    
    //Not implement ImageView yet
    //    UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:100];
    //    recipeImageView.image = [UIImage imageNamed:[recipeImages objectAtIndex:indexPath.row]];
    //    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-frame.png"]];
	
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
//    NSLog(@"Select %d", indexPath.row);
    
    YMGenericCollectionViewCell *cell = (YMGenericCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
//    NSLog(@"%@", cell.label.text);
    
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
            YMGenericCollectionViewCell *cellTitle = cell;
            YMGenericCollectionViewCell *cellAlbum = (YMGenericCollectionViewCell*)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]];
            YMGenericCollectionViewCell *cellArtist = (YMGenericCollectionViewCell*)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row+2 inSection:indexPath.section]];
            
            NSDictionary *dictionary = [[NSDictionary alloc] initWithObjects:@[cellTitle.label.text, cellAlbum.label.text, cellArtist.label.text] forKeys:@[@"title", @"album", @"artist"]];
            
            //Switch to Youtube
            SampleMusicYoutubeViewController *controller = [[SampleMusicYoutubeViewController alloc] initWithDictionary:dictionary];
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
    
    _iTuneUrl = [NSURL URLWithString:collectionString];
//    NSURLRequest *request = [NSURLRequest requestWithURL:previewUrl];
    NSString *alertString = [NSString stringWithFormat:@"You are about to switch to iTune for the song %@ in %@ by %@.", trackName, collectionName, artistName];
    
    //Before Switch Webview
    _alertBeforeSwitchToITune = [[UIAlertView alloc] initWithTitle: @"Reminder" message:alertString delegate: self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
    [_alertBeforeSwitchToITune show];
    
    
    
//    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.collectionView.frame];
//    webView.delegate = self;
//    [webView loadRequest:request];
//    webView.hidden = NO;
//    [self.collectionView addSubview:webView];
  
}
- (void)fetchedDataWithError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Sorry, can't find the sample song." delegate:self.delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Switch Webview
    if([alertView isEqual:alertView] && buttonIndex == 0){
        [[UIApplication sharedApplication] openURL:_iTuneUrl];
    }
}
//#pragma mark - UIWebView Delegate
//- (void)webViewDidStartLoad:(UIWebView *)webView
//{
//    
//}
//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//}

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
        [songQuery orderByDescending:@"updateAt"]; //Get latest song
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
    
    // custom refresh logic would be placed here...
    
    _saveMusicEntries = [[SaveMusicEntries alloc] init];
    [_saveMusicEntries saveMusic];
    
    [self fetchData:self.refreshControl];
//    [self updateSongInParse];
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
    
//    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editSong)];
    
    [self.mm_drawerController.navigationItem setRightBarButtonItem:nil];
}

-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)editSong
{
    if(self.editing)
    {
        [super setEditing:NO animated:NO];
        [self setEditing:NO animated:NO];
        [self.mm_drawerController.navigationItem.leftBarButtonItem setTitle:@"Edit"];
        [self.mm_drawerController.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStylePlain];
    }
    else
    {
        [super setEditing:YES animated:YES];
        [self setEditing:YES animated:YES];
        [self.mm_drawerController.navigationItem.leftBarButtonItem setTitle:@"Done"];
        [self.mm_drawerController.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStyleDone];
    }
}





@end