
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

- (void)saveMusicInBackground
{
    //Fetch Existing Songs from Parse
    PFQuery *postQuery = [PFQuery queryWithClassName:kClassSong];
    [postQuery whereKey:kClassSongUsername equalTo:[[PFUser currentUser] username]];
    [postQuery orderByDescending:kClassGeneralCreatedAt]; //Get latest song
    postQuery.limit = 100;
    
    fetechObjects = [postQuery findObjects];
    if (fetechObjects) {
        [self getIPodMusic];
//        [self getRdioMusic];
//        [self getFaceBookMusic];
//        [self getScrobbleMusic];
    }
}

- (void)saveMusic
{
    //Fetch Existing Songs from Parse
    PFQuery *postQuery = [PFQuery queryWithClassName:kClassSong];
    [postQuery whereKey:kClassSongUsername equalTo:[[PFUser currentUser] username]];
    [postQuery orderByDescending:kClassGeneralCreatedAt]; //Get latest song
    postQuery.limit = 100;
    
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            fetechObjects = objects;
            [self getIPodMusic];
            [self getRdioMusic];
            [self getFaceBookMusic];
            [self getScrobbleMusic];
        }else{
            NSLog(@"Error:%@", error.description);
        }
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
            
            [musicArray addObject:songRecord];
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
        int songNumber = 10;
        NSString *kURLString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=%@&api_key=55129edf3dc293c4192639caedef0c2e&limit=%d&format=json", lastFMUsername, songNumber];
        
        //Download Result From Last.fm
        dispatch_async(kBgQueue, ^{
            NSData* data = [NSData dataWithContentsOfURL:
                            [NSURL URLWithString:kURLString]];
            [self performSelectorOnMainThread:@selector(fetchedData:)
                                   withObject:data waitUntilDone:YES];
        });
        
        //Save Scrobbler Music from XML Parser
//        NSURL *url = [NSURL URLWithString:kURLString];
//        _parser = [[ScrobbleListenedMusic alloc] initWithURL:url];
//        _parser.delegate = self;
//        [self.parser startParsing];
    }else{
        NSLog(@"No Last.fm Music Available");
    }
}
- (void)fetchedData:(NSData *)responseData
{
    if (!responseData) {
        NSLog(@"No data from Last.fm.");
        return;
    }
    
    NSError* error = nil;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
//    NSLog(@"%@",json);
    
    NSArray* tracks;
    if(json && json[@"recenttracks"] && json[@"recenttracks"][@"track"]){
        tracks = json[@"recenttracks"][@"track"];
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(NSDictionary *dict in tracks){
        NSString *title = dict[@"name"];
        NSString *album = dict[@"album"][@"#text"];
        NSString *artist = dict[@"artist"][@"#text"];
//        NSString *imagesmall = dict[@"image"][0][@"#text"];
//        NSString *imagemedium = dict[@"image"][1][@"#text"];
//        NSString *imagelarge = dict[@"image"][2][@"#text"];
        NSString *imageextralarge = dict[@"image"][3][@"#text"];
        
        PFObject *object = [PFObject objectWithClassName:kClassSong];
        if(title) [object setObject:title forKey:kClassSongTitle];
        if(album) [object setObject:album forKey:kClassSongAlbum];
        if(artist) [object setObject:artist forKey:kClassSongArtist];
        if(imageextralarge) [object setObject:imageextralarge forKey:kClassSongAlbumURL];
        [object setObject:[[PFUser currentUser] username] forKey:kClassSongUsername];
        [object setObject:@"Last.fm" forKey:kClassSongSource];
        
        [array addObject:object];
    }
    
    [self finishParsingLastFM:array];
}
- (void)finishParsingLastFM:(NSMutableArray*)musicToSave
{
    //Return if empty
    if (musicToSave == nil || [musicToSave count] == 0) {
        return;
    }
    
    //Get rid of duplicated data then save
    FilterAndSaveMusic *filter = [[FilterAndSaveMusic alloc] init];
    [filter filterDuplicatedDataToSaveInParse:musicToSave andSource:@"Last.fm" andFetchObjects:fetechObjects];
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
    NSString *albumurl = [lastSongPlayedData objectForKey:@"icon400"];
    
    PFObject *songRecord = [PFObject objectWithClassName:kClassSong];
    if(title) [songRecord setObject:title  forKey:kClassSongTitle];
    if(album) [songRecord setObject:album forKey:kClassSongAlbum];
    if(albumurl) [songRecord setObject:albumurl forKey:kClassSongAlbumURL];
    if(artist) [songRecord setObject:artist forKey:kClassSongArtist];
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
