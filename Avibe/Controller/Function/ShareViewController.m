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

@property (nonatomic, strong) NSArray *songs;

@end

@implementation ShareViewController

@synthesize songs = _songs;



- (id)init
{
    self = [super initWithCollectionViewLayout:nil];
    
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
	
	[self setupRefreshControl];
	[self refreshView:self.refreshControl];
}

#pragma mark - UICollection view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 4;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
	return 5;
 //    return recipeImages.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
	static NSString *identifier = @"Cell";
	
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
	cell.backgroundColor = [[Setting sharedSetting] sharedCellColor];

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
	PFQuery *postQuery = [PFQuery queryWithClassName:@"Favorite"];
	[postQuery whereKey:@"author" equalTo:[[PFUser currentUser] username]];
	[postQuery orderByDescending:@"updatedAt"];

    // Run the query
	[postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error) {
            //Save results and update the table
//			self.PFObjects = objects;
//			[self.tableView reloadData];
			
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