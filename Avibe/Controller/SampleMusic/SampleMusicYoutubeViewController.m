//
//  SampleMusicYoutubeViewController.m
//  Avibe
//
//  Created by Yuhua Mai on 1/14/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "SampleMusicYoutubeViewController.h"

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import "UIViewController+MMDrawerController.h"
#import "ShareMusicEntry.h"
#import "Setting.h"
#import "SampleMusic_iTune.h"

@interface SampleMusicYoutubeViewController () <UIWebViewDelegate, SampleMusicDelegate, AVAudioPlayerDelegate>
{
    UIColor *backgroundColor;
    UIColor *textColor;
    UIColor *textHighlightColor;
    
    float width;
    float height;
    float playerHeight;
    float currentHeight;
    
    //iTune View
    float playerImageWidth;
    float playerImageHeight;
    float playerLabelWidth;
    float playerLabelHeight;
    float playerProgressWidth;
    float playerProgressHeight;
    float playerButtonWidth;
    float playerButtonHeight;
}

//View
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *infoLabel;

//Youtube
@property (strong, nonatomic) MPMoviePlayerController* moviePlayer;
@property (strong, nonatomic) UIWebView *sampleMusicWebView;

//iTune
@property (strong, nonatomic) SampleMusic_iTune *samepleMusic;
@property (strong, nonatomic) UIView *sampleMusicITuneView;
@property (strong, nonatomic) UIImageView *sampleMusicImageView;
@property (strong, nonatomic) UILabel *playedTime;
@property (strong, nonatomic) UILabel *leftTime;
//@property (strong, nonatomic) UISlider *progress;
@property (strong, nonatomic) UIProgressView *progress;
@property (strong, nonatomic) NSTimer *progressTimer;
@property (strong, nonatomic) UIButton *playButton;
@property (nonatomic, retain) AVAudioPlayer *player;
@property (nonatomic, strong) UIImage *albumImage;

//Song Info
@property (nonatomic, strong) NSString *songTitle;
@property (nonatomic, strong) NSString *songAlbum;
@property (nonatomic, strong) NSString *songArtist;

@property (nonatomic, strong) ShareMusicEntry *shareMusicEntry;

@end

