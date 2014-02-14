//
//  SaveMusicEntries.m
//  Avibe
//
//  Created by Yuhua Mai on 1/11/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "SaveMusicFromSources.h"
#import "ScrobbleListenedMusic.h"
#import "FilterAndSaveMusic.h"

//Rdio
#import "RdioConsumerCredentials.h"
#import "AppDelegate.h"
#import <Rdio/Rdio.h>

//iPod
#import <MediaPlayer/MediaPlayer.h>
#import "iPodListenedMusic.h"

//Facebook
#import "FaceBookListenedMusic.h"


/**
 * Fetch songs from different song, compare to exisiting songs on server and then save.
 */
@interface SaveMusicFromSources () <XMLParserDelegate, RDAPIRequestDelegate, FaceBookListenedMusicDelegate>

@property (nonatomic, strong) ScrobbleListenedMusic *parser;

//Parse
@property NSArray *fetechObjects;

//Rdio
@property (readonly) Rdio *rdio;
@property NSString *rdio_userkey;

//Facebook
@property (nonatomic, strong) FaceBookListenedMusic *listenedMusic;

@end

@implementation SaveMusicFromSources

@synthesize fetechObjects;

- (void)saveMusic
{
    //Fetch Existing Songs from Parse
    PFQuery *postQuery = [PFQuery queryWithClassName:kClassSong];
    [postQuery whereKey:kClassSongUsername equalTo:[[PFUser currentUser] username]];
    [postQuery orderByDescending:kClassGeneralCreatedAt]; //Get latest song
    postQuery.limit = 1000;
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        fetechObjects = objects;
        [self getIPodMusic];
        [self getRdioMusic];
        [self getFaceBookMusic];
        [self getScrobbleMusic];
    }];
}

#pragma mark - iPod Music
- (void)getIPodMusic
{
    NSMutableArray *musicArray = [[NSMutableArray alloc] init];
    NSArray *playedMusicArray = [IPodListenedMusic iPodPlayedMusic];
    
    if (playedMusicArray && [playedMusicArray count] > 0) {
        for(NSDictionary *dict in playedMusicArray){
            PFObject *songRecord = [PFObject objectWithClassName:kClassSong];
            [songRecord setObject:[dict objectForKey:kClassSongTitle]  forKey:kClassSongTitle];
            [songRecord setObject:[dict objectForKey:kClassSongAlbum] forKey:kClassSongAlbum];
            [songRecord setObject:[dict objectForKey:kClassSongArtist] forKey:kClassSongArtist];
            [songRecord setObject:[[PFUser currentUser] username] forKey:kClassSongUsername];
            [songRecord setObject:@"iPod" forKey:kClassSongSource];

//            NSLog(@"=====iPod Music: Title:%@, Album:%@, Artist%@", [dict objectForKey:kClassSongTitle], [dict objectForKey:kClassSongAlbum], [dict objectForKey:kClassSongArtist]);
        }
        
        FilterAndSaveMusic *filter = [[FilterAndSaveMusic alloc] init];
        [filter filterDuplicatedDataToSaveInParse:musicArray andSource:@"iPod" andFetchObjects:fetechObjects];
    }else{
        NSLog(@"No iPod Music Available");
    }
}

#pragma mark - LastFM Music
- (void)getScrobbleMusic
{
    NSString *lastFMUsername = [[PFUser currentUser] objectForKey:kClassUserLastFMUsername];
    
    if(lastFMUsername){
        NSString *kURLString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=%@&api_key=55129edf3dc293c4192639caedef0c2e&limit=10", lastFMUsername];
        
        //Save Scrobbler Music from XML Parser
        NSURL *url = [NSURL URLWithString:kURLString];
        _parser = [[ScrobbleListenedMusic alloc] initWithURL:url];
        _parser.delegate = self;
        [self.parser startParsing];
    }else{
        NSLog(@"No Last.fm Music Available");
    }
}
- (void)finishParsing:(NSMutableArray*)result
{
    NSMutableArray *musicToSave = [[NSMutableArray alloc] init];

    //Return if empty
    if ([musicToSave count] == 0) {
        return;
    }
    
    for(PFObject *object in result){
        [musicToSave addObject:object];
    }
    
    //Get rid of duplicated data then save
    FilterAndSaveMusic *filter = [[FilterAndSaveMusic alloc] init];
    [filter filterDuplicatedDataToSaveInParse:musicToSave andSource:@"Scrobble" andFetchObjects:fetechObjects];
}

