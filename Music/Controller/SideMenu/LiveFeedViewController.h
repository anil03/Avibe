//
//  LiveFeedViewController.h
//  Beet
//
//  Created by Yuhua Mai on 12/7/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MMExampleViewController.h"

@interface LiveFeedViewController : MMExampleViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView * tableView;

- (id)initWithSelf:(UIViewController*)controller;

@end