@implementation SampleMusicYoutubeViewController
@synthesize moviePlayer;
@synthesize scrollView;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    
    if (self) {
        _songTitle = [dictionary objectForKey:@"title"];
        _songTitle =  [NSString stringWithUTF8String:[_songTitle UTF8String]];
        _songAlbum = [dictionary objectForKey:@"album"];
        _songAlbum =  [NSString stringWithUTF8String:[_songAlbum UTF8String]];
        _songArtist = [dictionary objectForKey:@"artist"];
        _songArtist =  [NSString stringWithUTF8String:[_songArtist UTF8String]];
        
        //Youtube
        // ...
        
        //iTune
        NSDictionary *dict = [[NSDictionary alloc] initWithObjects:@[_songTitle, _songAlbum, _songArtist] forKeys:@[@"title", @"album", @"artist"]];
        _samepleMusic = [[SampleMusic_iTune alloc] init];
        _samepleMusic.delegate = self;
        [_samepleMusic startSearch:dict];
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.userInteractionEnabled = NO;

    [self setupNavigationBar];
    
    backgroundColor = [UIColor blackColor];
    textColor = [UIColor whiteColor];
    textHighlightColor = [UIColor grayColor];
    [self.view setBackgroundColor:backgroundColor];
    
    //Size Specification
    width = [[UIScreen mainScreen] bounds].size.width;
    height = [[UIScreen mainScreen] bounds].size.height;
    float barHeight = 10;
    float titleLabelHeight = 30;
    float infoLabelHight = 30;
    playerHeight = 200;
    playerImageWidth = width/2;
    playerImageHeight = playerHeight*2/3;
    playerProgressWidth = width/2;
    playerProgressHeight = (playerHeight-playerImageHeight)/2;
    playerLabelWidth = 30.0f;
    playerLabelHeight = playerProgressHeight;
    playerButtonWidth = 30.0f;
    playerButtonHeight = playerProgressHeight;
    float buttonHeight = 40;
    float buttonLeft = 10;
    currentHeight = 0;
    
    //ScrollView
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [scrollView setContentSize:CGSizeMake(width, height*2)];
    self.view = scrollView;
    
    //Song Info
    currentHeight = barHeight;
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, currentHeight, width, titleLabelHeight)];
    _titleLabel.backgroundColor = backgroundColor;
    _titleLabel.text = _songTitle;
    _titleLabel.textColor = textColor;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    [scrollView addSubview:_titleLabel];
    
    currentHeight += titleLabelHeight;
    _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, currentHeight, width, infoLabelHight)];
    _infoLabel.backgroundColor = backgroundColor;
    _infoLabel.text = [NSString stringWithFormat:@"%@ by %@", _songAlbum, _songArtist];
    _infoLabel.textColor = textColor;
    _infoLabel.textAlignment = NSTextAlignmentCenter;
    _infoLabel.adjustsFontSizeToFitWidth = YES;
    [scrollView addSubview:_infoLabel];
    
    //PlayerView
    /**
     Could be Youtube, iTune, ...
     */
    currentHeight += infoLabelHight;
    //Youtube
    /*
    self.sampleMusicWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, currentHeight, width, playerHeight)];
    self.sampleMusicWebView.backgroundColor = backgroundColor;
    self.sampleMusicWebView.scrollView.backgroundColor = backgroundColor;
    [scrollView addSubview:self.sampleMusicWebView];
    [self playYoutube];*/
    //iTune
    
    [self setupITuneMusicView];

    //Button - Share
    currentHeight += playerHeight;
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonLeft, currentHeight, width, buttonHeight)];
    [shareButton setTitle:@"Share" forState:UIControlStateNormal];
    [shareButton setTitleColor:textColor forState:UIControlStateNormal];
    [shareButton setTitleColor:textHighlightColor forState:UIControlStateHighlighted];
    shareButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    shareButton.backgroundColor = [UIColor blackColor];
    [shareButton addTarget:self action:@selector(shareMusic) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:shareButton];
    
    //Button - Buy
    currentHeight += buttonHeight;
    UIButton *buyButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonLeft, currentHeight, width, buttonHeight)];
    [buyButton setTitle:@"Buy in " forState:UIControlStateNormal];
    [buyButton setTitleColor:textColor forState:UIControlStateNormal];
    [buyButton setTitleColor:textHighlightColor forState:UIControlStateHighlighted];
    buyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    buyButton.backgroundColor = [UIColor blackColor];
    [scrollView addSubview:buyButton];
    
    //Button - Listen
    currentHeight += buttonHeight;
    UIButton *listenButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonLeft, currentHeight, width, buttonHeight)];
    [listenButton setTitle:@"Listen in " forState:UIControlStateNormal];
    [listenButton setTitleColor:textColor forState:UIControlStateNormal];
    [listenButton setTitleColor:textHighlightColor forState:UIControlStateHighlighted];
    listenButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    listenButton.backgroundColor = [UIColor blackColor];
    [scrollView addSubview:listenButton];
    
    //Label - More Like this
    currentHeight += buttonHeight;
    UILabel *moreLabel = [[UILabel alloc] initWithFrame:CGRectMake(buttonLeft, currentHeight, width, buttonHeight)];
    moreLabel.backgroundColor = backgroundColor;
    moreLabel.text = @"More Like This:";
    moreLabel.textColor = textColor;
    [scrollView addSubview:moreLabel];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_player pause];
    _player = nil;
}

#pragma mark - Youtube
- (void)playYoutube
{
    NSString *videoURL = @"http://www.youtube.com/embed/SB-DA6hyuj4";
    
    // if your url is not in embed format or it is dynamic then you have to convert it in embed format.
//    videoURL = [videoURL stringByReplacingOccurrencesOfString:@"watch?v=" withString:@"embed/"];
//    
//    NSRange range = [videoURLString rangeOfString:@"&"];
//    @try {
//        videoURLString = [videoURLString substringToIndex:range.location];
//    }
//    @catch (NSException *exception) {
//        
//    }
    
    // here your link is converted in embed format.
    
    NSString* embedHTML = [NSString stringWithFormat:@"\
                           <html><head>\
                           <style type=\"text/css\">\
                           iframe {position:absolute; top:50%%; margin-top:-130px;}\
                           body {\
                           background-color: transparent;\
                           color: white;\
                           }\
                           </style>\
                           </head><body style=\"margin:0\">\
                           <iframe width=\"100%%\" height=\"240px\" src=\"%@\" frameborder=\"0\" allowfullscreen></iframe>\
                           </body></html>",videoURL];

    [self.sampleMusicWebView loadHTMLString:embedHTML baseURL:nil];
}

