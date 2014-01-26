//
//  SampleMusic_iTune.m
//  Avibe
//
//  Created by Yuhua Mai on 1/12/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "SampleMusic_iTune.h"



@interface SampleMusic_iTune()

@property (nonatomic, strong) NSIndexPath *indexPath;

@end

@implementation SampleMusic_iTune

- (id)initWithIndexPath:(NSIndexPath*)indexPath
{
    self = [super init];
    if (self) {
        _indexPath = indexPath;
    }
    return self;
}

- (void)startSearch:(NSDictionary*)searchInfo
{
    NSString *title = [searchInfo objectForKey:@"title"]  ;
    NSString *searchTitle = [title stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *stringURL = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&limit=1", searchTitle];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Sorry, can't find the sample song." delegate:self.delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
    
    
    NSString* kind = [result objectForKey:@"kind"];
    
    if(![kind isEqualToString:@"song"]){
        NSLog(@"Not Song File");
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
    
    
    
    
    NSURL* previewUrl = [NSURL URLWithString:[result objectForKey:@"previewUrl"]];
    NSError* __autoreleasing soundFileError = nil;
    NSData *songFile = [[NSData alloc] initWithContentsOfURL:previewUrl options:NSDataReadingMappedIfSafe error:&soundFileError ];
    
    if (soundFileError) {
        NSLog(@"Load Song File Error!");
        return;
    }
    
    
    //Background Image For UICollectionView
    if (self.delegateForIndexPath && [self.delegateForIndexPath respondsToSelector:@selector(finishFetchData:andInfo:andIndexPath:)]) {
        [self.delegateForIndexPath finishFetchData:songFile andInfo:songInfo andIndexPath:_indexPath];
    }
    //Other Call Back
    if (self.delegate && [self.delegate respondsToSelector:@selector(finishFetchData:andInfo:)]){
        [self.delegate finishFetchData:songFile andInfo:songInfo];
    }
}

@end
