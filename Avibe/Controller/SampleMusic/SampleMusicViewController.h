//
//  SampleMusicYoutubeViewController.h
//  Avibe
//
//  Created by Yuhua Mai on 1/14/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SampleMusicViewController : UIViewController

@property (nonatomic, strong) UIViewController *delegate;

- (id)initWithDictionary:(NSDictionary*)dictionary;
- (id)initWithPFObject:(PFObject*)object;

/**
 * Really bad practice
 */
-(void)setupNavigationBar;

@end
