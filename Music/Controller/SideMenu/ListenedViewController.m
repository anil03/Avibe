//
//  ListenedViewController.m
//  Beet
//
//  Created by Yuhua Mai on 12/7/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "ListenedViewController.h"

#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"

#import "SampleMusicViewController.h"


@interface ListenedViewController ()
{
    NSArray *recipeImages;
}

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSArray *songs;

@end

@implementation ListenedViewController

@synthesize songs = _songs;

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [aFlowLayout setItemSize:CGSizeMake(150, 100)];
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    
    self = [super initWithCollectionViewLayout:aFlowLayout];
    
    if(self){
        
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
    
    
    
	[self setupRefreshControl];
    [self refreshView:self.refreshControl];
    
    
    recipeImages = [NSArray arrayWithObjects:@"angry_birds_cake.jpg", @"creme_brelee.jpg", @"egg_benedict.jpg", @"full_breakfast.jpg", @"green_tea.jpg", @"ham_and_cheese_panini.jpg", @"ham_and_egg_sandwich.jpg", @"hamburger.jpg", @"instant_noodle_with_egg.jpg", @"japanese_noodle_with_pork.jpg", @"mushroom_risotto.jpg", @"noodle_with_bbq_pork.jpg", @"starbucks_coffee.jpg", @"thai_shrimp_cake.jpg", @"vegetable_curry.jpg", @"white_chocolate_donut.jpg", nil];
}

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.PFObjects count];
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
//    PFObject *song = [_songs objectAtIndex:indexPath.row];
//    cell.textLabel.text = [song objectForKey:@"title"];
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", [song objectForKey:@"title"], [song objectForKey:@"album"]];
//    
//    return cell;
//}
*/

#pragma mark - UICollection view data source
- (NSInteger)numberOfSections
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
//    return 5;
    return recipeImages.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    //Not implement ImageView yet
    UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:100];
    recipeImageView.image = [UIImage imageNamed:[recipeImages objectAtIndex:indexPath.row]];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-frame.png"]];
    
    return cell;
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

    // custom refresh logic would be placed here...
    [self fetchData:refresh];
    
    
}

-(void)fetchData:(UIRefreshControl*)refresh
{
    //Create query for all Post object by the current user
    PFQuery *postQuery = [PFQuery queryWithClassName:@"Song"];
    postQuery.limit = 15;
    [postQuery whereKey:@"user" equalTo:[[PFUser currentUser] username]];
    [postQuery orderByDescending:@"updatedAt"];
    
    // Run the query
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //Save results and update the table
            
//            self.PFObjects = objects;
//            [self.tableView reloadData];
            
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
    titleLabel.text = @"Listened";
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
