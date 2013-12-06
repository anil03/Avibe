//
//  LiveFeedViewController.h
//  Beet
//
//  Created by Yuhua Mai on 12/5/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMDrawerController.h"

@interface LiveFeedViewController : MMDrawerController


-(id)initWithCenterViewController:(UIViewController *)centerViewController leftDrawerViewController:(UIViewController *)leftDrawerViewController rightDrawerViewController:(UIViewController *)rightDrawerViewController;

@end

