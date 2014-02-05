//
//  SaveMusicEntries.m
//  Avibe
//
//  Created by Yuhua Mai on 1/11/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "SaveMusicEntries.h"
#import "XMLParser.h"
#import "FilterAndSaveObjects.h"

//Rdio
#import "Rdio/RdioConsumerCredentials.h"
#import <Rdio/Rdio.h>

//iPod
#import <MediaPlayer/MediaPlayer.h>
#import "iPodListenedMusic.h"

//Facebook
#import "FaceBookListenedMusic.h"


/**
 * Fetch songs from different song, compare to exisiting songs on server and then save.
 */
@interface SaveMusicEntries () <XMLParserDelegate, RDAPIRequestDelegate, FaceBookListenedMusicDelegate>

@property (nonatomic, strong) XMLParser *parser;

//Parse
@property NSArray *fetechObjects;

//Rdio
@property (readonly) Rdio *rdio;
@property NSString *rdio_userkey;

//Facebook
@property (nonatomic, strong) FaceBookListenedMusic *listenedMusic;

@end

@implementation SaveMusicEntries

@synthesize fetechObjects;

- (void)saveMusic
{
    //Fetch Existing Songs from Parse
    PFQuery *postQuery = [PFQuery queryWithClassName:@"Song"];
    [postQuery whereKey:@"user" equalTo:[[PFUser currentUser] username]];
    [postQuery orderByDescending:@"updateAt"]; //Get latest song
    postQuery.limit = 1000;
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        fetechObjects = objects;
        [self getIPodMusic];
        [self getRdioMusic];
        [self getFaceBookMusic];
        [self getSpotifyMusic];
        [self getScrobbleMusic];
    }];
}

#pragma mark - iPod Music
- (void)getIPodMusic
{
    NSMutableArray *musicArray = [[NSMutableArray alloc] init];
    NSArray *playedMusicArray = [IPodListenedMusic iPodPlayedMusic];
    
    if (playedMusicArray) {
        for(NSDictionary *dict in playedMusicArray){
            PFObject *songRecord = [PFObject objectWithClassName:@"Song"];
            [songRecord setObject:[dict objectForKey:kClassSongTitle]  forKey:kClassSongTitle];
            [songRecord setObject:[dict objectForKey:kClassSongAlbum] forKey:kClassSongAlbum];
            [songRecord setObject:[dict objectForKey:kClassSongArtist] forKey:kClassSongArtist];
            [songRecord setObject:[[PFUser currentUser] username] forKey:kClassSongUsername];
            [songRecord setObject:@"iPod" forKey:kClassSongSource];

//            NSLog(@"=====iPod Music: Title:%@, Album:%@, Artist%@", [dict objectForKey:kClassSongTitle], [dict objectForKey:kClassSongAlbum], [dict objectForKey:kClassSongArtist]);
        }
        
        FilterAndSaveObjects *filter = [[FilterAndSaveObjects alloc] init];
        [filter filterDuplicatedDataToSaveInParse:musicArray andSource:@"iPod" andFetchObjects:fetechObjects];
    }else{
        NSLog(@"No iPod Music Available");
    }
}

#pragma mark - LastFM Music
- (void)getScrobbleMusic
{
    NSString *lastFMUsername = [[PFUser currentUser] objectForKey:kClassUserLastFM];
    
    if(!lastFMUsername) return;
    
    NSString *kURLString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=%@&api_key=55129edf3dc293c4192639caedef0c2e&limit=10", lastFMUsername];

    //Save Scrobbler Music from XML Parser
    NSURL *url = [NSURL URLWithString:kURLString];
    _parser = [[XMLParser alloc] initWithURL:url];
    _parser.delegate = self;
    [self.parser startParsing];
}

- (void)finishParsing:(NSMutableArray*)result
{
    NSMutableArray *musicToSave = [[NSMutableArray alloc] init];

    for(PFObject *object in result){
        [musicToSave addObject:object];
    }
    
    //Get rid of duplicated data then save
    FilterAndSaveObjects *filter = [[FilterAndSaveObjects alloc] init];
    [filter filterDuplicatedDataToSaveInParse:musicToSave andSource:@"LastFM" andFetchObjects:fetechObjects];
}

#pragma mark - Facebook with Spotify Music
- (void)getFaceBookMusic
{
    _listenedMusic = [[FaceBookListenedMusic alloc] init];
    _listenedMusic.delegate = self;
}
- (void)finishGetListenedMusic:(NSMutableArray *)musicArray
{
    //Get rid of duplicated data then save
    FilterAndSaveObjects *filter = [[FilterAndSaveObjects alloc] init];
    [filter filterDuplicatedDataToSaveInParse:musicArray andSource:@"Facebook" andFetchObjects:fetechObjects];
}

#pragma mark - Spotify Music
- (void)getSpotifyMusic
{
    NSLog(@"No Spotify Music Available");
}

#pragma mark - Rdio Music
- (void)getRdioMusic
{
    _rdio_userkey = @"s12187116";
    _rdio = [[Rdio alloc] initWithConsumerKey:RDIO_CONSUMER_KEY andSecret:RDIO_CONSUMER_SECRET delegate:nil];
    [_rdio callAPIMethod:@"get"
         withParameters:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:_rdio_userkey, @"lastSongPlayed,lastSongPlayTime", nil] forKeys:[NSArray arrayWithObjects:@"keys",@"extras", nil]]
               delegate:[RDAPIRequestDelegate delegateToTarget:self       loadedAction:@selector(rdioRequest:didLoadData:)              failedAction:@selector(rdioRequest:didFailWithError:)]];
}

#pragma mark - Rdio delegate method
- (void)rdioRequest:(RDAPIRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"No Rdio Music Available with error: %@", error);
}

- (void)rdioRequest:(RDAPIRequest *)request didLoadData:(id)data
{
    NSDictionary *userdata = [data objectForKey:_rdio_userkey];
    NSDictionary *lastSongPlayedData = [userdata objectForKey:@"lastSongPlayed"];
    
    NSString *title = [lastSongPlayedData objectForKey:@"name"];
    NSString *artist = [lastSongPlayedData objectForKey:@"artist"];
    NSString *album = [lastSongPlayedData objectForKey:@"album"];
//    NSLog(@"Rdio LastSongPlayed: %@, %@, %@", title, artist, album);
    
    PFObject *songRecord = [PFObject objectWithClassName:@"Song"];
    [songRecord setObject:title  forKey:@"title"];
    [songRecord setObject:album forKey:@"album"];
    [songRecord setObject:artist forKey:@"artist"];
    [songRecord setObject:[[PFUser currentUser] username] forKey:@"user"];
    
    FilterAndSaveObjects *filter = [[FilterAndSaveObjects alloc] init];
    [filter filterDuplicatedDataToSaveInParse:[NSMutableArray arrayWithObject:songRecord] andSource:@"Rdio" andFetchObjects:fetechObjects];
}



@end
