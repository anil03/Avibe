//
//  FilterAndSaveObjects.h
//  Avibe
//
//  Created by Yuhua Mai on 1/19/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FilterAndSaveMusicDelegate <NSObject>

- (void)dataSavedSucceed;
- (void)dataSavedWithDuplicate;
- (void)dataSavedFailed:(NSError*)error;

@end

@interface FilterAndSaveMusic : NSObject

@property (nonatomic, weak) id<FilterAndSaveMusicDelegate> delegate;

-(void)filterDuplicatedDataToSaveInParse:(NSMutableArray*)musicToSave andSource:(NSString*)sourceName andFetchObjects:(NSArray*)fetechObjects;

@end
