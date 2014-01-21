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


#pragma mark - Class Contact
NSString *const kClassContact = @"Contact";
NSString *const kClassContactUsername = @"username_contact";
NSString *const kClassContactEmail = @"email_contact";
NSString *const kClassContactPhoneNumber = @"phoneNumber_contact";

#pragma mark - Class User
NSString *const kClassUser = @"User";
NSString *const kClassUserUsername = @"username";
NSString *const kClassUserEmail = @"email";
NSString *const kClassUserPhoneNumber = @"additional";
NSString *const kClassUserLastFM = @"lastFM";
NSString *const kClassUserRdio = @"rdio";


#pragma mark - Class Friend
NSString *const kClassFriend = @"Friend";
NSString *const kClassFriendFromUsername = @"user";
NSString *const kClassFriendToUsername = @"friend";
NSString *const kClassFriendObjectId = @"objectId";


#pragma mark - Class Share
NSString *const kClassShare = @"Share";
NSString *const kClassShareUsername = @"user";
NSString *const kClassShareTitle = @"title";
NSString *const kClassShareAlbum = @"album";
NSString *const kClassShareArtist = @"artist";
NSString *const kClassShareAlbumImage = @"albumImage";

#pragma mark - Class Song
NSString *const kClassSong = @"Song";
NSString *const kClassSongUsername = @"user";
NSString *const kClassSongTitle = @"title";
NSString *const kClassSongAlbum = @"album";
NSString *const kClassSongArtist = @"artist";

@end