#pragma mark - Facebook with Spotify Music
- (void)getFaceBookMusic
{
    NSString *facebookUsername = [[PFUser currentUser] objectForKey:kClassUserFacebookUsername];
    
    if (facebookUsername) {
        _listenedMusic = [[FaceBookListenedMusic alloc] init];
        _listenedMusic.delegate = self;
    }else{
        NSLog(@"No Facebook Music - Spotify & Pandora Available");
    }
}
- (void)finishGetListenedMusic:(NSMutableArray *)musicArray
{
    //Return if empty
    if (musicArray == nil || [musicArray count] == 0) {
        return;
    }
    
    //Get rid of duplicated data then save
    FilterAndSaveMusic *filter = [[FilterAndSaveMusic alloc] init];
    [filter filterDuplicatedDataToSaveInParse:musicArray andSource:@"Facebook" andFetchObjects:fetechObjects];
}

#pragma mark - Rdio Music
- (void)getRdioMusic
{
    NSString *key = [[PFUser currentUser] objectForKey:kClassUserRdioKey];

    if (key) {
        _rdio = [AppDelegate rdioInstance];
        [_rdio callAPIMethod:@"get"
              withParameters:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"s12187116", @"lastSongPlayed,lastSongPlayTime", nil] forKeys:[NSArray arrayWithObjects:@"keys",@"extras", nil]]
                    delegate:[RDAPIRequestDelegate delegateToTarget:self       loadedAction:@selector(rdioRequest:didLoadData:)              failedAction:@selector(rdioRequest:didFailWithError:)]];
    }else{
        NSLog(@"No Rdio Music Available");
    }
}
#pragma mark - Rdio delegate method
- (void)rdioRequest:(RDAPIRequest *)request didLoadData:(id)data
{
    NSString *key = [[PFUser currentUser] objectForKey:kClassUserRdioKey];
    NSDictionary *userdata = [data objectForKey:key];
    NSDictionary *lastSongPlayedData = [userdata objectForKey:@"lastSongPlayed"];
    
    NSString *title = [lastSongPlayedData objectForKey:@"name"];
    NSString *artist = [lastSongPlayedData objectForKey:@"artist"];
    NSString *album = [lastSongPlayedData objectForKey:@"album"];
    
    //Return if empty
    if (title == nil || artist == nil || album == nil) {
        return;
    }
    
    assert(title != nil);
    assert(artist != nil);
    assert(album != nil);
    
    PFObject *songRecord = [PFObject objectWithClassName:kClassSong];
    [songRecord setObject:title  forKey:kClassSongTitle];
    [songRecord setObject:album forKey:kClassSongAlbum];
    [songRecord setObject:artist forKey:kClassSongArtist];
    [songRecord setObject:[[PFUser currentUser] username] forKey:kClassSongUsername];
    [songRecord setObject:@"Rdio" forKey:kClassSongSource];
    
    FilterAndSaveMusic *filter = [[FilterAndSaveMusic alloc] init];
    [filter filterDuplicatedDataToSaveInParse:[NSMutableArray arrayWithObject:songRecord] andSource:@"Rdio" andFetchObjects:fetechObjects];
}
- (void)rdioRequest:(RDAPIRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"No Rdio Music Available with error: %@", error);
}

#pragma mark - Youtube
+(void)saveYoutubeEntry:(NSArray*)array
{
    NSMutableArray *youtubeArray = [[NSMutableArray alloc] init];
    for(NSDictionary *dict in array){
        NSString *title = [dict objectForKey:@"title"];
//        NSString *thumbnailUrl = [dict objectForKey:@"url"];
        
        PFObject *songRecord = [PFObject objectWithClassName:kClassSong];
        [songRecord setObject:title  forKey:kClassSongTitle];
        [songRecord setObject:[[PFUser currentUser] username] forKey:kClassSongUsername];
        [songRecord setObject:@"Youtube" forKey:kClassSongSource];

        [youtubeArray addObject:songRecord];
    }
    
    //Fetch Existing Songs from Parse
    PFQuery *postQuery = [PFQuery queryWithClassName:kClassSong];
    [postQuery whereKey:kClassSongUsername equalTo:[[PFUser currentUser] username]];
    [postQuery orderByDescending:kClassGeneralCreatedAt]; //Get latest song
    postQuery.limit = 1000;
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        FilterAndSaveMusic *filter = [[FilterAndSaveMusic alloc] init];
        [filter filterDuplicatedDataToSaveInParse:youtubeArray andSource:@"Youtube" andFetchObjects:objects];
    }];
}
@end
