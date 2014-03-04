//
//  PublicMethod.m
//  Avibe
//
//  Created by Yuhua Mai on 1/14/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "PublicMethod.h"
#import "BackgroundImageView.h"
#import "GoogleOAuth.h"
#import "UIViewController+MMDrawerController.h"
#import "MMNavigationController.h"
#import "SaveMusicFromSources.h"

@interface PublicMethod()<GoogleOAuthDelegate>

@property (nonatomic, strong) GoogleOAuth *googleOAuth;

@property (nonatomic, strong) NSMutableArray *md5Array; //Store MD5 info to check for duplicate songs, even in the same save

@end

@implementation PublicMethod

+ (PublicMethod *)sharedInstance
{
    static PublicMethod *sharedInstance;
    
    @synchronized(self)
    {
        if (!sharedInstance){
            sharedInstance = [[PublicMethod alloc] init];
        }
            
        return sharedInstance;
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        _pfUserArray = [[NSMutableArray alloc] init];
        
        _backgroundImages = [[NSMutableArray alloc] init];
        [self setupBackImages];
        
        
        
    }
    return self;
}

#pragma mark - Instance
- (SaveMusicFromSources *)saveMusicFromSources
{
    if (!_saveMusicFromSources) {
        _saveMusicFromSources = [[SaveMusicFromSources alloc] init];
    }
    
    return _saveMusicFromSources;
}

#pragma mark - Google
- (GoogleOAuth *)googleOAuth
{
    //Lazy init
    /*Google OAuth*/
    if (!_googleOAuth) {
        float barHeight = 10.0f;
        float buttomOffset = 80.0f;
        _googleOAuth = [[GoogleOAuth alloc] initWithFrame:CGRectMake(0, barHeight, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-buttomOffset)];
        _googleOAuth.scrollView.scrollEnabled = YES;
//        _googleOAuth.scalesPageToFit = YES;
        [_googleOAuth setGOAuthDelegate:self];
    }
    return _googleOAuth;
}

#pragma mark - Fetch images
- (void)setupBackImages
{
    NSUInteger limit = 500;
    NSString *urlString = [NSString stringWithFormat:@"http://developer.echonest.com/api/v4/song/search?api_key=9PFPYZSZPU9X2PKES&format=json&results=%lu&bucket=song_hotttnesss&sort=song_hotttnesss-desc",limit];
    NSURL *searchUrl = [NSURL URLWithString:urlString];
//    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        searchUrl];
        [self performSelectorOnMainThread:@selector(fetchHotArtistListFromEchoNest:)
                               withObject:data waitUntilDone:YES];
//    });
}
- (void)fetchHotArtistListFromEchoNest:(NSData*)responseData
{
    //Artist used to search artist album image from iTune
    NSMutableSet *artistArray;
    if(!responseData){
        artistArray = [NSMutableSet setWithArray:@[@"Justin+Timberlake", @"Katy+Perry", @"Pitbull", @"OneRepublic", @"Eminem", @"One+Direction", @"Passenger", @"Lorde", @"Avicii", @"Imagine+Dragons", @"Beyonce", @"Miley+Cyrus", @"Rihanna", @"Lady+Gaga", @"Calvin+Harris", @"Rihanna", @"Daft+Punk", @"Bastille", @"Drake", @"Jason+Derulo", @"Lana+Del+Rey", @"Martin+Garrix", @"Britney+Spears", @"Robin+Thicke", @"Macklemore", @"Ryan+Lewis", @"Michael+Buble", @"Stromae", @"Arctic+Moneys", @"Pharrell", @"Justin+Bieber", @"John+Newman", @"Demi+Lovato", @"Ed+Sheeran", @"Kid+Ink", @"Lily+Allen", @"Adele", @"Beatles", @"Killers", @"Leona", @"Greenday", @"Ariana+Grande", @"Westlife"]];
    }else{
        artistArray = [[NSMutableSet alloc] init];
        
        NSError* error = nil;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        NSDictionary *songs;
        if(json && json[@"response"]){
            songs = json[@"response"][@"songs"];
        }
        if(songs){
            for(NSDictionary *song in songs){
                NSString *title = song[@"title"];
                NSString *artist = song[@"artist_name"];
                
                [artistArray addObject:artist];
            }
        }
    }
    
    
    /*
     * Search hot artist one by one
     * Online search for background images, but slow
     */
    for(NSString *artist in artistArray){
        [self searchForImages:1 andTerm:artist];
    }

}

/**
 * Hugely improve app loading speed for just load image at the frist time, then save locally
 * Next time, just load local image instead of download images again.
 */
