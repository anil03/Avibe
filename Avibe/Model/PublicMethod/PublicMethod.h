//
//  PublicMethod.h
//  Avibe
//
//  Created by Yuhua Mai on 1/14/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PublicMethod : NSObject

+ (PublicMethod *)sharedInstance;
-(void)filterDuplicatedDataToSaveInParse:(NSMutableArray*)musicToSave andSource:(NSString*)sourceName andFetchObjects:(NSArray*)fetechObjects;

@end
