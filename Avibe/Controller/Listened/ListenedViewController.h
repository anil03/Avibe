//
//  ListenedViewController.h
//  Beet
//
//  Created by Yuhua Mai on 12/7/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YMTableViewController.h"

@interface ListenedViewController : YMTableViewController

@property (nonatomic, weak) UIViewController *previousViewController;

- (id)initWithUsername:(NSString*)username;

@end
