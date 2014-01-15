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

#import "Setting.h"


@interface ShareViewController ()

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
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
        
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
	
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
	cell.backgroundColor = [UIColor grayColor];
    
    PFObject *song = [_PFObjects objectAtIndex:indexPath.row];
    NSString *title = [song objectForKey:@"title"];
    NSString *artist = [song objectForKey:@"artist"];
    NSString *album = [song objectForKey:@"album"];
    NSString *user = [song objectForKey:@"user"];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, cell.frame.size.width, 60)];
    titleLabel.text = [NSString stringWithFormat:@"\"%@\" by %@", title, artist];
    titleLabel.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
    titleLabel.numberOfLines = 2;
    [cell.contentView addSubview:titleLabel];
    UIImage *image = [UIImage imageNamed:@"default_album.png"];
    cell.backgroundView = [[UIImageView alloc] initWithImage:image];
    
 //Not implement ImageView yet
 //    UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:100];
 //    recipeImageView.image = [UIImage imageNamed:[recipeImages objectAtIndex:indexPath.row]];
 //    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-frame.png"]];
	
	return cell;
}

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
    
    [self.collectionView addSubview:self.refreshControl];
//    self.collectionView.alwaysBounceVertical = YES;
}

-(void)refreshView:(UIRefreshControl *)refresh {
	refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
	
    // custom refresh logic would be placed here...
	[self fetchData:refresh];
	
	
}

-(void)fetchData:(UIRefreshControl*)refresh
{
    //Create query for all Post object by the current user
	PFQuery *postQuery = [PFQuery queryWithClassName:@"Share"];
	[postQuery orderByDescending:@"updatedAt"];

    // Run the query
	[postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error) {
            //Save results and update the table
			_PFObjects = objects;
			[self.collectionView reloadData];
			
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateFormat:@"MMM d, h:mm a"];
			NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",[formatter stringFromDate:[NSDate date]]];
			refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
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