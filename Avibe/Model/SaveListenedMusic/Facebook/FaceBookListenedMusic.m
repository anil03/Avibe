//
//  FaceBookListenedMusic.m
//  Avibe
//
//  Created by Yuhua Mai on 1/21/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "FaceBookListenedMusic.h"

@interface FaceBookListenedMusic()
{
    int connectionNumber;
}

@property (nonatomic, strong) NSMutableArray *musicArray;

//Batch Request
@property FBRequestConnection *connection;
@property (nonatomic, strong) NSMutableArray *batchRequestResult;


@end

@implementation FaceBookListenedMusic

- (id)init
{
    self = [super init];
    
    if(self){
        _musicArray = [[NSMutableArray alloc] init];
        
        _connection = [[FBRequestConnection alloc] init];
        _batchRequestResult = [[NSMutableArray alloc] init];
        connectionNumber = 0;
        
        //NSArray *permissionsNeeded = @[@"publish_actions"];
        NSArray *permissionsNeeded = @[@"user_actions.music"];
        
        // Request the permissions the user currently has
        [FBRequestConnection startWithGraphPath:@"/me/permissions"
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                  if (!error){
                                      // These are the current permissions the user has
                                      NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
                                      
                                      // We will store here the missing permissions that we will have to request
                                      NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:@[]];
                                      
                                      // Check if all the permissions we need are present in the user's current permissions
                                      // If they are not present add them to the permissions to be requested
                                      for (NSString *permission in permissionsNeeded){
                                          if (![currentPermissions objectForKey:permission]){
                                              [requestPermissions addObject:permission];
                                          }
                                      }
                                      
                                      // If we have permissions to request
                                      if ([requestPermissions count] > 0){
                                          [FBSession.activeSession
                                           requestNewReadPermissions:requestPermissions
                                           completionHandler:^(FBSession *session, NSError *error) {
                                               if (!error) {
                                                   // Permission granted, we can request the user information
                                                   [self makeMusicHistoryRequest];
                                               } else {
                                                   // An error occurred, we need to handle the error
                                                   // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                                   NSLog(@"error %@", error.description);
                                               }
                                           }];
                                      } else {
                                          // Permissions are present
                                          // We can request the user information
                                          [self makeMusicHistoryRequest];
                                      }
                                      
                                  } else {
                                      // An error occurred, we need to handle the error
                                      // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                      NSLog(@"error %@", error.description);
                                  }
                              }];
    }
    return self;
}

- (void)makeMusicHistoryRequest
{
    [FBRequestConnection startWithGraphPath:@"/me/music.listens?fields=data,application"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              /* handle the result */
                              if (!error) {
                                  // Success! Include your code to handle the results here
//                                  NSLog(@"Music history: %@", result);
                                  [self handleResult:result];
                              } else {
                                  // An error occurred, we need to handle the error
                                  // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                  NSLog(@"error %@", error.description);
                              }
                          }];
    
}
- (void)makeSongIDRequest:(NSString*)songID
{
    connectionNumber++;
    
    FBRequest *request = [FBRequest requestWithGraphPath:[NSString stringWithFormat:@"/%@",songID] parameters:nil HTTPMethod:@"GET"];
    [_connection addRequest:request completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
//            NSLog(@"Connection succedd with %@", songID);
            [_batchRequestResult addObject:result];
            connectionNumber--;
            
            if (connectionNumber == 0) {
//                NSLog(@"The end");
                for (id result in _batchRequestResult) {
                    [self handleSongIDResult:result];
                }
                
                //Call delegate method
                if(self.delegate && [self.delegate respondsToSelector:@selector(finishGetListenedMusic:)]){
                    [self.delegate finishGetListenedMusic:_musicArray];
                }
            }
            
        }else{
            NSLog(@"error %@", error.description);
        }
    }];
}

/**
 * No album & artist from facebook source
 */
- (void)handleResult:(id)result
{
    
    NSMutableArray* jsonArray = [result objectForKey:@"data"];
    for(NSMutableDictionary *dataDict in jsonArray){
        NSMutableDictionary *data = [dataDict objectForKey:@"data"];
        //data-data-song-id,title
        NSMutableDictionary *song = [data objectForKey:@"song"];
        NSString *songID = [song objectForKey:@"id"];
//        NSString *title = [song objectForKey:@"title"];

        //data-application-name
//        NSMutableDictionary *application = [dataDict objectForKey:@"application"];
//        NSString *sourceName = [application objectForKey:@"name"];

        [self makeSongIDRequest:songID];
    }
    
    [_connection start];
}
- (void)handleSongIDResult:(id)result
{
//    NSLog(@"result:%@",result);
    //Title
    NSString *title = [result objectForKey:@"title"];
    
    //Image
    NSMutableArray *image = [result objectForKey:@"image"];
    NSString *imageurl = [image[0] objectForKey:@"url"];
    
    //Data
    NSMutableDictionary* data = [result objectForKey:@"data"];
    //Data-Album
    NSMutableArray* album = [data objectForKey:@"album"];
    NSMutableDictionary* albumurl = [album[0] objectForKey:@"url"];
    NSString *albumTitle = [albumurl objectForKey:@"title"];
    
    //Data-Musician
    NSMutableArray* musician = [data objectForKey:@"musician"];
    NSString *musicianTitle = [musician[0] objectForKey:@"name"];
    
    //Application
    NSMutableDictionary *application = [result objectForKey:@"application"];
    NSString *sourceName = [application objectForKey:@"name"];
    
//    NSLog(@"%@ %@ %@ %@ %@", title, albumTitle, musicianTitle, sourceName, imageurl);
    
    //PFObject
    PFObject *songRecord = [PFObject objectWithClassName:kClassSong];
    if(title) [songRecord setObject:title  forKey:kClassSongTitle];
    if(albumTitle) [songRecord setObject:albumTitle  forKey:kClassSongAlbum];
    if(musicianTitle) [songRecord setObject:musicianTitle  forKey:kClassSongArtist];
    if(sourceName) [songRecord setObject:sourceName forKey:kClassSongSource];
    if(imageurl) [songRecord setObject:imageurl forKey:kClassSongAlbumURL];
    [songRecord setObject:[[PFUser currentUser] username] forKey:kClassSongUsername];

    [_musicArray addObject:songRecord];
}


@end
