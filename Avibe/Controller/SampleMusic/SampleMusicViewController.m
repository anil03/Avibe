//
//  SampleMusicYoutubeViewController.m
//  Avibe
//
//  Created by Yuhua Mai on 1/14/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "SampleMusicViewController.h"

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import "UIViewController+MMDrawerController.h"
#import "ShareMusicEntry.h"
#import "Setting.h"
#import "SampleMusic.h"
#import "MMNavigationController.h"

#import "PublicMethod.h"
#import "GlobalPlayer.h"

//Rdio
#import "RdioConsumerCredentials.h"
#import <Rdio/Rdio.h>

//Echo NEst
#import "NSMutableArray+Shuffling.h"

//Youtube
#import "LBYouTube.h"
#import "XCDYouTubeVideoPlayerViewController.h"

@interface SampleMusicViewController () <UIWebViewDelegate, SampleMusicDelegate, AVAudioPlayerDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, GlobalPlayerDelegate>
{
    UIColor *backgroundColor;
    UIColor *scrollViewBackgroundColor;
    UIColor *lightBackgroundColor;
    UIColor *textColor;
    UIColor *textHighlightColor;
    
    float width;
    float height;
    float backgroundImageHeight;
    float playerHeight;
    float currentHeight;
    float buttonLeft;
    float buttonHeight;
    
    float barHeight;
    
    //iTune View
    float playerImageWidth;
    float playerImageHeight;
    float playerLabelWidth;
    float playerLabelHeight;
    float playerProgressWidth;
    float playerProgressHeight;
    float playerButtonWidth;
    float playerButtonHeight;
    
    float bottomOfScrollView;
}

//View
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIView *listenInView;
@property (nonatomic, strong) UIView *buyInView;
@property (nonatomic, strong) UIAlertView *alertBeforeSwitchToITune;

@property (nonatomic, strong) UIActivityIndicatorView *spinner;


//Youtube
@property (strong, nonatomic) MPMoviePlayerController* moviePlayer;
@property UIView *sampleMusicYoutubeView;
@property XCDYouTubeVideoPlayerViewController *videoPlayerViewController;
@property NSString *youtubeVideoLink;
@property (strong, nonatomic) UIWebView *sampleMusicWebView;

//iTune
@property (strong, nonatomic) SampleMusic *samepleMusic;
@property (strong, nonatomic) UIView *sampleMusicITuneView;
@property (strong, nonatomic) UIImageView *sampleMusicImageView;
@property (strong, nonatomic) UILabel *playedTime;
@property (strong, nonatomic) UILabel *leftTime;
//@property (strong, nonatomic) UISlider *progress;
@property (strong, nonatomic) UIProgressView *progress;
@property (strong, nonatomic) NSTimer *progressTimer;
@property (strong, nonatomic) UIButton *playButton;
@property UIButton *shareButton;
@property UIButton *playSourceButton;
@property UIButton *iTuneButton;
@property (nonatomic, retain) AVAudioPlayer *player;
@property (nonatomic, strong) UIImage *albumImage;

//iTune fetch error
@property UIAlertView *iTuneFetchErrorAlertView;

//Song Info
@property NSString *songMd5;
@property (nonatomic, strong) NSString *songTitle;
@property (nonatomic, strong) NSString *songAlbum;
@property (nonatomic, strong) NSString *songArtist;
@property NSString *songImageUrlString;
@property NSString *songPreviewUrlString;
@property (nonatomic, strong) NSString *collectionViewUrlLinkToITuneStore;

@property (nonatomic, strong) ShareMusicEntry *shareMusicEntry;

//Rdio
@property (readonly) Rdio *rdio;
@property NSString *rdio_userkey;

//PFObject of current song
@property PFObject *pfObject;

//Global player
@property GlobalPlayer *globalPlayer;

//MoreLikeThis View - UITableView
@property (nonatomic, strong) UIView *addMoreLikeThisView;
@property UILabel *moreLabel;
@property (nonatomic, strong) NSMutableArray *songsForTableView;
@property UITableView *tableView;
@property int tableViewRows;
@property float tableViewRowHeight;

//Select Music to SampleMusic from Echo Nest
@property (nonatomic, strong) MMNavigationController *navigationControllerForSampleMusic;
@property (nonatomic, strong) SampleMusicViewController *sampleMusicViewController;
@property NSMutableArray *artistsArrray;
@property NSUInteger artistFetchCount;

//NavigationBar
@property UILabel *navigationBarTitleLabel;

@end

@implementation SampleMusicViewController
@synthesize moviePlayer;
@synthesize scrollView;

@synthesize moreLabel;
@synthesize tableView;

#pragma mark - Init method
- (void)checkInfoValid
{
    if (!_songMd5) _songMd5 = @" ";
    
    if (!_songTitle) _songTitle = @" ";
    _songTitle =  [NSString stringWithUTF8String:[_songTitle UTF8String]];
    if (!_songAlbum) _songAlbum = @" ";
    _songAlbum =  [NSString stringWithUTF8String:[_songAlbum UTF8String]];
    if (!_songArtist) _songArtist = @" ";
    _songArtist =  [NSString stringWithUTF8String:[_songArtist UTF8String]];
    
    
}
- (id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    
    if (self) {
        _songTitle = [dictionary objectForKey:@"title"];
        _songAlbum = [dictionary objectForKey:@"album"];
        _songArtist = [dictionary objectForKey:@"artist"];
        [self checkInfoValid];
    }
    
    return self;
}
- (id)initWithPFObject:(PFObject*)object
{
    self = [super init];
    if (self) {
        _pfObject = object;
        _songMd5 = _pfObject[kClassSongMD5];
        _songTitle = [_pfObject objectForKey:kClassSongTitle];
        _songAlbum = [_pfObject objectForKey:kClassSongAlbum];
        _songArtist = [_pfObject objectForKey:kClassSongArtist];
        [self checkInfoValid];
        
        _globalPlayer = [[PublicMethod sharedInstance] globalPlayer];
        [_globalPlayer setDelegate:self];
    }
    return self;
}

