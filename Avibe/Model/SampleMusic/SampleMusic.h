//
//  SampleMusic.h
//  Avibe
//
//  Created by Yuhua Mai on 1/13/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SampleMusicDelegate <NSObject>

- (void)finishFetchData:(NSData*)song andInfo:(NSDictionary*)songInfo;

@end

@interface SampleMusic : NSObject

@property (nonatomic, weak) id<SampleMusicDelegate> delegate;

-(void)startSearch:(NSDictionary*)searchInfo;

@end
