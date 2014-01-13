//
//  SampleMusic_iTune.m
//  Avibe
//
//  Created by Yuhua Mai on 1/12/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "SampleMusic_iTune.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@implementation SampleMusic_iTune

- (void)initSearch:(NSDictionary*)searchInfo
{
    NSString *title = [searchInfo objectForKey:@"title"]  ;
    NSString *searchTitle = [title stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSURL *searchURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&limit=10", searchTitle]];
    
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Sorry, can't find the sample song." delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSError* error = nil;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    NSArray* results = [json objectForKey:@"results"];
    
    NSLog(@"results: %@", results);
    
    NSDictionary* result = [results objectAtIndex:0];
    
    //Prepare Song Info
    NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
    [songInfo setObject:[result objectForKey:@"artworkUrl100"] forKey:@"imageURL"];
    [songInfo setObject:[result objectForKey:@"trackName"] forKey:@"title"];
    [songInfo setObject:[result objectForKey:@"artistName"] forKey:@"artist"];
    [songInfo setObject:[result objectForKey:@"collectionName"] forKey:@"album"];
    
    
    NSString* kind = [result objectForKey:@"kind"];
    
    if(![kind isEqualToString:@"song"]){
        NSLog(@"Not Song File");
        return;
    }
    
    NSURL* previewUrl = [NSURL URLWithString:[result objectForKey:@"previewUrl"]];
    NSError* __autoreleasing soundFileError = nil;
    NSData *songFile = [[NSData alloc] initWithContentsOfURL:previewUrl options:NSDataReadingMappedIfSafe error:&soundFileError ];
    
    if (soundFileError) {
        NSLog(@"Load Song File Error!");
        return;
    }
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(finishFetchData:andInfo:)]){
        [self.delegate finishFetchData:songFile andInfo:songInfo];
    }
}

@end
