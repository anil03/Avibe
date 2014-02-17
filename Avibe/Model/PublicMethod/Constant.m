//
//  Constant.m
//  Avibe
//
//  Created by Yuhua Mai on 1/20/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "Constant.h"

/**
 * Constants class for the project.
 */

@implementation Constant

#pragma mark - LastUpdatedDate
NSString *const kKeyLastUpdatedDate = @"lastUpdatedDate";

#pragma mark - Affiliate Token
NSString *const kAffiliateProgramToken = @"1l3v6A8";
NSString *const kKeyRdioUserKey = @"kKeyRdioUserKey";

#pragma mark - Class General
NSString *const kClassGeneralCreatedAt = @"createdAt";

#pragma mark - Class Contact
NSString *const kClassContact = @"Contact";
NSString *const kClassContactUsername = @"username_contact";
NSString *const kClassContactEmail = @"email_contact";
NSString *const kClassContactPhoneNumber = @"phoneNumber_contact";

#pragma mark - Class User
NSString *const kClassUser = @"User";
NSString *const kClassUserUsername = @"username";
NSString *const kClassUserDisplayname = @"displayname";
NSString *const kClassUserEmail = @"email";
NSString *const kClassUserPhoneNumber = @"additional";
NSString *const kClassUserLastFMUsername = @"lastfmUsername";
NSString *const kClassUserFacebookDisplayname = @"facebookDisplayname";
NSString *const kClassUserFacebookUsername = @"facebookUsername";
NSString *const kClassUserFacebookIntegratedWithParse = @"facebookIntegratedWithParse";
NSString *const kClassUserRdioDisplayname = @"rdioDisplayname";
NSString *const kClassUserRdioKey = @"rdioKey";
NSString *const kClassUserGoogleUsername = @"googleUsername";


#pragma mark - Class Friend
NSString *const kClassFriend = @"Friend";
NSString *const kClassFriendFromUsername = @"user";
NSString *const kClassFriendToUsername = @"friend";
NSString *const kClassFriendObjectId = @"objectId";


#pragma mark - Class Share (Should be the same with Song - Dependence in FilterAndSave)
NSString *const kClassShare = @"Share";
NSString *const kClassShareAlbumImage = @"albumImage";

#pragma mark - Class Song
NSString *const kClassSong = @"Song";
NSString *const kClassSongUsername = @"user";
NSString *const kClassSongTitle = @"title";
NSString *const kClassSongAlbum = @"album";
NSString *const kClassSongAlbumURL = @"albumURL";
NSString *const kClassSongAlbumImage = @"albumImage";
NSString *const kClassSongArtist = @"artist";
NSString *const kClassSongSource = @"source";
NSString *const kClassSongMD5 = @"md5";


@end