- (void)searchForImages:(NSInteger)limit andTerm:(NSString*)term
{
    //Paths to Save or Load
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *imageName = [basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", term]];
    
    //Check the term image has existed
    UIImage *imageToLoad = [UIImage imageWithContentsOfFile:imageName];
    
    if (imageToLoad) {
        [_backgroundImages addObject:imageToLoad];
    }else{
        ImageFetcher *imageFetcher = [[ImageFetcher alloc] initWithLimit:limit andTerm:term];
        for(UIImage *image in [imageFetcher getAlbumImages]){
            [_backgroundImages addObject:image];
            
            UIImage * imageToSave = image;
            NSData * binaryImageData = UIImagePNGRepresentation(imageToSave);
            [binaryImageData writeToFile:imageName atomically:YES];
        }
    }
}
- (NSArray *)backgroundImages
{
    NSMutableArray *shuffleBackGroundImages = [[NSMutableArray alloc] initWithArray:_backgroundImages];
    NSUInteger count = [shuffleBackGroundImages count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = arc4random_uniform((int)nElements) + i;
        [shuffleBackGroundImages exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    return shuffleBackGroundImages;
}


#pragma mark - Refresh Control
- (NSMutableAttributedString*)refreshBeginString
{
    NSString *lastUpdated = @"Pull to Refresh";
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:lastUpdated];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0,[lastUpdated length])];
    
    return string;
}
- (NSMutableAttributedString*)refreshUpdatingString
{
    NSString *lastUpdated = @"Refreshing data...";
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:lastUpdated];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0,[lastUpdated length])];
    
    return string;
}
/**
 * When finish update, update the lastUpdatedDate
 */
- (NSMutableAttributedString*)refreshFinsihedString
{
    //update lastUpdateDate
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastUpdatedDate = [NSDate date];
    [defaults setObject:lastUpdatedDate forKey:kKeyLastUpdatedDate];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",[formatter stringFromDate:[NSDate date]]];
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:lastUpdated];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0,[lastUpdated length])];
    
    return string;
}

#pragma mark - Google OAuth
- (void)authorizeGoogle:(UIView*)view {
    //    [_googleOAuth authorizeUserWithClienID:@"746869634473-hl2v6kv6e65r1ak0u6uvajdl5grrtsgb.apps.googleusercontent.com"
    //                           andClientSecret:@"_FsYBVXMeUD9BGzNmmBvE9Q4"
    //                             andParentView:self.view
    //                                 andScopes:[NSArray arrayWithObjects:@"https://www.googleapis.com/auth/userinfo.profile", nil]
    //     ];
    [self.googleOAuth authorizeUserWithClienID:@"4881560502-uteihtgcnas28bcjmnh0hfrbk4chlmsa.apps.googleusercontent.com"
                           andClientSecret:@"R02t8Pk-59eEYy-B359-gvOY"
                             andParentView:view
                                 andScopes:[NSArray arrayWithObjects:@"https://www.googleapis.com/auth/youtube", @"https://www.googleapis.com/auth/youtube.readonly",@"https://www.googleapis.com/auth/youtubepartner",@"https://www.googleapis.com/auth/youtubepartner-channel-audit", nil]
     ];
}
- (void)revokeAccess{
    [self.googleOAuth revokeAccessToken];
}

-(void)authorizationWasSuccessful{
    [self.googleOAuth callAPI:@"https://www.googleapis.com/youtube/v3/channels"
           withHttpMethod:httpMethod_GET
       postParameterNames:[NSArray arrayWithObjects:@"part",@"mine",nil] postParameterValues:[NSArray arrayWithObjects:@"contentDetails",@"true",nil]];
    
    //    [_googleOAuth callAPI:@"https://www.googleapis.com/oauth2/v1/userinfo"
    //           withHttpMethod:httpMethod_GET
    //       postParameterNames:nil postParameterValues:nil];
}
-(void)accessTokenWasRevoked{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"Your access was revoked!"
                                                   delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}
