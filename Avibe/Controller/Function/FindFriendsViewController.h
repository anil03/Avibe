//
//  AddFriendsViewController.h
//  Beet
//
//  Created by Yuhua Mai on 12/27/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FindFriendsViewControllerDelegate <NSObject>


@end

@interface FindFriendsViewController : UITableViewController

@property (nonatomic, weak) id<FindFriendsViewControllerDelegate> delegate;

@property (nonatomic, weak) UIViewController *friendsViewController;

@end