#pragma mark - Set up views
- (void)viewWillDisappear:(BOOL)animated
{
    [_player pause];
    _player = nil;
    
    //Stop XCDYoutubeController
    [_videoPlayerViewController.moviePlayer stop];
    _videoPlayerViewController = nil;
    _sampleMusicYoutubeView = nil;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    /**
     * Should set up everytime appear
     * Otherwise the navigation item may be the item of last view, not current view
     * Why not called inside NavigationController?
     */
    [self setupNavigationBar];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupParameter];
    [self setupNavigationBar];

    //Navigation bar title
    _navigationBarTitleLabel.text = [NSString stringWithFormat:@"%@ - %@", _songTitle, _songArtist];
    
    //More like this setup
    _artistsArrray = [[NSMutableArray alloc] init];
    _artistFetchCount = 0;
    _songsForTableView = [[NSMutableArray alloc] init];
    
    [self setupMusicView];
    
    
    /*
     * Prepare global player current song
     */
    [_globalPlayer setCurrentSongByMd5:_songMd5];
    [_globalPlayer prepareCurrentSong];
    
    /**
     * Preview Url existed, then no need to search from iTune
     */
//    NSString *previewUrlString = [_pfObject objectForKey:kClassSongDataURL];
//    if (previewUrlString) {
//        [self handleAudioPlayer:previewUrlString];
//    }else{
//        [self listenInItune];
//    }
    
    /**
     * XCDYoutubeController
     */
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{ @"VideoIdentifier": @"9bZkp7q19f0" }];
	
	NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter addObserver:self selector:@selector(videoPlayerViewControllerDidReceiveMetadata:) name:XCDYouTubeVideoPlayerViewControllerDidReceiveMetadataNotification object:nil];
	[defaultCenter addObserver:self selector:@selector(moviePlayerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	[defaultCenter addObserver:self selector:@selector(moviePlayerPlaybackStateDidChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
	[defaultCenter addObserver:self selector:@selector(moviePlayerLoadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
}
- (void)setupParameter
{
    backgroundColor = [UIColor clearColor];
    lightBackgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1];
    
    textColor = [UIColor whiteColor];
    textHighlightColor = [UIColor grayColor];

    //Size Specification
    barHeight = self.mm_drawerController.navigationController.navigationBar.frame.size.height;
//    float titleLabelHeight = 30;
//    float infoLabelHight = 30;
    float bottomOffset = 15;
    
    width = [[UIScreen mainScreen] bounds].size.width;
    height = [[UIScreen mainScreen] bounds].size.height-bottomOffset;
    
    buttonHeight = 40;
    buttonLeft = 10;
    currentHeight = 0;
}

#pragma mark - Add SubView
- (void)setupMusicView
{
    playerHeight = 200;
    
    playerImageWidth = 200;//width/2;
    playerImageHeight = 200;//playerHeight*2/3;
    
    playerProgressWidth = width*2/3;
    playerProgressHeight = 36.0;
    playerLabelWidth = 36.0f;
    playerLabelHeight = playerProgressHeight;
    
    playerButtonWidth = 36.0f;
    playerButtonHeight = playerButtonWidth;
    
    float buttonSize = 24;
    
    //iTune Image View
    float imageViewTopOffset = 30.0f;
    _sampleMusicImageView = [[UIImageView alloc] initWithFrame:CGRectMake(width/2-playerImageWidth/2, barHeight+imageViewTopOffset, playerImageWidth, playerImageHeight)];
    _sampleMusicYoutubeView = [[UIView alloc] initWithFrame:CGRectMake(0, barHeight+imageViewTopOffset, width, playerImageHeight)];
    [self.view addSubview:_sampleMusicImageView];
    
    //More like this
    float moreLikeThisViewTopOffset = 10.0f;
    float moreLikeThisViewBottomOffset = 10.0f;
    float moreLikeThisViewHeight = height-(barHeight+imageViewTopOffset+playerImageHeight+moreLikeThisViewTopOffset+moreLikeThisViewBottomOffset)-playerButtonHeight-playerProgressHeight;
    _addMoreLikeThisView = [[UIView alloc] initWithFrame:CGRectMake(0, barHeight+imageViewTopOffset+playerImageHeight+moreLikeThisViewTopOffset, width, moreLikeThisViewHeight)];
    [_addMoreLikeThisView setHidden:YES];
    [self.view addSubview:_addMoreLikeThisView];
    
    //More Like this Parameter
    _tableViewRows = 8;
    _tableViewRowHeight = 50.0f;
    [self addSimilarSongView];
    
    //Progress View
    _progress = [[UIProgressView alloc] initWithFrame:CGRectMake(width/2-playerProgressWidth/2, height-playerButtonHeight-playerProgressHeight/2, playerProgressWidth, playerProgressHeight)];
    [_progress setProgressViewStyle:UIProgressViewStyleBar];
    [self.view addSubview:_progress];
    
    float fontSize = 12.0;
    _playedTime = [[UILabel alloc] initWithFrame:CGRectMake(width/2-playerProgressWidth/2-playerLabelWidth, height-playerButtonHeight-playerProgressHeight, playerLabelWidth, playerLabelHeight)];
    _playedTime.textColor = textColor;
    _playedTime.font = [UIFont systemFontOfSize:fontSize];
    _playedTime.backgroundColor = backgroundColor;
    _playedTime.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:_playedTime];
    
    _leftTime = [[UILabel alloc] initWithFrame:CGRectMake(width/2+playerProgressWidth/2, height-playerButtonHeight-playerProgressHeight, playerLabelWidth, playerLabelHeight)];
    _leftTime.textColor = textColor;
    _leftTime.font = [UIFont systemFontOfSize:fontSize];
    _leftTime.backgroundColor = backgroundColor;
    _leftTime.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:_leftTime];
    
    //Button View
    [_playButton removeFromSuperview];
    _playButton = [[UIButton alloc] initWithFrame:CGRectMake(width/2-playerButtonWidth/2, height-playerButtonHeight, playerButtonWidth, playerButtonHeight)];
    [_playButton addTarget:self action:@selector(playOrPause) forControlEvents:UIControlEventTouchUpInside];
    
    [_playButton setBackgroundImage:[UIImage imageNamed:@"start-32.png"] forState:UIControlStateNormal];
    [_playButton setBackgroundImage:[UIImage imageNamed:@"stop-32.png"] forState:UIControlStateSelected];
    
    //    [_playButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    //    [_playButton setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    //    [_playButton setTitle:@"▶︎" forState:UIControlStateNormal];
    //    [_playButton setTitle:@"◼︎" forState:UIControlStateSelected];
    [_playButton setHidden:YES];
    [self.view addSubview:_playButton];
    
    //Share button
    _shareButton = [[UIButton alloc] initWithFrame:CGRectMake(width/2-buttonSize*9/2, height-buttonSize, buttonSize, buttonSize)];
    UIImage *shareButtonImage = [UIImage imageNamed:@"outline-star-32.png"];
    [_shareButton setBackgroundImage:shareButtonImage forState:UIControlStateNormal];
    [_shareButton addTarget:self action:@selector(shareMusic) forControlEvents:UIControlEventTouchUpInside];
    [_shareButton setHidden:YES];
    [self.view addSubview:_shareButton];
    
    //Play source button
    _playSourceButton = [[UIButton alloc] initWithFrame:CGRectMake(width/2-buttonSize*5/2, height-buttonSize, buttonSize, buttonSize)];
    [_playSourceButton setBackgroundImage:[UIImage imageNamed:@"youtube-48.png"] forState:UIControlStateNormal];
    [_playSourceButton setBackgroundImage:[UIImage imageNamed:@"youtube-48-highlight.png"] forState:UIControlStateHighlighted];
    [_playSourceButton addTarget:self action:@selector(listenInYoutube) forControlEvents:UIControlEventTouchUpInside];
    [_playSourceButton setHidden:YES];
    [self.view addSubview:_playSourceButton];
    
    //Buy in iTune button
    _iTuneButton = [[UIButton alloc] initWithFrame:CGRectMake(width/2+buttonSize*3/2, height-buttonSize, 64, 24)];
    [_iTuneButton setBackgroundImage:[UIImage imageNamed:@"Download_on_iTunes_Badge_US-UK_110x40_1004"] forState:UIControlStateNormal];
    [_iTuneButton addTarget:self action:@selector(buyInItune) forControlEvents:UIControlEventTouchUpInside];
    //    [_iTuneButton setBackgroundColor:[UIColor whiteColor]];
    [_iTuneButton setHidden:YES];
    [self.view addSubview:_iTuneButton];
    
    //Spinner
    _spinner = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    _spinner.hidesWhenStopped = YES;
    [self.view addSubview:_spinner];
    [self.view bringSubviewToFront:_spinner];
    [_spinner startAnimating];
}
- (void)shareMusic
{
    NSLog(@"Share Music");
    
    PFObject *songRecord = [PFObject objectWithClassName:kClassShare];
    [songRecord setObject:_songTitle  forKey:@"title"];
    [songRecord setObject:_songAlbum forKey:@"album"];
    [songRecord setObject:_songArtist forKey:@"artist"];
    [songRecord setObject:[[PFUser currentUser] username] forKey:@"user"];
    
    if (!_albumImage) {
        _albumImage = [UIImage imageNamed:@"default_album.png"];
    }
    NSData *imageData = UIImageJPEGRepresentation(_albumImage, 0.05f);
    /*ImageFile Name should be Error code indicating an invalid channel name. A channel name is either an empty string (the broadcast channel) or contains only a-zA-Z0-9_ characters and starts with a letter.*/
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy_MM_dd_h_mm"];
    NSString *lastUpdated = [formatter stringFromDate:[NSDate date]];
    NSString *imageFileName = [NSString stringWithFormat:@"%@_%@", [[PFUser currentUser] username],lastUpdated];
    PFFile *imageFile = [PFFile fileWithName:imageFileName data:imageData];
    [songRecord setObject:imageFile forKey:@"albumImage"];
    
    _shareMusicEntry = [[ShareMusicEntry alloc] initWithMusic:songRecord];
    [_shareMusicEntry shareMusic];
}
- (void)buyInItune
{
    NSString *alertString = [NSString stringWithFormat:@"You are about to switch to iTune for the song %@ in %@ by %@.", _songTitle, _songAlbum, _songArtist];
    _alertBeforeSwitchToITune = [[UIAlertView alloc] initWithTitle: @"Reminder" message:alertString delegate: self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
    [_alertBeforeSwitchToITune show];

}
- (void)addSimilarSongView
{
    moreLabel = [[UILabel alloc] initWithFrame:CGRectMake(buttonLeft, 0, width, buttonHeight)];
    moreLabel.backgroundColor = backgroundColor;
    moreLabel.text = @"More Like This:";
    moreLabel.textColor = textColor;
    [moreLabel setHidden:YES];
    [_addMoreLikeThisView addSubview:moreLabel];
    
    //UITableView
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, buttonHeight, width, _addMoreLikeThisView.frame.size.height-buttonHeight) style:UITableViewStylePlain];
//    UIView *backgroundView = [[BackgroundImageView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height)];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    tableView.dataSource = self;
    tableView.delegate = self;
    [tableView setHidden:YES];
    [_addMoreLikeThisView addSubview:tableView];
}

#pragma mark - iTune Music
- (void)listenInItune
{
    //    [_sampleMusicWebView removeFromSuperview];
    
//    if (_player) {
//        [_spinner stopAnimating];
//        //        [self.view addSubview:_sampleMusicITuneView];
//    }else{
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:@[_songTitle, _songAlbum, _songArtist] forKeys:@[@"title", @"album", @"artist"]];
    _samepleMusic = [[SampleMusic alloc] init];
    _samepleMusic.delegate = self;
    [_samepleMusic startSearch:dict];
    
//    }
}
- (void)finishFetchData:(NSDictionary *)songInfo
{
    //Update origin song info
    _songTitle = [songInfo objectForKey:@"title"];
    _songAlbum = [songInfo objectForKey:@"album"];
    _songArtist = [songInfo objectForKey:@"artist"];
    _collectionViewUrlLinkToITuneStore = [songInfo objectForKey:@"collectionViewUrl"];
    _songImageUrlString = [songInfo objectForKey:@"imageURL"];
    _songPreviewUrlString = [songInfo objectForKey:@"previewUrl"];
    _navigationBarTitleLabel.text = [NSString stringWithFormat:@"%@ - %@", _songTitle, _songArtist];
    
    
    //Music Player
    [self handleAudioPlayer:_songPreviewUrlString];    
}
- (void)finishFetchDataWithError:(NSError *)error
{
    _iTuneFetchErrorAlertView = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Sorry, can't find the sample song." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [_iTuneFetchErrorAlertView show];

//    [_spinner stopAnimating];
//    [self fetchFromEchoNest];
}
- (void)handleAudioPlayer:(NSString*)previewUrlString
{
    dispatch_async(kBgQueue, ^{
        NSURL* previewUrl = [NSURL URLWithString:previewUrlString];
        NSError* soundFileError = nil;
        NSData *songFile = [[NSData alloc] initWithContentsOfURL:previewUrl options:NSDataReadingMappedIfSafe error:&soundFileError ];
        if (soundFileError) {
            NSLog(@"Sound file error:%@", soundFileError.description);
            return;
        }
        
        [self performSelectorOnMainThread:@selector(fetchSongData:)
                               withObject:songFile waitUntilDone:YES];
    });
}
- (void)fetchSongData:(NSData*)songData
{
    NSError* audioError = nil;
    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithData:songData error:&audioError];
    if (audioError) {
        NSLog(@"Audio error:%@", audioError.description);
    }
    
    _player = newPlayer;
    _player.delegate = self;
    
    //Update Progress Slider
    //        self.progress.maximumValue = self.player.duration;
    self.progress.userInteractionEnabled = NO;
    
    _playedTime.text = @"0:00";
    int minLeft = self.player.duration/60;
    int secLeft = ceil(self.player.duration-minLeft*60);
    _leftTime.text = [NSString stringWithFormat:@"%d:%02d", minLeft, secLeft];
    
    [_player prepareToPlay];
    
    //User interface
    [_playButton setHidden:NO];
    [_shareButton setHidden:NO];
    [_playSourceButton setHidden:NO];
    [_iTuneButton setHidden:NO];
    [_addMoreLikeThisView setHidden:NO];
    
    //Spinner
    [_spinner stopAnimating];
    //Album image
    [self handleAlbumImage];
    //Recommended songs
    [self fetchFromEchoNest];
}
- (void)updateSongInfo
{
    //Update song info if previewDataUrl not saved
    if(_pfObject && ![_pfObject objectForKey:kClassSongDataURL]){
        NSString *objectId = [_pfObject objectId];

        PFObject *songObject = [PFObject objectWithoutDataWithClassName:kClassSong objectId:objectId];
        if(_songTitle) [songObject setObject:_songTitle forKey:kClassSongTitle];
        if(_songAlbum) [songObject setObject:_songAlbum forKey:kClassSongAlbum];
        if(_songArtist) [songObject setObject:_songArtist forKey:kClassSongArtist];
        if(_songImageUrlString) [songObject setObject:_songImageUrlString forKey:kClassSongAlbumURL];
        if(_songPreviewUrlString) [songObject setObject:_songPreviewUrlString forKey:kClassSongDataURL];
        [songObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Sample music update song successfully.");
            }else{
                NSLog(@"Sample music update song with error:%@",error.description);
            }
        }];
        
    }
}

