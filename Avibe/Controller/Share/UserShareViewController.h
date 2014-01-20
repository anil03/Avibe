//
//  UserShareViewController.h
//  Avibe
//
//  Created by Yuhua Mai on 1/20/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "ShareViewController.h"

@interface UserShareViewController : ShareViewController

@property (nonatomic, weak) UIViewController *previousViewController;

- (id)initWithUsername:(NSString*)username;

@end
