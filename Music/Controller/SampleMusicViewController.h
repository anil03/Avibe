//
//  SampleMusicViewController.h
//  AddCurrentMusicThenPlaySample
//
//  Created by Yuhua Mai on 11/24/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"

@interface SampleMusicViewController : UIViewController

@property (nonatomic, strong) Song *song;
@property (nonatomic, strong) PFObject *pfObject;

@end