#pragma mark - Global Player delegate
- (void)prepareCurrentSongSucceed
{
    //User interface
    [_playButton setHidden:NO];
    [_shareButton setHidden:NO];
    [_playSourceButton setHidden:NO];
    [_iTuneButton setHidden:NO];
    [_addMoreLikeThisView setHidden:NO];
    
    //Spinner
    [_spinner stopAnimating];
}
- (void)prepareCurrentSongFailed
{
    
}


#pragma mark - Youtube
- (void)listenInYoutube
{
    [_player stop];
    [_sampleMusicITuneView removeFromSuperview];
    
    if (_sampleMusicWebView) {
        [scrollView addSubview:self.sampleMusicWebView];
    }else{
        /*Youtube Embeded in Webview*/
        /*
         NSString *videoURL = @"https://www.youtube.com/watch?v=FyXtoTLLcDk&feature=youtube_gdata";
         UIWebView *videoView = [[UIWebView alloc] initWithFrame:_sampleMusicITuneView.frame];
         videoView.delegate = self;
         
         NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:videoURL]];
         [videoView loadRequest:request];
         [self.view addSubview:videoView];
         
         [_sampleMusicITuneView removeFromSuperview];
         [scrollView addSubview:videoView];
         */
        
        /*Youtbe Embeded Fully in View*/
        self.sampleMusicWebView = [[UIWebView alloc] initWithFrame:_sampleMusicITuneView.frame];
        self.sampleMusicWebView.backgroundColor = backgroundColor;
        self.sampleMusicWebView.scrollView.backgroundColor = backgroundColor;
        [scrollView addSubview:self.sampleMusicWebView];
        
        //Spinner
        _spinner = [[UIActivityIndicatorView alloc]
                    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _spinner.center = CGPointMake(_sampleMusicWebView.frame.size.width/2, _sampleMusicWebView.frame.size.height/2);
        _spinner.hidesWhenStopped = YES;
        [_sampleMusicWebView addSubview:_spinner];
        [_spinner startAnimating];
        
        //Search on Youtube
        NSString *searchInfo = [NSString stringWithFormat:@"%@+%@", _songTitle, _songArtist];
        NSString *searchTitle = [searchInfo stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSString *stringURL = [NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/videos?q=%@&alt=json&fields=entry(title,link,author)&max-results=1&prettyprint=true", searchTitle];
        NSURL *searchURL = [NSURL URLWithString:[stringURL stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        //Download Music
        dispatch_async(kBgQueue, ^{
            NSData* data = [NSData dataWithContentsOfURL:
                            searchURL];
            [self performSelectorOnMainThread:@selector(fetchedDataFromYoutube:)
                                   withObject:data waitUntilDone:YES];
        });
    }
}
- (void)fetchedDataFromYoutube:(NSData *)responseData
{
    if (!responseData) {
        [self fetchedDataWithError];
        return;
    }
    
    NSError* error = nil;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    NSDictionary* feed = [json objectForKey:@"feed"];
    if([feed count] == 0){
        [self fetchedDataWithError];
        return;
    }
    NSArray* entry = [feed objectForKey:@"entry"];
    if(!entry){
        [self fetchedDataWithError];
        return;
    }
//    NSLog(@"results: %@", entry);
    
    NSArray *link = [entry[0] objectForKey:@"link"];
    NSString *href = [link[0] objectForKey:@"href"];
    
    NSString *title = [[entry[0] objectForKey:@"title"] objectForKey:@"$t"];
    _infoLabel.text = title;
    
    [_spinner stopAnimating];
    
    [self playYoutube:href];
}
- (void)fetchedDataWithError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Sorry, can't listen in Youtube right now. Please try later." delegate:self.delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}
- (void)playYoutube:(NSString*)videoURL
{
    _youtubeVideoLink = videoURL;
    //URL Example
//    NSString *videoURL = @"http://www.youtube.com/embed/SB-DA6hyuj4";
//    videoURL = @"https://www.youtube.com/watch?v=FyXtoTLLcDk&feature=youtube_gdata";

    // if your url is not in embed format or it is dynamic then you have to convert it in embed format.
    videoURL = [videoURL stringByReplacingOccurrencesOfString:@"watch?v=" withString:@"embed/"];
    
    NSRange range = [videoURL rangeOfString:@"&"];
    @try {
        videoURL = [videoURL substringToIndex:range.location];
    }
    @catch (NSException *exception) {
        
    }
    NSRange rangeEmbed = [videoURL rangeOfString:@"embed/"];
    NSString *identifier = [videoURL substringFromIndex:rangeEmbed.location+rangeEmbed.length];
    
    /*
     * XCDYoutubeController play embed view, if fails, open in safari/youtube app
     */
    [_sampleMusicImageView removeFromSuperview];
    [self.view addSubview:_sampleMusicYoutubeView];
    _videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:identifier];
    [_videoPlayerViewController.moviePlayer prepareToPlay];
    [_videoPlayerViewController presentInView:_sampleMusicYoutubeView];
//    [_videoPlayerViewController.moviePlayer play];
//    self.videoPlayerViewController.moviePlayer.shouldAutoplay = self.shouldAutoplaySwitch.on;
    return;
    
    // here your link is converted in embed format.
//    NSString *embedHTML = [NSString stringWithFormat:@"<iframe id=\"ytplayer\" type=\"text/html\" width=\"640\" height=\"390\" src=\"%@\" frameborder=\"0\"/>", videoURL];
//    NSString* embedHTML = [NSString stringWithFormat:@"\
//                           <html><head>\
//                           <style type=\"text/css\">\
//                           iframe {position:absolute; top:50%%; margin-top:-130px;}\
//                           body {\
//                           background-color: transparent;\
//                           color: white;\
//                           }\
//                           </style>\
//                           </head><body style=\"margin:0\">\
//                           <iframe width=\"100%%\" height=\"240px\" src=\"%@?playsinline=1\" webkit-playsinline frameborder=\"0\"></iframe>\
//                           </body></html>",videoURL]; //fs=0&playsinline=1&modestbranding=1&rel=0&showinfo=0&autohide=2&html5=1
//    [self.sampleMusicWebView loadHTMLString:embedHTML baseURL:nil];
//    self.sampleMusicWebView.allowsInlineMediaPlayback = YES;
//    _sampleMusicWebView.delegate = self;
}
-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"Log Finish.");
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"WebView Load Fail:%@", error);
}

#pragma mark - Handle album image
/**
 * Get Image from PFObject image url
 * If fails, then get album image from iTune
 */
- (void)setAlbumImage:(UIImage *)albumImage
{
    _albumImage = albumImage;
    [_sampleMusicImageView setImage:albumImage];
    
    //Set background image for scroll view when setting album image
//    float imageHeight = albumImage.size.height;
//    float imageWidth = albumImage.size.width;
//    float portion = imageHeight/imageWidth;
    
    UIImageView *scrollBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(-width/2, barHeight, height, height)];
    [scrollBackgroundView setImage:albumImage];
    //Mask for ScrollBackgroundView
    UIView *scrollBackgroundViewMask = [[UIView alloc] initWithFrame:CGRectMake(width/2, 0, width, height)];
    [scrollBackgroundViewMask setBackgroundColor:[ColorConstant backgroundViewMaskColor]];
    [scrollBackgroundView addSubview:scrollBackgroundViewMask];
    
    [self.view addSubview:scrollBackgroundView];
    [self.view sendSubviewToBack:scrollBackgroundView];
}
/**
 * Get image from Echo Nest
 * Then try saved album url
 * Last try iTune image
 */
