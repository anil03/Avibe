//
//  ShareViewController.h
//  Beet
//
//  Created by Yuhua Mai on 12/7/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SideMenuRowViewController.h"
#import "YMGenericTableViewController.h"
#import "YMGenericCollectionViewController.h"
#import "ShareCollectionViewCell.h"
#import "BackgroundImageView.h"

@interface ShareViewController : UICollectionViewController

@property (nonatomic, strong) NSArray *PFObjects;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property int column;
@property int row;

- (void)setupRefreshControl;
-(void)refreshView:(UIRefreshControl *)refresh;

@end
