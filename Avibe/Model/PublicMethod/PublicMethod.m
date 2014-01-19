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
        ImageFetcher *imageFetcher = [[ImageFetcher alloc] initWithLimit:50 andTerm:@"*"];
        _backgroundImages = [imageFetcher getAlbumImages];
    }
    return self;
}



@end
