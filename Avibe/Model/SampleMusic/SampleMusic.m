//
//  SampleMusic.m
//  Avibe
//
//  Created by Yuhua Mai on 1/13/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "SampleMusic.h"

@implementation SampleMusic

- (void)startSearch:(NSDictionary*)searchInfo
{
    NSString *title = [searchInfo objectForKey:@"title"];
    NSString *artist = [searchInfo objectForKey:@"artist"];
    NSString *string = [NSString stringWithFormat:@"%@+%@", title, artist];
    
    NSString *searchTitle = [string stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *stringURL = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&limit=5", searchTitle];
    NSURL *searchURL = [NSURL URLWithString:[stringURL stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    
    //Download Music
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        searchURL];
        [self performSelectorOnMainThread:@selector(fetchedData:)
                               withObject:data waitUntilDone:YES];
    });
    
}

- (void)fetchedData:(NSData *)responseData
{
    //Can't find the song
    if (!responseData) {
        [self handleError];
        return;
    }
    
    
    
    NSError* error = nil;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    
    NSArray* results = [json objectForKey:@"results"];
    if([results count] == 0){
        [self handleError];
        return;
    }
    
//    NSLog(@"results: %@", results);
    
    NSDictionary* result = [results objectAtIndex:0];
    NSString* kind = [result objectForKey:@"kind"];
    
    if(![kind isEqualToString:@"song"]){
        NSLog(@"Not Song File");
        [self handleError];
        return;
    }
    
    //Prepare Song Info
    NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
    NSString *artworkUrl100 = [result objectForKey:@"artworkUrl100"];
    if (artworkUrl100) {
        [songInfo setObject:artworkUrl100 forKey:@"imageURL"];
    }
    NSString *trackName = [result objectForKey:@"trackName"];
    if (trackName) {
        [songInfo setObject:trackName forKey:@"title"];
    }
    NSString *artistName = [result objectForKey:@"artistName"];
    if (artistName) {
        [songInfo setObject:artistName forKey:@"artist"];
    }
    NSString *collectionName = [result objectForKey:@"collectionName"];
    if (collectionName) {
        [songInfo setObject:collectionName forKey:@"album"];
    }
    NSString *collectionViewUrl = [result objectForKey:@"collectionViewUrl"];
    if (collectionViewUrl) {
        collectionViewUrl = [collectionViewUrl stringByAppendingString:[NSString stringWithFormat:@"&at=%@", kAffiliateProgramToken]];
        NSLog(@"iTuneUrl:%@", collectionViewUrl);
        [songInfo setObject:collectionViewUrl forKey:@"collectionViewUrl"];
    }
    NSString *preViewUrl = [result objectForKey:@"previewUrl"];
    if (preViewUrl) {
        [songInfo setObject:preViewUrl forKey:@"previewUrl"];
    }

    //Call Back
    if (self.delegate && [self.delegate respondsToSelector:@selector(finishFetchData:)]){
        [self.delegate finishFetchData:songInfo];
    }
}
- (void)handleError
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(finishFetchDataWithError:)]) {
        [self.delegate finishFetchDataWithError:nil];
    }
}

@end
