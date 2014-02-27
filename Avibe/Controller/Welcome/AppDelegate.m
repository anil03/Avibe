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
//#import "RdioConsumerCredentials.h"
static AppDelegate *launchedDelegate;

//SaveMusic
#import "PublicMethod.h"
#import "FilterAndSaveMusic.h"

#import <FacebookSDK/FacebookSDK.h>

@interface AppDelegate()

@property (nonatomic, strong) MPMusicPlayerController *player;
@property (nonatomic, strong) UIViewController *welcomeViewController;

@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


#pragma mark - Init instance
//Rdio
//+ (Rdio *)rdioInstance
//{
//    return launchedDelegate.rdio;
//}


#pragma mark - Application Method
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    
    
    
    /**
     * Rdio
     */
//    launchedDelegate = self;
//    _rdio = [[Rdio alloc] initWithConsumerKey:RDIO_CONSUMER_KEY andSecret:RDIO_CONSUMER_SECRET delegate:nil];
    
    /*
     * Check first run user
     */
    static NSString* const hasRunAppOnceKey = @"hasRunAppOnceKey";
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:hasRunAppOnceKey] == NO)
    {
        [defaults setBool:YES forKey:hasRunAppOnceKey];
    }
    
    // Override point for customization after application launch.
//    NSManagedObjectContext *context = [self managedObjectContext];

    
    /*
     * Set up Parse Account
     */
    [Parse setApplicationId:@"DlQo5mHLeC6vHUQgSneLnEqMeoL0VmLpoSZITnv2" clientKey:@"QLuxJU6Td4rU0B06atRyyru3kWoN8SsiWymtcfGr"];
//    [PFFacebookUtils initializeFacebook]; //Manual sign in with Facebook below
//    [PFTwitterUtils initializeWithConsumerKey:@"7RufvU8xSuPj6dr9xPipdw"  consumerSecret:@"sxxk2HHFyorRfkPmO24GfexGEx3vPRe7t4guTZnGU"];
    
    // Set default ACLs
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    
    
    /*
     *Facebook - make sure that the FBLoginView class is loaded before the view is shown
     */
    [FBLoginView class];
    if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
        //Check for a cached session, if there's one, open the session silently
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info", @"user_actions.music"] allowLoginUI:NO completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            // Handler for session state changes
            // This method will be called EACH time the session state changes,
            // also for intermediate states and NOT just when the session open
            [self sessionStateChanged:session state:status error:error];
        }];
    }
    
    /*
     * Background Fetch - 600s => 10mins
     */
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:600.0];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    //Set up Welcome View depending on different device
    _welcomeViewController = [[WelcomeViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_welcomeViewController];
    self.window.rootViewController = navigationController;
    
    /*
     * Notification
     */
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    _player = [MPMusicPlayerController iPodMusicPlayer];
    [notificationCenter addObserver:self
                           selector:@selector(nowPlayingItemChanged:)
                               name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                             object:_player];
    [_player beginGeneratingPlaybackNotifications];
    
    return YES;
}


#pragma mark - Background Method
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"########### Received Background Fetch ###########");
    
    //Test Parse Background
    PFObject *pfObject = [PFObject objectWithClassName:@"BackgroundFetch"];
    [pfObject setObject:[NSDate date] forKey:@"BackgroundFetchDate"];
    [pfObject saveInBackground];
    
    
    MPMediaItem *currentPlayingSong = [[MPMusicPlayerController iPodMusicPlayer] nowPlayingItem];
    if (currentPlayingSong){
        [[[PublicMethod sharedInstance] saveMusicFromSources] saveMusicInBackground];
        completionHandler(UIBackgroundFetchResultNewData);
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

#pragma mark - Notification
-(void)nowPlayingItemChanged:(NSNotification *)notification {
    MPMusicPlayerController *player = (MPMusicPlayerController *)notification.object;
    MPMediaItem *song = [player nowPlayingItem];
    
    if (song && [[PFUser currentUser] isAuthenticated]) {
        NSString *title = [song valueForProperty:MPMediaItemPropertyTitle];
        NSString *album = [song valueForProperty:MPMediaItemPropertyAlbumTitle];
        NSString *artist = [song valueForProperty:MPMediaItemPropertyArtist];
        NSString *playCount = [song valueForProperty:MPMediaItemPropertyPlayCount];
        
        NSLog(@"title: %@", title);
        NSLog(@"album: %@", album);
        NSLog(@"artist: %@", artist);
        NSLog(@"playCount: %@", playCount);
        
        [self saveIPodMusic:@"iPodItemChanged"];
    }
}
- (void)saveIPodMusic:(NSString*)source
{
    MPMediaItem *currentPlayingSong = [[MPMusicPlayerController iPodMusicPlayer] nowPlayingItem];
    PFObject *songRecord = [PFObject objectWithClassName:kClassSong];
    [songRecord setObject:[currentPlayingSong valueForProperty:MPMediaItemPropertyTitle]  forKey:kClassSongTitle];
    [songRecord setObject:[currentPlayingSong valueForProperty:MPMediaItemPropertyAlbumTitle] forKey:kClassSongAlbum];
    [songRecord setObject:[currentPlayingSong valueForProperty:MPMediaItemPropertyArtist] forKey:kClassSongArtist];
    [songRecord setObject:[[PFUser currentUser] username] forKey:kClassSongUsername];
    [songRecord setObject:source forKey:kClassSongSource];
    
    FilterAndSaveMusic *filter = [[FilterAndSaveMusic alloc] init];
//    filter.delegate = self;
    
    PFQuery *postQuery = [PFQuery queryWithClassName:@"Song"];
    [postQuery whereKey:kClassSongUsername equalTo:[[PFUser currentUser] username]];
    [postQuery orderByDescending:kClassGeneralCreatedAt]; //Get latest song
    postQuery.limit = 1000;
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [filter filterDuplicatedDataToSaveInParse:[NSMutableArray arrayWithObject:songRecord] andSource:source andFetchObjects:objects];
        //Increase Badge Number
        [UIApplication sharedApplication].applicationIconBadgeNumber++;
    }];
    
}

#pragma mark - Application Method
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [_player endGeneratingPlaybackNotifications];
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [_player beginGeneratingPlaybackNotifications];
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Facebook Delegate
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}
// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        // Show the user the logged-in UI
//        [self userLoggedIn];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
//        [self userLoggedOut];
    }
    
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
//            [self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
//                [self showMessage:alertText withTitle:alertTitle];
                
                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
//                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
//        [self userLoggedOut];
    }
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



@end
