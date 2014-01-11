//
//  ImageFetcher.h
//  Avibe
//
//  Created by Yuhua Mai on 1/11/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageFetcher : NSObject

- (id)initWithLimit:(int)limit andTerm:(NSString*)term;
- (NSArray*)getAlbumImages;

@end