- (void)embedYouTube:(NSString *)urlString frame:(CGRect)frame {
//    NSString *embedHTML = @"\
    <html><head>\
    <style type=\"text/css\">\
    body {\
    background-color: transparent;\
    color: white;\
    }\
    </style>\
    </head><body style=\"margin:0\">\
    <embed id=\"yt\" src=\"%@\" type=\"application/x-shockwave-flash\" \
    width=\"%0.0f\" height=\"%0.0f\"></embed>\
    </body></html>";
//    NSString *html = [NSString stringWithFormat:embedHTML, urlString, frame.size.width, frame.size.height];
    UIWebView *videoView = [[UIWebView alloc] initWithFrame:frame];
    videoView.delegate = self;
    
//    [videoView loadHTMLString:urlString baseURL:nil];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [videoView loadRequest:request];
    [self.view addSubview:videoView];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"Log Finish.");
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"WebView Load Fail:%@", error);
}

#pragma mark - iTune Music
- (void)setupITuneMusicView
{
    _sampleMusicITuneView = [[UIView alloc] initWithFrame:CGRectMake(0, currentHeight, width, playerHeight)];
    [scrollView addSubview:_sampleMusicITuneView];

    //Progress View
    _progress = [[UIProgressView alloc] initWithFrame:CGRectMake(width/2-playerProgressWidth/2, playerImageHeight+playerProgressHeight/2, playerProgressWidth, playerProgressHeight)];
    [_progress setProgressViewStyle:UIProgressViewStyleBar];
//    _progress = [[UISlider alloc] initWithFrame:CGRectMake(width/2-playerProgressWidth/2, playerImageHeight, playerProgressWidth, playerProgressHeight)];
    [_sampleMusicITuneView addSubview:_progress];
    _playedTime = [[UILabel alloc] initWithFrame:CGRectMake(width/2-playerProgressWidth/2-playerLabelWidth, playerImageHeight, playerLabelWidth, playerLabelHeight)];
    _playedTime.textColor = textColor;
    _playedTime.backgroundColor = backgroundColor;
    _playedTime.adjustsFontSizeToFitWidth = YES;
    [_sampleMusicITuneView addSubview:_playedTime];
    _leftTime = [[UILabel alloc] initWithFrame:CGRectMake(width/2+playerProgressWidth/2, playerImageHeight, playerLabelWidth, playerLabelHeight)];
    _leftTime.textColor = textColor;
    _leftTime.backgroundColor = backgroundColor;
    _leftTime.adjustsFontSizeToFitWidth = YES;
    [_sampleMusicITuneView addSubview:_leftTime];
    
    //Button View
    _playButton = [[UIButton alloc] initWithFrame:CGRectMake(width/2-playerButtonWidth/2, playerImageHeight+playerProgressHeight, playerButtonWidth, playerButtonHeight)];
    [_playButton addTarget:self action:@selector(playOrPause) forControlEvents:UIControlEventTouchUpInside];
    [_playButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_playButton setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [_playButton setTitle:@"▶︎" forState:UIControlStateNormal];
    [_playButton setTitle:@"◼︎" forState:UIControlStateSelected];
    [_sampleMusicITuneView addSubview:_playButton];
}

- (void)finishFetchData:(NSData *)song andInfo:(NSDictionary *)songInfo
{
    //Enable User interaction
    self.view.userInteractionEnabled = YES;
    
    //Update origin song
    _songTitle = [songInfo objectForKey:@"title"];
    _songAlbum = [songInfo objectForKey:@"album"];
    _songArtist = [songInfo objectForKey:@"artist"];
    
    //Set Song Title
    _titleLabel.text = [songInfo objectForKey:@"title"];
    _infoLabel.text = [NSString stringWithFormat:@"%@ by %@", [songInfo objectForKey:@"album"], [songInfo objectForKey:@"artist"]];
    
    //Set Album Image
    NSURL *imageUrl = [NSURL URLWithString:[songInfo objectForKey:@"imageURL"]];
    NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
    UIImage *image = [UIImage imageWithData:imageData];
    if (image) {
        _albumImage = image;
    }
    
    _sampleMusicImageView = [[UIImageView alloc] initWithFrame:CGRectMake(width/2-playerImageWidth/2, 0, playerImageWidth, playerImageHeight)];
    [_sampleMusicImageView setImage:_albumImage];
    [_sampleMusicITuneView addSubview:_sampleMusicImageView];
    
    //Player
    NSError* __autoreleasing audioError = nil;
    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithData:song error:&audioError];
    
    if (!audioError) {
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
    }else{
        NSLog(@"Audio Error!");
    }

}
- (void)finishFetchDataWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Sorry, can't find the sample song." delegate:self.delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    //Enable User interaction
    self.view.userInteractionEnabled = YES;
}

