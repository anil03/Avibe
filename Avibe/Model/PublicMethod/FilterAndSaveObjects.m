//
//  FilterAndSaveObjects.m
//  Avibe
//
//  Created by Yuhua Mai on 1/19/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "FilterAndSaveObjects.h"

@implementation FilterAndSaveObjects

#pragma mark - TODO Upgrade Duplcated Algorithm
- (void)filterDuplicatedDataToSaveInParse:(NSMutableArray*)musicToSave andSource:(NSString*)sourceName andFetchObjects:(NSArray*)fetechObjects
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