- (void)handleAlbumImage
{
    BOOL echoNestSource = NO;
    BOOL parseSource = NO;
    BOOL iTuneSource = NO;
    
    echoNestSource = [self getImageFromEchoNest];
    if (!echoNestSource) {
        parseSource = [self getImageFromParse];
        if (!parseSource) {
            iTuneSource = [self getImageFromITune];
            if (!iTuneSource) {
                [self getImageFromDefault];
            }
        }
    }

    //After getting the image url, update parse in class song
    [self updateSongInfo];
}
- (BOOL)getImageFromEchoNest
{
    NSString *title = [_songTitle stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *artist = [_songArtist stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *urlString = [NSString stringWithFormat:@"http://developer.echonest.com/api/v4/song/search?api_key=9PFPYZSZPU9X2PKES&format=json&results=1&artist=%@&title=%@&bucket=id:7digital-US&bucket=audio_summary&bucket=tracks", artist, title];
    NSURL *searchUrl = [NSURL URLWithString:urlString];
    NSData* responseData = [NSData dataWithContentsOfURL:
                    searchUrl];
    
    //Return if no data
    if(!responseData) return NO;
    
    NSError* error = nil;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    
    NSArray *songs;
    if(json && json[@"response"]){
        songs = json[@"response"][@"songs"];
    }
    
    if (songs && [songs count] > 0) {
        NSDictionary *song = songs[0];
//        NSString *title = song[@"title"];
//        NSString *artist = song[@"artist_name"];
        NSArray *tracks = song[@"tracks"];
        NSString *imageUrl;
        if(tracks && [tracks count] > 0){
            imageUrl = tracks[0][@"release_image"];
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            if (imageData) {
                _songImageUrlString = imageUrl; //Update song image url
                self.albumImage = [UIImage imageWithData:imageData];
                return YES;
            }
        }
    }
    
    return NO;
}
- (BOOL)getImageFromParse
{
    NSString *imageUrlFromParse = [_pfObject objectForKey:kClassSongAlbumURL];
    if (imageUrlFromParse) { //Parse image
        NSData *imageDataFromParse = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrlFromParse]];
        if (imageDataFromParse) {
            _songImageUrlString = imageUrlFromParse;
            self.albumImage = [UIImage imageWithData:imageDataFromParse];
            return YES;
        }
    }
    return NO;
}
- (BOOL)getImageFromITune
{
    NSData *imageDataFromITune;
    if (_songImageUrlString) {
        imageDataFromITune = [NSData dataWithContentsOfURL:[NSURL URLWithString:_songImageUrlString]];
    }
    if (imageDataFromITune) {
        self.albumImage = [UIImage imageWithData:imageDataFromITune];
        return YES;
    }
    return NO;
}
- (void)getImageFromDefault
{
    self.albumImage = [UIImage imageNamed:@"avibe_icon_120_120.png"];
}

