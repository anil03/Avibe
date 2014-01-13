//
//  SampleMusic_iTune.h
//  Avibe
//
//  Created by Yuhua Mai on 1/12/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol SampleMusic_iTuneDelegate <NSObject>

- (void)finishFetchData:(NSData*)song andInfo:(NSDictionary*)songInfo;

@end

@interface SampleMusic_iTune : NSObject

@property (nonatomic, weak) id<SampleMusic_iTuneDelegate> delegate;

-(void)initSearch:(NSDictionary*)searchInfo;

@end
