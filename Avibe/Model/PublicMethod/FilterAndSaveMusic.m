//
//  FilterAndSaveObjects.m
//  Avibe
//
//  Created by Yuhua Mai on 1/19/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "FilterAndSaveMusic.h"
#import "PublicMethod.h"
#import "NSString+MD5.h"

@implementation FilterAndSaveMusic

#pragma mark - TODO Upgrade Dupilcated Algorithm
- (void)filterDuplicatedDataToSaveInParse:(NSMutableArray*)musicToSave andSource:(NSString*)sourceName andFetchObjects:(NSArray*)fetechObjects
{
//    NSLog(@"***Filtering %@ Music***", sourceName);
//    [self printMusicToSaveData:musicToSave];
    
    NSMutableArray *dataToSave = [[NSMutableArray alloc] init];
    int numberOfDuplicated = 0;
    
    
    /*
     * Assign MD5 to each PFObject to indentify its uniqueness
     */
    for(PFObject *pfToSave in musicToSave){
        NSString *newTitle = [pfToSave objectForKey:kClassSongTitle];
        NSString *newArtist = [pfToSave objectForKey:kClassSongArtist];
        NSString *newAlbum = [pfToSave objectForKey:kClassSongAlbum];
        
        //Deal with nil
        if(!newTitle) newTitle = @"";
        if(!newArtist) newArtist = @"";
        if(!newAlbum) newAlbum = @"";
        
        NSString *stringForMD5 = [NSString stringWithFormat:@"%@%@%@%@",newTitle,newArtist,newAlbum,[[PFUser currentUser]username]];
        NSString *MD5String = [self handleStringToMD5:stringForMD5];
        
        //Get dupliacted song MD5 from Public Method
        NSMutableArray *md5Array = [PublicMethod sharedInstance].md5Array;
        if ([md5Array containsObject:MD5String] == NO) {
            /*
             * Save MD5String to PublicMethod for next usage in the same save
             * In case there are more than same song in one save
             */
            [[PublicMethod sharedInstance] addStringToMD5Array:MD5String];
            
            [pfToSave setObject:MD5String forKey:kClassSongMD5];
            [dataToSave addObject:pfToSave];
        }else{
            numberOfDuplicated++;
        }
    }
    
    /**
     * Save PFObject to parse
     */
    [PFObject saveAllInBackground:dataToSave block:^(BOOL succeeded, NSError *error) {
        NSLog(@"***Saving %@ Music***", sourceName);
        if (succeeded) {
            NSLog(@"Number of songs to save: %lu", (unsigned long)[dataToSave count]);
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

#pragma mark - Turn string to MD5 
- (NSString*)handleStringToMD5:(NSString*)string
{
    NSString *charactirzedString = [NSString stringWithUTF8String:[string UTF8String]];
    NSString *MD5String = [charactirzedString MD5];
//    NSLog(@"Original: %@ Charactrized:%@ MD5: %@", string, charactirzedString, MD5String);
    return MD5String;
}

#pragma mark - call delegate method using by Share
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
