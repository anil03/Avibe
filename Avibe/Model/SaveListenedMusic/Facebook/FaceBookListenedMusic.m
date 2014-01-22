//
//  FaceBookListenedMusic.m
//  Avibe
//
//  Created by Yuhua Mai on 1/21/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "FaceBookListenedMusic.h"

@interface FaceBookListenedMusic()

@property (nonatomic, strong) NSMutableArray *musicArray;

@end

@implementation FaceBookListenedMusic

- (id)init
{
    self = [super init];
    
    if(self){
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
    [FBRequestConnection startWithGraphPath:@"/me/music.listens"
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
- (void)handleResult:(id)result
{
    _musicArray = [[NSMutableArray alloc] init];
    
    NSMutableArray* jsonArray = [result objectForKey:@"data"];
    for(NSMutableDictionary *dataDict in jsonArray){
        NSMutableDictionary *data = [dataDict objectForKey:@"data"];
        NSMutableDictionary *song = [data objectForKey:@"song"];
        NSString *title = [song objectForKey:@"title"];
        NSString *album = @"N/A";
        NSString *artist = @"N/A";
        
        PFObject *songRecord = [PFObject objectWithClassName:@"Song"];
        [songRecord setObject:title  forKey:@"title"];
        [songRecord setObject:album forKey:@"album"];
        [songRecord setObject:artist forKey:@"artist"];
        [songRecord setObject:[[PFUser currentUser] username] forKey:@"user"];
        
        [_musicArray addObject:songRecord];
    }
    
    //Call delegate method
    if(self.delegate && [self.delegate respondsToSelector:@selector(finishGetListenedMusic:)]){
        [self.delegate finishGetListenedMusic:_musicArray];
    }
}



@end
