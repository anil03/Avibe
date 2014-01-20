//
//  SampleMusic_iTune.h
//  Avibe
//
//  Created by Yuhua Mai on 1/12/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "SampleMusic.h"

@protocol SampleMusic_iTuneDelegate <NSObject>

- (void)finishFetchData:(NSData*)song andInfo:(NSDictionary*)songInfo andIndexPath:(NSIndexPath*)indexPath;

@end

@interface SampleMusic_iTune : SampleMusic

@property (nonatomic, weak) id<SampleMusic_iTuneDelegate> delegateForIndexPath;

- (id)initWithIndexPath:(NSIndexPath*)indexPath;

@end