-(void)errorOccuredWithShortDescription:(NSString *)errorShortDescription andErrorDetails:(NSString *)errorDetails{
    NSLog(@"%@", errorShortDescription);
    NSLog(@"%@", errorDetails);
}
-(void)errorInResponseWithBody:(NSString *)errorMessage{
    NSLog(@"%@", errorMessage);
}
-(void)responseFromServiceWasReceived:(NSString *)responseJSONAsString andResponseJSONAsData:(NSData *)responseJSONAsData{
    NSError *error;
    NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseJSONAsData
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:&error];
    if (error) {
        NSLog(@"An error occured while converting JSON data to dictionary.");
        return;
    }
    NSLog(@"%@", dictionary);
    
    NSString *kind = [dictionary objectForKey:@"kind"];
    if ([kind rangeOfString:@"channelListResponse"].location != NSNotFound){
        NSMutableArray *items = [dictionary objectForKey:@"items"];
        NSMutableDictionary *contentDetails = [items[0] objectForKey:@"contentDetails"];
        NSMutableDictionary *relatedPlaylists = [contentDetails objectForKey:@"relatedPlaylists"];
        //likes, uploads, watchHistory, favorites, watchLater
        NSString *watchHistory = [relatedPlaylists objectForKey:@"watchHistory"];
        NSLog(@"WatchHistory playListID:%@", watchHistory);
        
        //Get playlist items
        [self.googleOAuth callAPI:@"https://www.googleapis.com/youtube/v3/playlistItems"
               withHttpMethod:httpMethod_GET
           postParameterNames:[NSArray arrayWithObjects:@"part",@"playlistId",nil] postParameterValues:[NSArray arrayWithObjects:@"snippet",watchHistory,nil]];
        
    }
    
    if ([kind rangeOfString:@"playlistItemListResponse"].location != NSNotFound) {
        NSMutableArray *items = [dictionary objectForKey:@"items"];
        
        NSMutableArray *videoIds = [[NSMutableArray alloc] init];
        
        for(NSMutableDictionary *item in items){
            NSMutableDictionary *snippet = [item objectForKey:@"snippet"];
            //Snippet: desciption, thumbnails, publishedAt, channelTitle, playlistId, channelId, resourceId, title
//            NSString *title = [snippet objectForKey:@"title"];
            //Thumbnails
//            NSMutableDictionary *thumbnails = [snippet objectForKey:@"thumbnails"];
//            NSMutableDictionary *high = [thumbnails objectForKey:@"high"];
//            NSString *thumbnailHighURL = [high objectForKey:@"url"];
            NSString *videoId;
            if (snippet && snippet[@"resourceId"]) {
                 videoId = snippet[@"resourceId"][@"videoId"];
            }
            
//            NSLog(@"Title:%@, ThumbnailUrl:%@", title, thumbnailHighURL);
            
            //Get VideoId type
            if (videoId) {
                [videoIds addObject:videoId];
            }
        }
        
        NSString *videoIdCall = [videoIds componentsJoinedByString:@","];
        //Call API for Video categoryId
        if (videoIdCall) {
            [self.googleOAuth callAPI:@"https://www.googleapis.com/youtube/v3/videos"
                       withHttpMethod:httpMethod_GET
                   postParameterNames:[NSArray arrayWithObjects:@"part",@"id",nil] postParameterValues:[NSArray arrayWithObjects:@"snippet",videoIdCall,nil]];
        }
    }
    
    if ([kind rangeOfString:@"videoListResponse"].location != NSNotFound){
        NSMutableArray *entries = [[NSMutableArray alloc] init];

        NSMutableArray *items = [dictionary objectForKey:@"items"];
        
        for(NSMutableDictionary *item in items){
            NSMutableDictionary *snippet = [item objectForKey:@"snippet"];
            NSString *categoryId = snippet[@"categoryId"];
            
            if ([categoryId isEqualToString:@"10"]) {
                NSString *title;
                if (snippet) {
                    title = snippet[@"title"];
                }
                NSString *thumbnailUrl;
                if (snippet && snippet[@"thumbnails"] && snippet[@"thumbnails"][@"high"]) {
                    thumbnailUrl = snippet[@"thumbnails"][@"high"][@"url"];
                }
                
                //Save to Parse
                NSMutableDictionary *entry = [[NSMutableDictionary alloc] init];
                if(title) [entry setObject:title forKey:@"title"];
                if(thumbnailUrl) [entry setObject:thumbnailUrl forKey:@"url"];
                [entries addObject:entry];
            }
        }
        
        [SaveMusicFromSources saveYoutubeEntry:entries];

    }
}


#pragma mark - PFUser Object
- (PFObject*)searchPFUserByUsername:(NSString*)username
{
    //Find username in PFUserArray
    for(PFObject *user in _pfUserArray){
        NSString *usernameInObject = [user objectForKey:kClassUserUsername];
        if (usernameInObject && [usernameInObject isEqualToString:username]) {
            return user;
        }
    }
    
    //Can't find the user, fetch from Parse
    PFQuery *query = [PFUser query];
    [query whereKey:kClassUserUsername equalTo:username];
    PFObject *user = [query getFirstObject];
    if (user) {
        [_pfUserArray addObject:user];
    }
    
    return user;
}

#pragma mark - Save MD5 string for current user, set up when first log in
- (NSMutableArray *)md5Array
{
    if (!_md5Array) {
        _md5Array = [[NSMutableArray alloc] init];
        
        //Fetch Existing Songs from Parse
        PFQuery *songQuery = [PFQuery queryWithClassName:kClassSong];
        [songQuery whereKey:kClassSongUsername equalTo:[[PFUser currentUser] username]];
        [songQuery orderByDescending:kClassGeneralCreatedAt]; //Get latest song
    
#warning Long time parse
        NSArray *objects = [songQuery findObjects];
        for(PFObject *existingPFObject in objects){
            NSString *md5 = [existingPFObject objectForKey:kClassSongMD5];
            if(md5){
                [_md5Array addObject:md5];
            }
        }
    }
    return _md5Array;
}
- (void)addStringToMD5Array:(NSString *)md5String
{
    [self.md5Array addObject:md5String];
}


@end
