//
//  PublicMethod.h
//  Avibe
//
//  Created by Yuhua Mai on 1/14/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ImageFetcher.h"
#import "SaveMusicFromSources.h"

@interface PublicMethod : NSObject

@property (nonatomic, strong) NSMutableArray *backgroundImages;
//@property (nonatomic, strong) NSDate *lastUpdatedDate;

@property (nonatomic, strong) SaveMusicFromSources *saveMusicFromSources;

+ (PublicMethod *)sharedInstance;

#pragma mark - Refresh Control
- (NSMutableAttributedString*)refreshBeginString;
- (NSMutableAttributedString*)refreshUpdatingString;
- (NSMutableAttributedString*)refreshFinsihedString;



#pragma mark - Google OAuth
- (void)authorizeGoogle:(UIView*)view;
- (void)authorizationWasSuccessful;
- (void)revokeAccess;


#pragma mark - PFUser Object
@property (nonatomic, strong) NSMutableArray *pfUserArray;
- (PFObject*)searchPFUserByUsername:(NSString*)username;

#pragma mark - MD5 String Array for current user
@property (nonatomic, strong, readonly) NSMutableArray *md5Array; //Store MD5 info to check for duplicate songs, even in the same save
- (void)addStringToMD5Array:(NSString*)md5String;

@end
