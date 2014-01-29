//
//  SampleMusicYoutubeViewController.h
//  Avibe
//
//  Created by Yuhua Mai on 1/14/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SampleMusicViewController : UIViewController

@property (nonatomic, weak) UIViewController *delegate;

- (id)initWithDictionary:(NSDictionary*)dictionary;


@end
