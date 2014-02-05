//
//  iPodListenedMusic.m
//  Avibe
//
//  Created by Yuhua Mai on 2/4/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "IPodListenedMusic.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation IPodListenedMusic

- (NSDictionary *)iPodPlayedMusic
{
    //    MPMediaQuery *songsQuery =  [[MPMediaQuery alloc] initWithFilterPredicates: predicates];
    MPMediaQuery *songsQuery = [MPMediaQuery songsQuery];
    for(MPMediaItem *item in [songsQuery items]){
        NSString *title = [item valueForProperty:[MPMediaItem titlePropertyForGroupingType:MPMediaGroupingTitle]];
        NSNumber *count = [item valueForKey:MPMediaItemPropertyPlayCount];
        NSString *lastPlayedDate = [item valueForKey:MPMediaItemPropertyLastPlayedDate];
        
        NSLog(@"%@, %d, %@", title, [count unsignedIntegerValue], lastPlayedDate);
    }

    return nil;
}

@end
