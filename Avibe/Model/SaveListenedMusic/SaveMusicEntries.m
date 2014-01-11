//
//  SaveMusicEntries.m
//  Avibe
//
//  Created by Yuhua Mai on 1/11/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "SaveMusicEntries.h"
#import "XMLParser.h"

#import <MediaPlayer/MediaPlayer.h>



static NSString *kURLString = @"http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=myhgew&api_key=55129edf3dc293c4192639caedef0c2e&limit=10";


@interface SaveMusicEntries () <XMLParserDelegate>

@property (nonatomic, strong) NSMutableArray *musicToSave;
@property (nonatomic, strong) XMLParser *parser;


@end

@implementation SaveMusicEntries

- (id)init
{
    self = [super init];
    
    if (self) {
        _musicToSave = [[NSMutableArray alloc] init];
    }
    
    return self;
}


- (void)saveMusic
{
    [self getIPodMusic];
    [self getRdioMusic];
    [self getScrobbleMusic];
    [self getSpotifyMusic];
    
    //Get rid of duplicated data then save
    [self filterDuplicatedDataToSaveInParse:_musicToSave];
    
    
}

- (void)getIPodMusic
{
    MPMediaItem *currentPlayingSong = [[MPMusicPlayerController iPodMusicPlayer] nowPlayingItem];
    if (currentPlayingSong){
        PFObject *songRecord = [PFObject objectWithClassName:@"Song"];
        [songRecord setObject:[currentPlayingSong valueForProperty:MPMediaItemPropertyTitle]  forKey:@"title"];
        [songRecord setObject:[currentPlayingSong valueForProperty:MPMediaItemPropertyAlbumTitle] forKey:@"album"];
        [songRecord setObject:[currentPlayingSong valueForProperty:MPMediaItemPropertyArtist] forKey:@"artist"];
        [songRecord setObject:[[PFUser currentUser] username] forKey:@"user"];
        
        [_musicToSave addObject:songRecord];
    }
}

- (void)getScrobbleMusic
{
    //Save Scrobbler Music from XML Parser
    NSURL *url = [NSURL URLWithString:kURLString];
    _parser = [[XMLParser alloc] initWithURL:url AndData:_musicToSave];
    _parser.delegate = self;
    [self.parser startParsing];
}

- (void)getSpotifyMusic
{
    
}

- (void)getRdioMusic
{
    
}

- (void)filterDuplicatedDataToSaveInParse:(NSMutableArray*)XMLData
{
    NSMutableArray *dataToSave = [[NSMutableArray alloc] init];
    __block int numberOfDuplicated = 0;
    
    
    PFQuery *postQuery = [PFQuery queryWithClassName:@"Song"];
    [postQuery whereKey:@"user" equalTo:[[PFUser currentUser] username]];
    postQuery.limit = 1000;
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *fetechObjects, NSError *error) {
        BOOL songExisted = NO;
        
        for(PFObject *pfToSave in XMLData){
            songExisted = NO;
            
            NSString *newTitle = [pfToSave objectForKey:@"title"];
            NSString *newArtist = [pfToSave objectForKey:@"artist"];
            NSString *newAlbum = [pfToSave objectForKey:@"album"];
            
            /* Too slow in background
             PFQuery *postQuery = [PFQuery queryWithClassName:@"Song"];
             [postQuery whereKey:@"user" equalTo:[[PFUser currentUser] username]];
             [postQuery whereKey:@"title" containsString:newTitle];
             [postQuery whereKey:@"artist" containsString:newArtist];
             [postQuery whereKey:@"album" containsString:newAlbum];
             
             if ([postQuery countObjects] > 0) {
             songExisted = YES;
             }
             */
            
            
            for(PFObject *pf in fetechObjects){
                NSString *existingTitle = [pf objectForKey:@"title"];
                NSString *existingArtist = [pf objectForKey:@"artist"];
                NSString *existingAlbum = [pf objectForKey:@"album"];
                
                if ([newTitle isEqualToString:existingTitle] && [newArtist isEqualToString:existingArtist] && [newAlbum isEqualToString:existingAlbum]) {
                    //Duplicated Object
                    numberOfDuplicated++;
                    //                    NSLog(@"Duplicated %@ - %@ - %@", newTitle, newArtist, newAlbum);
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
            if (succeeded) {
                NSLog(@"Save XML Data succeeded!");
                NSLog(@"Number of duplicated songs: %d", numberOfDuplicated);
                
                //Fetch data and Update table view
//                [self fetchData:self.refreshControl];
            }else{
                NSLog(@"Error Saving XML Data: %@", error);
            }
        }];
        
    }];
    
    
    
    
}

#pragma mark - XML method
- (void)finishParsing
{
    NSLog(@"Parse Finish.");
    
}


@end
