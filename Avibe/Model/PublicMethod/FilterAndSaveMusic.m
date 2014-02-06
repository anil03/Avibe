//
//  FilterAndSaveObjects.m
//  Avibe
//
//  Created by Yuhua Mai on 1/19/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "FilterAndSaveMusic.h"

@implementation FilterAndSaveMusic

#pragma mark - TODO Upgrade Duplcated Algorithm
- (void)filterDuplicatedDataToSaveInParse:(NSMutableArray*)musicToSave andSource:(NSString*)sourceName andFetchObjects:(NSArray*)fetechObjects
{
//    NSLog(@"***Filtering %@ Music***", sourceName);
//    [self printMusicToSaveData:musicToSave];
    
    NSMutableArray *dataToSave = [[NSMutableArray alloc] init];
    __block int numberOfDuplicated = 0;
    
    BOOL songExisted = NO;
    
    for(PFObject *pfToSave in musicToSave){
        songExisted = NO;
        
        NSString *newTitle = [pfToSave objectForKey:kClassSongTitle];
        NSString *newArtist = [pfToSave objectForKey:kClassSongArtist];
        NSString *newAlbum = [pfToSave objectForKey:kClassSongAlbum];
        
        for(PFObject *pf in fetechObjects){
            
            NSString *existingTitle = [pf objectForKey:kClassSongTitle];
            NSString *existingArtist = [pf objectForKey:kClassSongArtist];
            NSString *existingAlbum = [pf objectForKey:kClassSongAlbum];
            
            //                NSLog(@"%@-%@", newTitle, existingTitle);
            
            BOOL duplicated = [newTitle isEqualToString:existingTitle] ||
            ([newTitle isEqualToString:existingTitle] && [newArtist isEqualToString:existingArtist] && [newAlbum isEqualToString:existingAlbum]);
            if (duplicated) {
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
            NSLog(@"Number of songs to save: %d", [dataToSave count]);
            NSLog(@"Number of duplicated songs: %d", numberOfDuplicated);
            
//            [UIApplication sharedApplication].applicationIconBadgeNumber += ([dataToSave count]-numberOfDuplicated);
            
            if (numberOfDuplicated > 0) {
                [self callSavedDuplicate];
            }else{
                [self callSavedSucceed];
            }
        }else{
            NSLog(@"Error Saving XML Data: %@", error);
            
            [self callSavedFailed:error];
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

#pragma mark - call delegate method
- (void)callSavedSucceed
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dataSavedSucceed)]) {
        [self.delegate dataSavedSucceed];
    }
}
- (void)callSavedDuplicate
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dataSavedWithDuplicate)]) {
        [self.delegate dataSavedWithDuplicate];
    }
}
- (void)callSavedFailed:(NSError*)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dataSavedFailed:)]) {
        [self.delegate dataSavedFailed:error];
    }
}


@end
