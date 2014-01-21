//
//  PublicMethod.m
//  Avibe
//
//  Created by Yuhua Mai on 1/14/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "PublicMethod.h"
#import "BackgroundImageView.h"

@interface PublicMethod ()


@end

@implementation PublicMethod

+ (PublicMethod *)sharedInstance
{
    static PublicMethod *sharedInstance;
    
    @synchronized(self)
    {
        if (!sharedInstance){
            sharedInstance = [[PublicMethod alloc] init];
        }
            
        return sharedInstance;
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        ImageFetcher *imageFetcher = [[ImageFetcher alloc] initWithLimit:100 andTerm:@"*"];
        _backgroundImages = [imageFetcher getAlbumImages];
    }
    return self;
}

- (NSArray *)backgroundImages
{
    NSMutableArray *shuffleBackGroundImages = [[NSMutableArray alloc] initWithArray:_backgroundImages];
    NSUInteger count = [shuffleBackGroundImages count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = arc4random_uniform(nElements) + i;
        [shuffleBackGroundImages exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    return shuffleBackGroundImages;
}

- (NSMutableAttributedString*)refreshBeginString
{
    NSString *lastUpdated = @"Pull to Refresh";
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:lastUpdated];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0,[lastUpdated length])];
    
    return string;
}
- (NSMutableAttributedString*)refreshUpdatingString
{
    NSString *lastUpdated = @"Refreshing data...";
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:lastUpdated];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0,[lastUpdated length])];
    
    return string;
}
- (NSMutableAttributedString*)refreshFinsihedString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",[formatter stringFromDate:[NSDate date]]];
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:lastUpdated];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0,[lastUpdated length])];
    
    return string;
}


@end
