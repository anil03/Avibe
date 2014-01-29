//
//  LiveFeedViewController.h
//  Beet
//
//  Created by Yuhua Mai on 12/7/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SideMenuRowViewController.h"
#import "YMTableViewController.h"

@protocol LiveFeedViewControllerDelegate <NSObject>

- (NSString*)getLastFMAccount;

@end

@interface LiveFeedViewController : UICollectionViewController

@property (nonatomic, weak) UIViewController *delegate;

@end
