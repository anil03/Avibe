//
//  FaceBookListenedMusic.h
//  Avibe
//
//  Created by Yuhua Mai on 1/21/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FaceBookListenedMusicDelegate <NSObject>

- (void)finishGetListenedMusic:(NSMutableArray*)musicArray;

@end

@interface FaceBookListenedMusic : NSObject

@property (nonatomic, weak) id<FaceBookListenedMusicDelegate> delegate;

@end
