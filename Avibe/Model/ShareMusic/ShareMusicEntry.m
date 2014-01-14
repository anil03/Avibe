//
//  ShareMusicEntry.m
//  Avibe
//
//  Created by Yuhua Mai on 1/14/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "ShareMusicEntry.h"
#import "PublicMethod.h"

@interface ShareMusicEntry ()

@property NSArray *fetechObjects;
@property PFObject *musicToShare;

@end

@implementation ShareMusicEntry

- (id)initWithMusic:(PFObject*)object
{
    self = [super init];
    if(self){
        _musicToShare = object;
    }
    return self;
}

- (void)shareMusic
{
    //Fetch Existing Songs from Parse
    PFQuery *postQuery = [PFQuery queryWithClassName:@"Share"];
    [postQuery whereKey:@"user" equalTo:[[PFUser currentUser] username]];
    [postQuery orderByDescending:@"updateAt"]; //Get latest song
    postQuery.limit = 1000;
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        _fetechObjects = objects;
        [[PublicMethod sharedInstance] filterDuplicatedDataToSaveInParse:[NSMutableArray arrayWithObject:_musicToShare] andSource:@"Share" andFetchObjects:_fetechObjects];
    }];
}


@end