#pragma mark - Audio play method
- (void)playOrPause {
    [_globalPlayer playPauseSong];
    
//    _playButton.selected = !_playButton.selected;
//    // if already playing, then pause
//    if (_player.playing) {
//        [_player pause];
//        [_progressTimer invalidate];
//    } else {
//        [_player play];
//        _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
//    }
}
- (void)updateProgress
{
    
    int minPlayed = self.player.currentTime/60;
    int secPlayed = round(self.player.currentTime-minPlayed*60);
    int minLeft = (self.player.duration-self.player.currentTime)/60;
    int secLeft = round((self.player.duration-self.player.currentTime)-minLeft*60);
    
    _playedTime.text = [NSString stringWithFormat:@"%d:%02d", minPlayed, secPlayed];
    _leftTime.text = [NSString stringWithFormat:@"%d:%02d", minLeft, secLeft];
    
    //    _progress.value = _player.currentTime;
    [_progress setProgress:_player.currentTime/_player.duration animated:YES];
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.progressTimer invalidate];
    _playButton.selected = !_playButton.selected;
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    [self.progressTimer invalidate];
    _playButton.selected = !_playButton.selected;
}

#pragma mark - Echo Nest More like this
- (void)fetchFromEchoNest
{
    NSString *artist = [_songArtist stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *urlString = [NSString stringWithFormat:@"http://developer.echonest.com/api/v4/artist/similar?api_key=9PFPYZSZPU9X2PKES&name=%@&format=json", artist];
    NSURL *searchUrl = [NSURL URLWithString:urlString];
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        searchUrl];
        [self performSelectorOnMainThread:@selector(fetchFromEchoNestSimilarArtist:)
                               withObject:data waitUntilDone:YES];
    });
}
- (void)fetchFromEchoNestSimilarArtist:(NSData*)responseData
{
    //Return if no data
    if(!responseData) return;
    
    NSError* error = nil;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    
//    NSLog(@"Result from Echo Nest For similar artist:%@",json);
    
    NSDictionary *artists;
    if(json && json[@"response"]){
        artists = json[@"response"][@"artists"];
    }
    
    
    for(NSDictionary *dict in artists){
        NSString *name = dict[@"name"];
        if(name) [_artistsArrray addObject:name];
    }
    
    if([_artistsArrray count] > 0){
        NSString *artist = [_artistsArrray lastObject];
        if(artist){
            [self callEchoNestForSongsOfArtist:artist];
            [_artistsArrray removeLastObject];
        }
    }
}
- (void)callEchoNestForSongsOfArtist:(NSString*)artist
{
    _artistFetchCount++;
    
    artist = [artist stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *urlString = [NSString stringWithFormat:@"http://developer.echonest.com/api/v4/song/search?api_key=9PFPYZSZPU9X2PKES&artist=%@&format=json&bucket=id:7digital-US&bucket=audio_summary&bucket=tracks&results=8", artist];
    NSURL *searchUrl = [NSURL URLWithString:urlString];
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        searchUrl];
        [self performSelectorOnMainThread:@selector(fetchFromEchoNestSongsOfArtist:)
                               withObject:data waitUntilDone:YES];
    });
}
- (void)fetchFromEchoNestSongsOfArtist:(NSData*)responseData
{
    //Return if no data
    if(!responseData){
        [self noDataFromEchoNest];
        return;
    }

    NSError* error = nil;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    
//    NSLog(@"Result from Echo Nest:%@",json);
    
    NSDictionary *songs;
    if(json && json[@"response"]){
        songs = json[@"response"][@"songs"];
    }
    
//    int songCount = 0;
    for(NSDictionary *song in songs){
        
        NSString *title = song[@"title"];
        NSString *artist = song[@"artist_name"];
        NSArray *tracks = song[@"tracks"];
        NSString *imageUrl;
        
        if(tracks && [tracks count] != 0){
            imageUrl = tracks[0][@"release_image"];
        }
        
        if(title && artist && imageUrl){
            NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[title,artist,imageUrl] forKeys:@[@"title",@"artist",@"imageUrl"]];
            [_songsForTableView addObject:dict];
                    }
        
    }
    
    if([_artistsArrray count] > 0 && _artistFetchCount < 4){
        NSString *artist = [_artistsArrray lastObject];
        if(artist){
            [self callEchoNestForSongsOfArtist:artist];
            [_artistsArrray removeLastObject];
        }
    }else{
        if([_songsForTableView count] > 0){
            [moreLabel setHidden:NO];
            [tableView setHidden:NO];
            
            [tableView reloadData];
        }else{
            [self noDataFromEchoNest];
        }
       
    }
}
- (void)noDataFromEchoNest
{
    [_sampleMusicImageView setFrame:CGRectMake(width/2-playerImageWidth/2, height/2-playerImageHeight/2, playerImageWidth, playerImageHeight)];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([_songsForTableView count] > 0)[_songsForTableView shuffle];
    return [_songsForTableView count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _tableViewRowHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    
    NSDictionary *dict = _songsForTableView[indexPath.row];
    assert(dict != nil);
    NSString *title = [dict objectForKey:@"title"];
    NSString *artist = [dict objectForKey:@"artist"];
    
    cell.backgroundColor = lightBackgroundColor;
    cell.textLabel.text = title;
    cell.detailTextLabel.text = artist;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = _songsForTableView[indexPath.row];
    
    self.sampleMusicViewController = [[SampleMusicViewController alloc] initWithDictionary:dict];
    self.sampleMusicViewController.delegate = self.delegate; //no matter how many levels go deep in sample music, always return to LiveFeed
    _navigationControllerForSampleMusic = [[MMNavigationController alloc] initWithRootViewController:self.sampleMusicViewController];
    [self.mm_drawerController setCenterViewController:_navigationControllerForSampleMusic withFullCloseAnimation:YES completion:nil];
}

#pragma mark - AlertView method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Switch Webview
    if([alertView isEqual:_alertBeforeSwitchToITune] && buttonIndex == 0){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_collectionViewUrlLinkToITuneStore]];
    }else if ([alertView isEqual:_iTuneFetchErrorAlertView] && buttonIndex == 0){
        [self leftDrawerButtonPress];
    }
}

