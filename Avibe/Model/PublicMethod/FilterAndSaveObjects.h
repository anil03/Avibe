//
//  FilterAndSaveObjects.h
//  Avibe
//
//  Created by Yuhua Mai on 1/19/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FilterAndSaveObjectsDelegate <NSObject>

- (void)dataSavedSucceed;
- (void)dataSavedWithDuplicate;
- (void)dataSavedFailed:(NSError*)error;

@end

@interface FilterAndSaveObjects : NSObject

@property (nonatomic, weak) id<FilterAndSaveObjectsDelegate> delegate;

-(void)filterDuplicatedDataToSaveInParse:(NSMutableArray*)musicToSave andSource:(NSString*)sourceName andFetchObjects:(NSArray*)fetechObjects;

@end
