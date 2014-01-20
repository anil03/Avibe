//
//  Constant.m
//  Avibe
//
//  Created by Yuhua Mai on 1/20/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "Constant.h"

@implementation Constant

#pragma mark - Class User
NSString *const kClassUser = @"User";
NSString *const kClassUserUsername = @"username";
NSString *const kClassUserEmail = @"email";
NSString *const kClassUserPhoneNumber = @"additional";

#pragma mark - Class Friend
NSString *const kClassFriend = @"Friend";
NSString *const kClassFriendFromUsername = @"user";
NSString *const kClassFriendToUsername = @"friend";


#pragma mark - Class Share
NSString *const kClassShare = @"Share";
NSString *const kClassShareUsername = @"user";
NSString *const kClassShareTitle = @"title";
NSString *const kClassShareAlbum = @"album";
NSString *const kClassShareArtist = @"artist";
NSString *const kClassShareAlbumImage = @"albumImage";

@end
