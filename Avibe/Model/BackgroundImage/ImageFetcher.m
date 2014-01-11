//
//  ImageFetcher.m
//  Avibe
//
//  Created by Yuhua Mai on 1/11/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "ImageFetcher.h"

@interface ImageFetcher ()

@property int limit;
@property NSString *term;

@end

@implementation ImageFetcher

static NSString *const kURLString = @"https://itunes.apple.com/search?";

- (id)initWithLimit:(int)limit andTerm:(NSString*)term
{
    self = [super init];
    
    if (self) {
        _limit = limit;
        _term = term;
    }
    
    return self;
}

- (NSDictionary*)fetchMusicList
{
    NSURL *searchURL = [NSURL URLWithString:[kURLString stringByAppendingString:[NSString stringWithFormat:@"term=%@&limit=%d", _term, _limit]]];
    NSData* responseData = [NSData dataWithContentsOfURL:
                    searchURL];
    NSError* error = nil;
    NSDictionary* json = nil;
    
    if (responseData) {
        json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              
                              options:kNilOptions
                              error:&error];
    }else{
        NSLog(@"Can't fetch background image information.");
    }
    
    if (error) {
        NSLog(@"Error parsing background image JSON file.");
    }
    
    return json;
}

- (NSArray*)getAlbumImages
{
    NSMutableArray *imageURLs = [[NSMutableArray alloc] init];
    
    NSDictionary *json = [self fetchMusicList];
    NSArray* results = [json objectForKey:@"results"];
    for (int i = 0; i < [results count]; i++) {
        NSDictionary* result = [results objectAtIndex:i];
        NSURL* previewUrl = [NSURL URLWithString:[result objectForKey:@"artworkUrl100"]];
        [imageURLs addObject:previewUrl];
    }
    
    return imageURLs;
}

@end
