//
//  SaveMusicEntries.m
//  Avibe
//
//  Created by Yuhua Mai on 1/11/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "SaveMusicEntries.h"
#import "XMLParser.h"

//Rdio
#import "Rdio/RdioConsumerCredentials.h"
#import <Rdio/Rdio.h>

//iPod
#import <MediaPlayer/MediaPlayer.h>



static NSString *kURLString = @"http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=myhgew&api_key=55129edf3dc293c4192639caedef0c2e&limit=10";


@interface SaveMusicEntries () <XMLParserDelegate, RDAPIRequestDelegate>

@property (nonatomic, strong) XMLParser *parser;

//Parse
@property NSArray *fetechObjects;

//Rdio
@property (readonly) Rdio *rdio;
@property NSString *rdio_userkey;

@end

@implementation SaveMusicEntries

@synthesize fetechObjects;

- (id)init
{
    self = [super init];
    
    if (self) {
        
        
    }
    
    return self;
}

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
        [self getSpotifyMusic];
        [self getScrobbleMusic];
    }];
}

#pragma mark - iPod Music
- (void)getIPodMusic
{
    MPMediaItem *currentPlayingSong = [[MPMusicPlayerController iPodMusicPlayer] nowPlayingItem];
    if (currentPlayingSong){
        PFObject *songRecord = [PFObject objectWithClassName:@"Song"];
        [songRecord setObject:[currentPlayingSong valueForProperty:MPMediaItemPropertyTitle]  forKey:@"title"];
        [songRecord setObject:[currentPlayingSong valueForProperty:MPMediaItemPropertyAlbumTitle] forKey:@"album"];
        [songRecord setObject:[currentPlayingSong valueForProperty:MPMediaItemPropertyArtist] forKey:@"artist"];
        [songRecord setObject:[[PFUser currentUser] username] forKey:@"user"];
        
        [self filterDuplicatedDataToSaveInParse:[NSMutableArray arrayWithObject:songRecord] andSource:@"iPod"];
    }else{
        NSLog(@"No iPod Music Available");
    }
}

#pragma mark - LastFM Music
- (void)getScrobbleMusic
{
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
    [self filterDuplicatedDataToSaveInParse:musicToSave andSource:@"LastFM"];
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
    
    [self filterDuplicatedDataToSaveInParse:[NSMutableArray arrayWithObject:songRecord] andSource:@"Rdio"];
}


#pragma mark - TODO Upgrade Duplcated Algorithm
- (void)filterDuplicatedDataToSaveInParse:(NSMutableArray*)musicToSave andSource:(NSString*)sourceName
{
    NSLog(@"***Filtering %@ Music***", sourceName);
    [self printMusicToSaveData:musicToSave];
    
    NSMutableArray *dataToSave = [[NSMutableArray alloc] init];
    __block int numberOfDuplicated = 0;
    
    BOOL songExisted = NO;
    
    for(PFObject *pfToSave in musicToSave){
        songExisted = NO;
        
        NSString *newTitle = [pfToSave objectForKey:@"title"];
        NSString *newArtist = [pfToSave objectForKey:@"artist"];
        NSString *newAlbum = [pfToSave objectForKey:@"album"];
        
        for(PFObject *pf in fetechObjects){
            
            NSString *existingTitle = [pf objectForKey:@"title"];
            NSString *existingArtist = [pf objectForKey:@"artist"];
            NSString *existingAlbum = [pf objectForKey:@"album"];
            
//                NSLog(@"%@-%@", newTitle, existingTitle);

            if ([newTitle isEqualToString:existingTitle] && [newArtist isEqualToString:existingArtist] && [newAlbum isEqualToString:existingAlbum]) {
                //Duplicated Object
                numberOfDuplicated++;
//                NSLog(@"Duplicated %@ - %@ - %@", newTitle, newArtist, newAlbum);
                songExisted = YES;
                break;
            }
        }
        
        
        if (songExisted) {
            continue;
        }
        [dataToSave addObject:pfToSave];
    }
    
    
    [PFObject saveAllInBackground:dataToSave block:^(BOOL succeeded, NSError *error) {
        NSLog(@"***Saving %@ Music***", sourceName);
        if (succeeded) {
            NSLog(@"Save XML Data succeeded!");
            NSLog(@"Number of duplicated songs: %d", numberOfDuplicated);
            
            //Fetch data and Update table view
//                [self fetchData:self.refreshControl];
        }else{
            NSLog(@"Error Saving XML Data: %@", error);
        }
    }];
}

- (void)printMusicToSaveData:(NSMutableArray*)musicToSave
{
    NSLog(@"<===Saving Music===");
    for(PFObject *object in musicToSave){
        NSLog(@"%@,%@,%@", [object objectForKey:@"title"], [object objectForKey:@"artist"], [object objectForKey:@"album"]);
    }
    NSLog(@"==================>");

}

@end
