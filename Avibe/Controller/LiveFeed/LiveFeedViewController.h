//
//  LiveFeedViewController.h
//  Beet
//
//  Created by Yuhua Mai on 12/7/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SideMenuRowViewController.h"
#import "YMGenericTableViewController.h"

@protocol LiveFeedViewControllerDelegate <NSObject>

- (NSString*)getLastFMAccount;

@end

@interface LiveFeedViewController : UICollectionViewController

@property (nonatomic, weak) id<LiveFeedViewControllerDelegate> delegate;

@end
