//
//  Setting.h
//  Beet
//
//  Created by Yuhua Mai on 12/28/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Setting : NSObject

@property (nonatomic, strong) NSString *lastFMAccount;

- (UIColor*)sharedBackgroundColor;
- (UIColor*)sharedCellColor;

- (UIColor*)primary1Color;

+ (Setting *)sharedSetting;


@end
