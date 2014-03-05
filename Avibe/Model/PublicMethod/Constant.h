//
//  Constant.h
//  Avibe
//
//  Created by Yuhua Mai on 1/20/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constant : NSObject

#pragma mark - LastUpdatedDate
extern NSString *const kKeyLastUpdatedDate;

#pragma mark - Affiliate Token & Rdio Key
extern NSString *const kAffiliateProgramToken;
extern NSString *const kKeyRdioUserKey;

#pragma mark - Class General
extern NSString *const kClassGeneralCreatedAt;

#pragma mark - Class Contact
extern NSString *const kClassContact;
extern NSString *const kClassContactUsername;
extern NSString *const kClassContactEmail;
extern NSString *const kClassContactPhoneNumber;

#pragma mark - Class User
extern NSString *const kClassUser;
extern NSString *const kClassUserUsername;
extern NSString *const kClassUserDisplayname;
extern NSString *const kClassUserEmail;
extern NSString *const kClassUserProfileImage;
extern NSString *const kClassUserPhoneNumber;
extern NSString *const kClassUserLastFMUsername;
extern NSString *const kClassUserFacebookDisplayname;
extern NSString *const kClassUserFacebookUsername;
extern NSString *const kClassUserFacebookIntegratedWithParse;
extern NSString *const kClassUserRdioDisplayname;
extern NSString *const kClassUserRdioKey;
extern NSString *const kClassUserGoogleUsername;

#pragma mark - Class Friend
extern NSString *const kClassFriend;
extern NSString *const kClassFriendFromUsername;
extern NSString *const kClassFriendToUsername;
extern NSString *const kClassFriendObjectId;

#pragma mark - Class Share
extern NSString *const kClassShare;
extern NSString *const kClassShareAlbumImage;

#pragma mark - Class Song
extern NSString *const kClassSong;
extern NSString *const kClassSongUsername;
extern NSString *const kClassSongTitle;
extern NSString *const kClassSongAlbum;
extern NSString *const kClassSongAlbumURL;
extern NSString *const kClassSongAlbumImage;
extern NSString *const kClassSongArtist;
extern NSString *const kClassSongSource;
extern NSString *const kClassSongMD5;


@end
