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
#import "Song.h"

#import "YMGenericTableViewCell.h"
#import "YMGenericCollectionViewCell.h"
#import "YMGenericCollectionReusableHeaderView.h"
#import "YMGenericCollectionViewFlowLayout.h"

#import "Setting.h"

#import "XMLParser.h"

#import "BackgroundImageView.h"

typedef NS_ENUM(NSInteger, MMCenterViewControllerSection){
    MMCenterViewControllerSectionLeftViewState,
    MMCenterViewControllerSectionLeftDrawerAnimation,
    MMCenterViewControllerSectionRightViewState,
    MMCenterViewControllerSectionRightDrawerAnimation,
};

static NSString *kURLString = @"http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=myhgew&api_key=55129edf3dc293c4192639caedef0c2e&limit=10";


@interface LiveFeedViewController()<XMLParserDelegate>

@property (weak, atomic) UIViewController *viewController;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *CurrPlaying;

@property (nonatomic, strong) XMLParser *parser;
@property (nonatomic, strong) NSMutableArray *XMLData;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@property (nonatomic, strong) NSArray *PFObjects;


@end

@implementation LiveFeedViewController



- (id)initWithSelf:(UIViewController*)controller
{
    self.viewController = controller;
    return [self init];
}

- (id)init
{
//    self = [super init];
    
    UICollectionViewFlowLayout *flowLayout = [[YMGenericCollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(([UIScreen mainScreen].bounds.size.width-25)/4, 30)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:5.0f]; //Between items
    [flowLayout setMinimumLineSpacing:10.0f]; //Between lines
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 5, 5); //Between sections
    flowLayout.headerReferenceSize = CGSizeMake(50, 30); //set header
//    flowLayout.footerReferenceSize = CGSizeMake(50, 30);
    
    self = [super initWithCollectionViewLayout:flowLayout];
    
    if (self) {
        [self setRestorationIdentifier:@"MMExampleCenterControllerRestorationKey"];
        
        //UICollectionview
        [self.collectionView registerClass:[YMGenericCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
        [self.collectionView registerClass:[YMGenericCollectionReusableHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
        [self.collectionView registerClass:[YMGenericCollectionReusableHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
        
        //BackgroundView
        UIView *backgroundView = [[BackgroundImageView alloc] initWithFrame:self.collectionView.backgroundView.frame];
//        backgroundView.backgroundColor = [UIColor redColor];
        self.collectionView.backgroundView = backgroundView;
//        [self.collectionView setBackgroundColor:[[Setting sharedSetting] sharedBackgroundColor]];
        
        self.collectionView.delegate=self;
        self.collectionView.dataSource=self;
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupBarMenuButton];
    
    //Setup Scrobbler URL
    if(self.delegate && [self.delegate respondsToSelector:@selector(getLastFMAccount)]){
        if ([self.delegate getLastFMAccount] == nil) {
            return;
        }
        kURLString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=%@&api_key=55129edf3dc293c4192639caedef0c2e&limit=10", [self.delegate getLastFMAccount]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //UICollectionView

    
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
	
    //Data source
    int columnNumber = 4;
    int index = indexPath.row/columnNumber;
    
    PFObject *song = [self.PFObjects objectAtIndex:index];
//    dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[song objectForKey:@"title"], @"title", [song objectForKey:@"album"], @"album", [song objectForKey:@"artist"], @"artist", [song objectForKey:@"user"], @"user", nil];
    
    cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    
    switch (indexPath.row%columnNumber) {
        case 0:{
//            cell.backgroundColor = [[Setting sharedSetting] primary1Color];
            cell.label.text = [song objectForKey:@"title"];
            break;
        }
        case 1:{
//            cell.backgroundColor = [[Setting sharedSetting] sharedCellColor];
            cell.label.text = [song objectForKey:@"album"];
            break;
        }
        case 2:{
//            cell.backgroundColor = [[Setting sharedSetting] sharedCellColor];
            cell.label.text = [song objectForKey:@"artist"];
            break;
        }
        case 3:{
//            cell.backgroundColor = [[Setting sharedSetting] sharedCellColor];
            cell.label.text = [song objectForKey:@"user"];
            break;
        }
        default:
            break;
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
//       footerview.backgroundColor = [UIColor greenColor];
       
       reusableview = footerview;
       
// RecipeCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
// NSString *title = [[NSString alloc]initWithFormat:@"Recipe Group #%i", indexPath.section + 1];
// headerView.title.text = title;
// UIImage *headerImage = [UIImage imageNamed:@"header_banner.png"];
// headerView.backgroundImage.image = headerImage;
//
// reusableview = headerView;

   }

   if (kind == UICollectionElementKindSectionFooter) {

       UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];

       reusableview = footerview;

   }

   return reusableview;
}

#pragma mark Bar Button
- (void)updateSongInParse {
    //Save Scrobbler Music from XML Parser
    [self setupXMLParserAndParse]; //Update XMLData
    
    //iPod Music
    MPMediaItem *currentPlayingSong = [[MPMusicPlayerController iPodMusicPlayer] nowPlayingItem];
    if (currentPlayingSong){
        PFObject *songRecord = [PFObject objectWithClassName:@"Song"];
        [songRecord setObject:[currentPlayingSong valueForProperty:MPMediaItemPropertyTitle]  forKey:@"title"];
        [songRecord setObject:[currentPlayingSong valueForProperty:MPMediaItemPropertyAlbumTitle] forKey:@"album"];
        [songRecord setObject:[currentPlayingSong valueForProperty:MPMediaItemPropertyArtist] forKey:@"artist"];
        [songRecord setObject:[[PFUser currentUser] username] forKey:@"user"];
        
        [self.XMLData addObject:songRecord];
    }
    

    
    //Get rid of duplicated data then save
    [self filterDuplicatedDataToSaveInParse:self.XMLData];
    
    //NO more songs need to be added
    /*if ([dataToSave count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Congratulations!" message: @"All songs have been updated." delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }*/
    }



    - (void)filterDuplicatedDataToSaveInParse:(NSMutableArray*)XMLData
    {
        NSMutableArray *dataToSave = [[NSMutableArray alloc] init];
        __block int numberOfDuplicated = 0;
        
        
        PFQuery *postQuery = [PFQuery queryWithClassName:@"Song"];
        [postQuery whereKey:@"user" equalTo:[[PFUser currentUser] username]];
        postQuery.limit = 1000;
        [postQuery findObjectsInBackgroundWithBlock:^(NSArray *fetechObjects, NSError *error) {
            BOOL songExisted = NO;
            
            for(PFObject *pfToSave in XMLData){
                songExisted = NO;
                
                NSString *newTitle = [pfToSave objectForKey:@"title"];
                NSString *newArtist = [pfToSave objectForKey:@"artist"];
                NSString *newAlbum = [pfToSave objectForKey:@"album"];
                
            /* Too slow in background
             PFQuery *postQuery = [PFQuery queryWithClassName:@"Song"];
             [postQuery whereKey:@"user" equalTo:[[PFUser currentUser] username]];
             [postQuery whereKey:@"title" containsString:newTitle];
             [postQuery whereKey:@"artist" containsString:newArtist];
             [postQuery whereKey:@"album" containsString:newAlbum];
             
             if ([postQuery countObjects] > 0) {
             songExisted = YES;
             }
             */
             
             
             for(PFObject *pf in fetechObjects){
                NSString *existingTitle = [pf objectForKey:@"title"];
                NSString *existingArtist = [pf objectForKey:@"artist"];
                NSString *existingAlbum = [pf objectForKey:@"album"];
                
                if ([newTitle isEqualToString:existingTitle] && [newArtist isEqualToString:existingArtist] && [newAlbum isEqualToString:existingAlbum]) {
                    //Duplicated Object
                    numberOfDuplicated++;
//                    NSLog(@"Duplicated %@ - %@ - %@", newTitle, newArtist, newAlbum);
                    songExisted = YES;
                    break;
                }
            }
            
            
            if (songExisted) {
                continue;
            }
            [dataToSave addObject:pfToSave];
        }
        
        
        [PFObject saveAllInBackground:dataToSave block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Save XML Data succeeded!");
                NSLog(@"Number of duplicated songs: %d", numberOfDuplicated);

                //Fetch data and Update table view
                [self fetchData:self.refreshControl];
            }else{
                NSLog(@"Error Saving XML Data: %@", error);
            }
        }];

    }];




}

-(void)fetchData:(UIRefreshControl*)refresh
{
    //Create query for all Post object by the current user
    PFQuery *postQuery = [PFQuery queryWithClassName:@"Song"];
    postQuery.limit = 20;
    //    [postQuery whereKey:@"author" equalTo:[[PFUser currentUser] username]];
    [postQuery orderByDescending:@"updatedAt"];
    // Run the query
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //Save results and update the table
            self.PFObjects = objects;
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMM d, h:mm a"];
            NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",[formatter stringFromDate:[NSDate date]]];
            refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
            [refresh endRefreshing];
            
            [_spinner stopAnimating];

            [self.collectionView reloadData];
//            [self.tableView reloadData];
        }else{
            NSLog(@"Error In Fetch Data: %@", error);
        }
    }];
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
    refresh.tintColor = [UIColor whiteColor];
    
    // custom refresh logic would be placed here...
    [_spinner startAnimating];
    [self updateSongInParse];
    
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
    
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.mm_drawerController.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
//    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editSong)];
    
//    [self.mm_drawerController.navigationItem setRightBarButtonItem:barButton];
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
//        [self.tableView reloadData];
        [self.mm_drawerController.navigationItem.leftBarButtonItem setTitle:@"Edit"];
        [self.mm_drawerController.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStylePlain];
    }
    else
    {
        [super setEditing:YES animated:YES];
        [self setEditing:YES animated:YES];
//        [self.tableView reloadData];
        [self.mm_drawerController.navigationItem.leftBarButtonItem setTitle:@"Done"];
        [self.mm_drawerController.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStyleDone];
    }
}



#pragma mark - XML method
- (void)setupXMLParserAndParse
{
    //Setup XMLParser
    self.XMLData = nil; //clear previous data
    self.XMLData = [[NSMutableArray alloc] init];
    NSURL *url = [NSURL URLWithString:kURLString];
    self.parser = [[XMLParser alloc] initWithURL:url AndData:self.XMLData];
    self.parser.delegate = self;
    [self.parser startParsing];
}

- (void)finishParsing
{
    NSLog(@"Parse Finish.");
    
}

@end