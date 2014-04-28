//
//  UserShareViewController.m
//  Avibe
//
//  Created by Yuhua Mai on 1/20/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "UserShareViewController.h"
#import "PublicMethod.h"
#import "UIViewController+MMDrawerController.h"

@interface UserShareViewController ()


@end

@implementation UserShareViewController

- (id)initWithUsername:(NSString*)username
{
    self.username = username;
    
    self.column = 3;
    self.row = 5;
    float cellWidth = [UIScreen mainScreen].bounds.size.width/self.column-1;
    float cellHeight = [UIScreen mainScreen].bounds.size.height/self.row;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(cellWidth, cellHeight)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:0.5f]; //Between items
    [flowLayout setMinimumLineSpacing:5.5f]; //Between lines
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0); //Between sections
    
    self = [super initWithCollectionViewLayout:flowLayout];
    if(self){
        [self.collectionView registerClass:[ShareCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
        
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.backgroundColor = [UIColor blackColor];
        
        //BackgroundView
        UIView *backgroundView = [[BackgroundImageView alloc] initWithFrame:self.collectionView.frame];
        self.collectionView.backgroundView = backgroundView;
    }
    return self;
}
-(void)fetchData:(UIRefreshControl*)refresh
{
    PFQuery *postQuery = [PFQuery queryWithClassName:@"Share"];
    [postQuery whereKey:kClassSongUsername equalTo:self.username];
    [postQuery orderByDescending:@"updatedAt"];
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.PFObjects = objects;
            
            self.albumImages = [[NSMutableArray alloc] init];
            for(PFObject *object in objects){
                PFFile *albumImage = [object objectForKey:@"albumImage"];
                NSData *imageData = [albumImage getData];
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                if(!image){
                    image = [UIImage imageNamed:@"default_album.png"];
                }
                [self.albumImages addObject:image];
            }
            
            refresh.attributedTitle = [[PublicMethod sharedInstance] refreshFinsihedString];
            [self.collectionView reloadData];
            [refresh endRefreshing];
        }
    }];
}

#pragma mark - Button Handlers
-(void)setupMenuButton{
    //Navigation Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    NSString *titleText = self.username;
    int titleLength = 8;
    if([titleText length] > titleLength) titleText = [[titleText substringToIndex:titleLength]  stringByAppendingString:@"..."];
    titleLabel.text = [NSString stringWithFormat:@"%@'s Share", titleText];
    titleLabel.textColor = [UIColor colorWithRed:3.0/255.0
                                           green:49.0/255.0
                                            blue:107.0/255.0
                                           alpha:1.0];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [titleLabel sizeToFit];
    self.mm_drawerController.navigationItem.titleView = titleLabel;
    
    /*
     MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
     [self.mm_drawerController.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
     */
    UIBarButtonItem * leftDrawerButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    self.mm_drawerController.navigationItem.leftBarButtonItem = leftDrawerButton;
    
    UIBarButtonItem * rightDrawerButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(popCurrentView)];
    [self.mm_drawerController.navigationItem setRightBarButtonItem:rightDrawerButton];
}
-(void)leftDrawerButtonPress:(id)sender{
	[self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}
- (void)popCurrentView
{
    [self.mm_drawerController setCenterViewController:self.previousViewController];
}

@end