- (void)playOrPause {
    _playButton.selected = !_playButton.selected;
    // if already playing, then pause
    if (_player.playing) {
        [_player pause];
        [_progressTimer invalidate];
    } else {
        [_player play];
        _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    }
}

- (void)updateProgress
{
    
    int minPlayed = self.player.currentTime/60;
    int secPlayed = ceil(self.player.currentTime-minPlayed*60);
    int minLeft = (self.player.duration-self.player.currentTime)/60;
    int secLeft = ceil((self.player.duration-self.player.currentTime)-minLeft*60);
    
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
    
    //Back to Previous View
//    [self leftDrawerButtonPress:nil];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    [self.progressTimer invalidate];
    _playButton.selected = !_playButton.selected;
}

#pragma mark - Button Method
- (void)shareMusic
{
    NSLog(@"Share Music");
    
    PFObject *songRecord = [PFObject objectWithClassName:@"Share"];
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
    [formatter setDateFormat:@"MMM_d_h_mm_a"];
    NSString *lastUpdated = [formatter stringFromDate:[NSDate date]];
    NSString *imageFileName = [NSString stringWithFormat:@"%@_%@", [[PFUser currentUser] username],lastUpdated];
    PFFile *imageFile = [PFFile fileWithName:imageFileName data:imageData];
    [songRecord setObject:imageFile forKey:@"albumImage"];
    
    _shareMusicEntry = [[ShareMusicEntry alloc] initWithMusic:songRecord];
    [_shareMusicEntry shareMusic];
}

#pragma mark - Movie
-(void) playMovieAtURL: (NSURL*) theURL {
    
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL: theURL];
    
    [moviePlayer.view setFrame:self.view.bounds];
    
    //    theMovie.scalingMode = MPMovieScalingModeAspectFill;
    moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    //    theMovie.fullscreen=NO;
    //    theMovie.allowsAirPlay=YES;
    //    theMovie.shouldAutoplay=NO;
    //    theMovie.controlStyle=MPMovieControlStyleEmbedded;
    
    // Register for the playback finished notification
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(myMovieFinishedCallback:)
     name: MPMoviePlayerPlaybackDidFinishNotification
     object: moviePlayer];
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(myMovieFinishedCallback:)
     name: MPMoviePlayerDidExitFullscreenNotification
     object: moviePlayer];
    
    [moviePlayer prepareToPlay];
    
    // Movie playback is asynchronous, so this method returns immediately.
    //    [theMovie play];
}

// When the movie is done, release the controller.
-(void) myMovieFinishedCallback: (NSNotification*) aNotification
{
    [moviePlayer.view removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name: MPMoviePlayerPlaybackDidFinishNotification
     object: moviePlayer];
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name: MPMoviePlayerDidExitFullscreenNotification
     object: moviePlayer];
}

#pragma mark - Button Handlers
-(void)setupNavigationBar{
    //Navigation Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = @"Now Playing";
    titleLabel.textColor = [UIColor colorWithRed:3.0/255.0
                                           green:49.0/255.0
                                            blue:107.0/255.0
                                           alpha:1.0];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [titleLabel sizeToFit];
    self.mm_drawerController.navigationItem.titleView = titleLabel;
    [self.mm_drawerController.navigationController.navigationBar setBarTintColor: [[Setting sharedSetting] barTintColor]];
    
    //    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    UIBarButtonItem *leftDrawerButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(leftDrawerButtonPress:)];
    [self.mm_drawerController.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    [self.mm_drawerController.navigationItem setRightBarButtonItem:nil];
}

-(void)leftDrawerButtonPress:(id)sender{
    //    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    [self.mm_drawerController setCenterViewController:self.delegate withCloseAnimation:YES completion:nil];
    
    //    [self.mm_drawerController setCenterViewController:self.centerViewController];
    //    [self.mm_drawerController.navigationController popViewControllerAnimated:YES];
    
}

@end
