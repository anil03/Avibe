//
//  ShareMusicEntry.m
//  Avibe
//
//  Created by Yuhua Mai on 1/14/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "ShareMusicEntry.h"
#import "FilterAndSaveMusic.h"

@interface ShareMusicEntry () <FilterAndSaveMusicDelegate>

@property NSArray *fetechObjects;
@property PFObject *musicToShare;

@property (nonatomic, strong) FilterAndSaveMusic *filter;

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
    PFQuery *postQuery = [PFQuery queryWithClassName:kClassShare];
    [postQuery whereKey:kClassSongUsername equalTo:[[PFUser currentUser] username]];
    [postQuery orderByDescending:kClassGeneralCreatedAt]; //Get latest song
    postQuery.limit = 1000;
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        _fetechObjects = objects;
        
        _filter = [[FilterAndSaveMusic alloc] init];
        _filter.delegate = self;
        [_filter filterDuplicatedDataToSaveInParse:[NSMutableArray arrayWithObject:_musicToShare] andSource:@"Share" andFetchObjects:_fetechObjects];
    }];
}

#pragma mark - FilterAndSaveObjects Delegate Method

- (void)dataSavedSucceed
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Success" message: @"Congrat! Now your friend can see your shared music." delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)dataSavedWithDuplicate
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Oops, you have shared this song." delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)dataSavedFailed:(NSError*)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Sorry, can't share this song right now." delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
