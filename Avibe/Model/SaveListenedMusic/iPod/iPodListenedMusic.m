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

/**
 * Return array of dictionary, each dictionary contains title, album, artist.
 */
+ (NSArray *)iPodPlayedMusic
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastUpdatedDate = [defaults objectForKey:kKeyLastUpdatedDate];
    NSLog(@"Last update date:%@", lastUpdatedDate);
    
    MPMediaQuery *songsQuery = [MPMediaQuery songsQuery];
    for(MPMediaItem *item in [songsQuery items]){
        NSString *title = [item valueForProperty:MPMediaItemPropertyTitle];
        NSString *album = [item valueForProperty:MPMediaItemPropertyAlbumTitle];
        NSString *artist = [item valueForProperty:MPMediaItemPropertyArtist];

//        NSNumber *count = [item valueForKey:MPMediaItemPropertyPlayCount];
        NSDate *lastPlayedDate = [item valueForKey:MPMediaItemPropertyLastPlayedDate];
        
        if ([lastPlayedDate compare:lastUpdatedDate] == NSOrderedDescending) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:title forKey:kClassSongTitle];
            [dict setObject:album forKey:kClassSongAlbum];
            [dict setObject:artist forKey:kClassSongArtist];
            [array addObject:dict];
            
//            NSLog(@"===*****====%@, %@, %@, %lu, lastPlayed: %@, lastUpdated: %@", title, album, artist, (unsigned long)[count unsignedIntegerValue], lastPlayedDate, lastUpdatedDate);
        }
    }

    return array;
}

@end
