//
//  UserViewController.h
//  Beet
//
//  Created by Yuhua Mai on 12/7/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SideMenuRowViewController.h"
#import "ListenedViewController.h"
#import "UserShareViewController.h"

@protocol UserViewControllerDelegate <NSObject>

- (void)setLastFMAccount:(NSString*)account;
- (NSString*)getLastFMAccount;


@end

@interface UserViewController : SideMenuRowViewController
@property (nonatomic, strong) NSString *username;

@property (nonatomic, weak) id<UserViewControllerDelegate> delegate;
@property (nonatomic, weak) UIViewController *previousViewController;
@property (nonatomic, strong) ListenedViewController *listenedViewController;
@property (nonatomic, strong) UserShareViewController *userShareViewController;

- (id)initWithUsername:(NSString*)username;

@end
