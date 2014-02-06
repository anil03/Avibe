//
//  PublicMethod.h
//  Avibe
//
//  Created by Yuhua Mai on 1/14/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ImageFetcher.h"

@interface PublicMethod : NSObject

@property (nonatomic, strong) NSMutableArray *backgroundImages;
//@property (nonatomic, strong) NSDate *lastUpdatedDate;

+ (PublicMethod *)sharedInstance;

#pragma mark - Refresh Control
- (NSMutableAttributedString*)refreshBeginString;
- (NSMutableAttributedString*)refreshUpdatingString;
- (NSMutableAttributedString*)refreshFinsihedString;

@end
