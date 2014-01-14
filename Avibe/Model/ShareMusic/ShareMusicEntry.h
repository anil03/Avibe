//
//  ShareMusicEntry.h
//  Avibe
//
//  Created by Yuhua Mai on 1/14/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareMusicEntry : NSObject

- (id)initWithMusic:(PFObject*)object;
- (void)shareMusic;

@end
