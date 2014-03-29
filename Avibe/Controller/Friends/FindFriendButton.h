//
//  FindFriendButton.h
//  Avibe
//
//  Created by Yuhua Mai on 1/20/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindFriendButton : UIButton

@property (nonatomic, strong) NSMutableDictionary *person;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *username_contact;
@property (nonatomic, strong) NSArray *phoneNumber_contact;
@property (nonatomic, strong) NSArray *email_contact;
@property (nonatomic, strong) NSString *friendObjectId;

@end
