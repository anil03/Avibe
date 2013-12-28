//
//  AddFriendsViewController.h
//  Beet
//
//  Created by Yuhua Mai on 12/27/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddFriendsViewControllerDelegate <NSObject>


@end

@interface AddFriendsViewController : UIViewController

@property (nonatomic, weak) id<AddFriendsViewControllerDelegate> delegate;

@property (nonatomic, weak) UIViewController *friendsViewController;

@end
