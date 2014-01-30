//
//  AppDelegate.m
//  AddCurrentMusicThenPlaySample
//
//  Created by Yuhua Mai on 11/24/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "AppDelegate.h"

#import <MediaPlayer/MediaPlayer.h>

#import "WelcomeViewController.h"

//Rdio
#import <Rdio/Rdio.h>
#import "RdioConsumerCredentials.h"



@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Check first run user
    static NSString* const hasRunAppOnceKey = @"hasRunAppOnceKey";
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:hasRunAppOnceKey] == NO)
    {
        [defaults setBool:YES forKey:hasRunAppOnceKey];
    }
    
    // Override point for customization after application launch.
    //    NSManagedObjectContext *context = [self managedObjectContext];
    
    //Rdio
//    Rdio *rdio = [[Rdio alloc] initWithConsumerKey:RDIO_CONSUMER_KEY andSecret:RDIO_CONSUMER_SECRET delegate:nil];
    
    //Parse Account
    [Parse setApplicationId:@"Rcx3lFlYc3jGxhpqsYfeqSZ4Lpsd0b6u1J1Etsdu" clientKey:@"sKdduRpy83mgM8lwoT6viMaoFei5eKnBrE9bef55"];
    [PFFacebookUtils initializeFacebook];
    [PFTwitterUtils initializeWithConsumerKey:@"7RufvU8xSuPj6dr9xPipdw"
                               consumerSecret:@"sxxk2HHFyorRfkPmO24GfexGEx3vPRe7t4guTZnGU"];
    
    // Set default ACLs
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    //Background - 600s => 10mins
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:600.0];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    //Set up Welcome View depending on different device
    UIViewController *welcomeController = [[WelcomeViewController alloc] init];
    /*
    if (IS_IPHONE_5) {
        welcomeController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"WelComeViewController"];
    }else{
        welcomeController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"WelComeViewControllerFor3.5"];
    }*/
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:welcomeController];
    self.window.rootViewController = navigationController;
    

    
    
    /*Notification*/
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    MPMusicPlayerController *player = [MPMusicPlayerController iPodMusicPlayer];
    
    [notificationCenter addObserver:self
                           selector:@selector(nowPlayingItemChanged:)
                               name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                             object:player];
    [player beginGeneratingPlaybackNotifications];
    
    return YES;
}


-(void) nowPlayingItemChanged:(NSNotification *)notification {
    MPMusicPlayerController *player = (MPMusicPlayerController *)notification.object;
    
    MPMediaItem *song = [player nowPlayingItem];
    
    if (song) {
        NSString *title = [song valueForProperty:MPMediaItemPropertyTitle];
        NSString *album = [song valueForProperty:MPMediaItemPropertyAlbumTitle];
        NSString *artist = [song valueForProperty:MPMediaItemPropertyArtist];
        NSString *playCount = [song valueForProperty:MPMediaItemPropertyPlayCount];
        
        NSLog(@"title: %@", title);
        NSLog(@"album: %@", album);
        NSLog(@"artist: %@", artist);
        NSLog(@"playCount: %@", playCount);
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    /*Notification*/
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    MPMusicPlayerController *player = [MPMusicPlayerController iPodMusicPlayer];
    
    [notificationCenter addObserver:self
                           selector:@selector(nowPlayingItemChanged:)
                               name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                             object:player];
    [player beginGeneratingPlaybackNotifications];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Core Data

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Song" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Song.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Facebook Delegate
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [PFFacebookUtils handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

#pragma mark - Background Method
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    
    //Increase Badge Number
    [UIApplication sharedApplication].applicationIconBadgeNumber++;
    
    //Tutorial Chapter17 - Adding background fetching
    //Run your app in simulator. In XCode Menu, Go to “Debug” => “Simulate Background Fetch”.
    NSLog(@"########### Received Background Fetch ###########");
    //Download  the Content .
    
    //Test Background Fetch in Parse
    NSDateFormatter *formatter;
    NSString        *dateString;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    dateString = [formatter stringFromDate:[NSDate date]];
    
    PFObject *testObject = [PFObject objectWithClassName:@"TestBackground"];
    [testObject setObject:[NSString stringWithFormat:@"test, %@", dateString] forKey:kClassFriendFromUsername];
    [testObject setObject:@"test" forKey:kClassFriendToUsername];
    [testObject save];
//    completionHandler(UIBackgroundFetchResultNewData);
    
    //iPod Music
    MPMediaItem *currentPlayingSong = [[MPMusicPlayerController iPodMusicPlayer] nowPlayingItem];
    if (currentPlayingSong){
        PFObject *songRecord = [PFObject objectWithClassName:@"Song"];
        NSString *title = [currentPlayingSong valueForProperty:MPMediaItemPropertyTitle];
        title = [title stringByAppendingString:@"Background!"];
        
        [songRecord setObject:title  forKey:@"title"];
        [songRecord setObject:[currentPlayingSong valueForProperty:MPMediaItemPropertyAlbumTitle] forKey:@"album"];
        [songRecord setObject:[currentPlayingSong valueForProperty:MPMediaItemPropertyArtist] forKey:@"artist"];
        [songRecord setObject:[[PFUser currentUser] username] forKey:@"user"];
        
        [songRecord saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Save In Background Mode successfully.");
                
                //Tell the system that you ar done.
                completionHandler(UIBackgroundFetchResultNewData);
            }else{
                completionHandler(UIBackgroundFetchResultFailed);
            }
        }];
    }else{
        completionHandler(UIBackgroundFetchResultNoData);
    }
    
    NSLog(@"########### End Background Fetch ###########");
    
    

}

- (void) application : (UIApplication *)application didReceiveRemoteNotification:
(NSDictionary *)userInfo performFetchWithCompletionHandler:(void(^)
                                                            (UIBackgroundFetchResult))completionHandler
{
    //fetch the latest content
   
}


@end
