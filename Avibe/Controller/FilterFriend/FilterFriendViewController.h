//
//  FilterFriendViewController.h
//  Avibe
//
//  Created by Yuhua Mai on 3/27/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterFriendViewControllerDelegate <NSObject>

- (void)updateWithSelectedFriendsArrayWithUsername:(NSArray*)firendsArrayWithUsername;

@end

@interface FilterFriendViewController : UITableViewController

@property (nonatomic,weak) id<FilterFriendViewControllerDelegate> delegate;

@end
