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
        _backgroundImages = [[NSMutableArray alloc] init];

        NSArray *artistArray = @[@"Justin+Timberlake", @"Katy+Perry", @"Pitbull", @"OneRepublic", @"Eminem", @"One+Direction", @"Passenger", @"Lorde", @"Avicii", @"Imagine+Dragons", @"Beyonce", @"Miley+Cyrus", @"Rihanna", @"Lady+Gaga", @"Calvin+Harris", @"Rihanna", @"Daft+Punk", @"Bastille", @"Drake", @"Jason+Derulo", @"Lana+Del+Rey", @"Martin+Garrix", @"Britney+Spears", @"Robin+Thicke", @"Macklemore", @"Ryan+Lewis", @"Michael+Buble", @"Stromae", @"Arctic+Moneys", @"Pharrell", @"Justin+Bieber", @"John+Newman", @"Demi+Lovato", @"Ed+Sheeran", @"Kid+Ink", @"Lily+Allen", @"Adele", @"Beatles", @"Killers", @"Leona", @"Greenday", @"Ariana+Grande", @"Westlife"];
        for(NSString *artist in artistArray){
            [self searchForImages:1 andTerm:artist];
        }
    }
    return self;
}
- (void)searchForImages:(NSInteger)limit andTerm:(NSString*)term
{
    ImageFetcher *imageFetcher = [[ImageFetcher alloc] initWithLimit:limit andTerm:term];
    for(UIImage *image in [imageFetcher getAlbumImages]){
        [_backgroundImages addObject:image];
    }
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