#pragma mark - Button Handlers
-(void)setupNavigationBar{
    //Navigation Title
    _navigationBarTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    _navigationBarTitleLabel.text = @"Now Playing";
    _navigationBarTitleLabel.textColor = [UIColor colorWithRed:3.0/255.0
                                           green:49.0/255.0
                                            blue:107.0/255.0
                                           alpha:1.0];
    [_navigationBarTitleLabel setFont:[UIFont boldSystemFontOfSize:14]];
//    [_navigationBarTitleLabel sizeToFit];
    self.mm_drawerController.navigationItem.titleView = _navigationBarTitleLabel;
    
    UINavigationBar *navigationBar = self.mm_drawerController.navigationController.navigationBar;
    [navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    navigationBar.shadowImage = [UIImage new];
    navigationBar.translucent = YES;
    
    //    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    UIBarButtonItem *leftDrawerButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(leftDrawerButtonPress)];
    [self.mm_drawerController.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    [self.mm_drawerController.navigationItem setRightBarButtonItem:nil];
}
-(void)leftDrawerButtonPress{
    /**
     * Bad way to get around that ViewWillAppear not called
     */
    if([self.delegate isKindOfClass:[SampleMusicViewController class]]){
        [((SampleMusicViewController*)self.delegate) setupNavigationBar];
    }
    
    [self.mm_drawerController setCenterViewController:[[MMNavigationController alloc] initWithRootViewController:self.delegate] withCloseAnimation:YES completion:nil];
}

#pragma mark - XCDYoutubeController Notifications

- (void) moviePlayerPlaybackDidFinish:(NSNotification *)notification
{
	MPMovieFinishReason finishReason = [notification.userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
	NSError *error = notification.userInfo[XCDMoviePlayerPlaybackDidFinishErrorUserInfoKey];
	NSString *reason = @"Unknown";
	switch (finishReason)
	{
		case MPMovieFinishReasonPlaybackEnded:
			reason = @"Playback Ended";
			break;
		case MPMovieFinishReasonPlaybackError:
			reason = @"Playback Error";
			break;
		case MPMovieFinishReasonUserExited:
			reason = @"User Exited";
			break;
	}
	NSLog(@"Finish Reason: %@%@", reason, error ? [@"\n" stringByAppendingString:[error description]] : @"");
    
    //Handle error
    if (error) {
        [self.view addSubview:_sampleMusicImageView];
        //Safari or Youtube to open video url
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_youtubeVideoLink]];
    }
}

- (void) moviePlayerPlaybackStateDidChange:(NSNotification *)notification
{
	MPMoviePlayerController *moviePlayerController = notification.object;
	NSString *playbackState = @"Unknown";
	switch (moviePlayerController.playbackState)
	{
		case MPMoviePlaybackStateStopped:
			playbackState = @"Stopped";
			break;
		case MPMoviePlaybackStatePlaying:
			playbackState = @"Playing";
			break;
		case MPMoviePlaybackStatePaused:
			playbackState = @"Paused";
			break;
		case MPMoviePlaybackStateInterrupted:
			playbackState = @"Interrupted";
			break;
		case MPMoviePlaybackStateSeekingForward:
			playbackState = @"Seeking Forward";
			break;
		case MPMoviePlaybackStateSeekingBackward:
			playbackState = @"Seeking Backward";
			break;
	}
	NSLog(@"Playback State: %@", playbackState);
}

- (void) moviePlayerLoadStateDidChange:(NSNotification *)notification
{
	MPMoviePlayerController *moviePlayerController = notification.object;
	
	NSMutableString *loadState = [NSMutableString new];
	MPMovieLoadState state = moviePlayerController.loadState;
	if (state & MPMovieLoadStatePlayable)
		[loadState appendString:@" | Playable"];
	if (state & MPMovieLoadStatePlaythroughOK)
		[loadState appendString:@" | Playthrough OK"];
	if (state & MPMovieLoadStateStalled)
		[loadState appendString:@" | Stalled"];
	
	NSLog(@"Load State: %@", loadState.length > 0 ? [loadState substringFromIndex:3] : @"N/A");
}

- (void) videoPlayerViewControllerDidReceiveMetadata:(NSNotification *)notification
{
	NSLog(@"Metadata: %@", notification.userInfo);
}

@end
