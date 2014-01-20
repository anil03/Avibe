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
#import "UIViewController+MMDrawerController.h"

#import "SampleMusicViewController.h"
#import "ShareCollectionViewCell.h"
#import "Setting.h"
#import "PublicMethod.h"
#import "SampleMusic_iTune.h"


@interface ShareViewController () <SampleMusic_iTuneDelegate>

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@property (nonatomic, strong) NSArray *songs;

@property (nonatomic, strong) NSArray *PFObjects;

@property int column;
@property int row;

@end

@implementation ShareViewController

@synthesize songs = _songs;

- (id)init
{
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
	
    //Navigation
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
    NSString *album = [song objectForKey:@"album"];
    NSString *user = [song objectForKey:@"user"];
    PFFile *albumImage = [song objectForKey:@"albumImage"];
    
    cell.titleLabel.text = [NSString stringWithFormat:@"\"%@\" by %@", title, artist];

    NSData *imageData = [albumImage getData];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    if (!image) {
        image = [UIImage imageNamed:@"default_album.png"];
    }
    cell.backgroundView = [[UIImageView alloc] initWithImage:image];
    
    //SetUp BackgroundView
    /*
    SampleMusic_iTune *sampleMusic = [[SampleMusic_iTune alloc] initWithIndexPath:indexPath];
    sampleMusic.delegateForIndexPath = self;
    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:@[title] forKeys:@[@"title"]];
    [sampleMusic startSearch:dict];
    */
     
 //Not implement ImageView yet
 //    UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:100];
 //    recipeImageView.image = [UIImage imageNamed:[recipeImages objectAtIndex:indexPath.row]];
 //    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-frame.png"]];
	
	return cell;
}

/*
#pragma mark - BackgroundImage Delegate
- (void)finishFetchData:(NSData *)song andInfo:(NSDictionary *)songInfo andIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    NSURL *imageUrl = [NSURL URLWithString:[songInfo objectForKey:@"imageURL"]];
    NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
    UIImage *image = [UIImage imageWithData:imageData];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.backgroundView.frame];
    [imageView setImage:image];
    
    cell.backgroundView = imageView;
    [self.collectionView reloadData];
}
*/

// - (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
// {
// UICollectionReusableView *reusableview = nil;
// 
// if (kind == UICollectionElementKindSectionHeader) {
// 
// RecipeCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
// NSString *title = [[NSString alloc]initWithFormat:@"Recipe Group #%i", indexPath.section + 1];
// headerView.title.text = title;
// UIImage *headerImage = [UIImage imageNamed:@"header_banner.png"];
// headerView.backgroundImage.image = headerImage;
// 
// reusableview = headerView;
// 
// }
//
// if (kind == UICollectionElementKindSectionFooter) {
// 
// UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
// 
// reusableview = footerview;
// 
// }
// 
// return reusableview;
// }



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
-(void)fetchData:(UIRefreshControl*)refresh
{
    //Create query for all Post object by the current user
	PFQuery *postQuery = [PFQuery queryWithClassName:@"Share"];
	[postQuery orderByDescending:@"updatedAt"];
	[postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error) {
            //Save results and update the table
			_PFObjects = objects;
			[self.collectionView reloadData];
			
			refresh.attributedTitle = [[PublicMethod sharedInstance] refreshFinsihedString];
			[refresh endRefreshing];
		}
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