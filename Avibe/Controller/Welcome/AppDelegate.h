//
//  AppDelegate.h
//  AddCurrentMusicThenPlaySample
//
//  Created by Yuhua Mai on 11/24/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Rdio/Rdio.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//Core Data
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//Rdio
@property (retain) RDPlayer *rdioPlayer;
@property (readonly) Rdio *rdio;
+ (Rdio *)rdioInstance;

@end
