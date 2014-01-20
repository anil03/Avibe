//
//  Constant.h
//  Avibe
//
//  Created by Yuhua Mai on 1/20/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constant : NSObject

#pragma mark - Class User
extern NSString *const kClassUser;
extern NSString *const kClassUserUsername;
extern NSString *const kClassUserEmail;
extern NSString *const kClassUserPhoneNumber;

#pragma mark - Class Friend
extern NSString *const kClassFriend;
extern NSString *const kClassFriendFromUsername;
extern NSString *const kClassFriendToUsername;

#pragma mark - Class Share

extern NSString *const kClassShare;
extern NSString *const kClassShareUsername;
extern NSString *const kClassShareTitle;
extern NSString *const kClassShareAlbum;
extern NSString *const kClassShareArtist;
extern NSString *const kClassShareAlbumImage;

@end
