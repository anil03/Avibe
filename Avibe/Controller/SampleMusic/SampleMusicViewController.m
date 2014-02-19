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
#import "SampleMusic_iTune.h"


//Rdio
#import "RdioConsumerCredentials.h"
#import <Rdio/Rdio.h>

@interface SampleMusicViewController () <UIWebViewDelegate, SampleMusicDelegate, AVAudioPlayerDelegate>
{
    UIColor *backgroundColor;
    UIColor *textColor;
    UIColor *textHighlightColor;
    
    float width;
    float height;
    float playerHeight;
    float currentHeight;
    float buttonLeft;
    
    float buttonHeight;
    
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
@property (nonatomic, strong) UIView *listenInView;
@property (nonatomic, strong) UIView *buyInView;
@property (nonatomic, strong) UIAlertView *alertBeforeSwitchToITune;

@property (nonatomic, strong) UIActivityIndicatorView *spinner;


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
@property (nonatomic, strong) NSString *collectionViewUrl;

@property (nonatomic, strong) ShareMusicEntry *shareMusicEntry;

//Rdio
@property (readonly) Rdio *rdio;
@property NSString *rdio_userkey;

//PFObject of current song
@property PFObject *pfObject;

@end

@implementation SampleMusicViewController
@synthesize moviePlayer;
@synthesize scrollView;

#pragma mark - Init method
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
        
        
    }
    
    return self;
}
- (id)initWithPFObject:(PFObject*)object
{
    self = [super init];
    if (self) {
        _pfObject = object;
        _songTitle = [_pfObject objectForKey:kClassSongTitle];
        _songTitle =  [NSString stringWithUTF8String:[_songTitle UTF8String]];
        _songAlbum = [_pfObject objectForKey:kClassSongAlbum];
        _songAlbum =  [NSString stringWithUTF8String:[_songAlbum UTF8String]];
        _songArtist = [_pfObject objectForKey:kClassSongArtist];
        _songArtist =  [NSString stringWithUTF8String:[_songArtist UTF8String]];
    }
    return self;
}

#pragma mark - Set up views
- (void)viewWillDisappear:(BOOL)animated
{
    [_player pause];
    _player = nil;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.view.userInteractionEnabled = NO;

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
    buttonHeight = 40;
    buttonLeft = 10;
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
//    _infoLabel.text = [NSString stringWithFormat:@"%@ by %@", _songAlbum, _songArtist];
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

    //iTune
    _sampleMusicITuneView = [[UIView alloc] initWithFrame:CGRectMake(0, currentHeight, width, playerHeight)];
    [self listenInItune];
    

    //Button - Listen
    currentHeight += playerHeight;
    [self addListenInView];
    
    
    //Button - Buy
    currentHeight += buttonHeight*1.5;
    [self addBuyInView];
    
    //Button - Share
    currentHeight += buttonHeight*1.5;
    [self addShareView];
    
    //Label - More Like this
//    currentHeight += buttonHeight;
//    [self addMoreLikeThisView];
    
    //Test Rdio Image
//    [self getRdioMusic];
}


#pragma mark - Rdio Music
- (void)getRdioMusic
{
    _rdio_userkey = @"s12187116";
    _rdio = [[Rdio alloc] initWithConsumerKey:RDIO_CONSUMER_KEY andSecret:RDIO_CONSUMER_SECRET delegate:nil];
//    [_rdio callAPIMethod:@"get"
//          withParameters:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:_rdio_userkey, @"lastSongPlayed,lastSongPlayTime", nil] forKeys:[NSArray arrayWithObjects:@"keys",@"extras", nil]]
//                delegate:[RDAPIRequestDelegate delegateToTarget:self       loadedAction:@selector(rdioRequest:didLoadData:)              failedAction:@selector(rdioRequest:didFailWithError:)]];
    [_rdio callAPIMethod:@"search"
          withParameters:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"rolling", @"track", nil] forKeys:[NSArray arrayWithObjects:@"query",@"types", nil]]
                delegate:[RDAPIRequestDelegate delegateToTarget:self       loadedAction:@selector(rdioRequest:didLoadData:)              failedAction:@selector(rdioRequest:didFailWithError:)]];
}

#pragma mark - Rdio delegate method
- (void)rdioRequest:(RDAPIRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"No Rdio Music Available with error: %@", error);
}

- (void)rdioRequest:(RDAPIRequest *)request didLoadData:(id)data
{
    NSDictionary *userdata = [data objectForKey:_rdio_userkey];
    NSDictionary *lastSongPlayedData = [userdata objectForKey:@"lastSongPlayed"];
    
    NSString *title = [lastSongPlayedData objectForKey:@"name"];
    NSString *artist = [lastSongPlayedData objectForKey:@"artist"];
    NSString *album = [lastSongPlayedData objectForKey:@"album"];
    //    NSLog(@"Rdio LastSongPlayed: %@, %@, %@", title, artist, album);
    
    PFObject *songRecord = [PFObject objectWithClassName:@"Song"];
    [songRecord setObject:title  forKey:@"title"];
    [songRecord setObject:album forKey:@"album"];
    [songRecord setObject:artist forKey:@"artist"];
    [songRecord setObject:[[PFUser currentUser] username] forKey:@"user"];
    
//    FilterAndSaveObjects *filter = [[FilterAndSaveObjects alloc] init];
//    [filter filterDuplicatedDataToSaveInParse:[NSMutableArray arrayWithObject:songRecord] andSource:@"Rdio" andFetchObjects:fetechObjects];
}


#pragma mark - Add SubView
- (void)addShareView
{
    float buttonWidth = buttonHeight;
    float leftOffset = 100.0f;

    
    UIView *shareView = [[UIView alloc] initWithFrame:CGRectMake(0, currentHeight, width, buttonHeight)];
    UILabel *shareLabel = [[UILabel alloc] initWithFrame:CGRectMake(buttonLeft, 0, leftOffset, buttonHeight)];
    [shareLabel setText:@"Share: "];
    [shareLabel setTextColor:textColor];
    shareLabel.textAlignment = NSTextAlignmentLeft;
    shareLabel.backgroundColor = [UIColor blackColor];
//    [shareButton addTarget:self action:@selector(shareMusic) forControlEvents:UIControlEventTouchUpInside];
    [shareView addSubview:shareLabel];
    [scrollView addSubview:shareView];
    
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(leftOffset, 0, buttonWidth, buttonHeight)];
    [shareButton setBackgroundImage:[UIImage imageNamed:@"avibe_icon_120_120"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareMusic) forControlEvents:UIControlEventTouchUpInside];
    [shareView addSubview:shareButton];

}
- (void)addBuyInView
{
    _buyInView = [[UIView alloc] initWithFrame:CGRectMake(0, currentHeight, width, buttonHeight)];
    [scrollView addSubview:_buyInView];
    
    float leftOffset = buttonLeft;
    float labelWidth = 80;
    float buttonWidth = buttonHeight;
    
    UILabel *buyLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftOffset, 0, labelWidth, buttonHeight)];
    [buyLabel setText:@"Buy in: "];
    [buyLabel setTextColor:textColor];
    buyLabel.backgroundColor = [UIColor blackColor];
    [_buyInView addSubview:buyLabel];
    
    leftOffset = width/2 - 110/2;
    UIButton *iTuneButton = [[UIButton alloc] initWithFrame:CGRectMake(leftOffset, 0, 110, 40)];
    [iTuneButton setBackgroundImage:[UIImage imageNamed:@"Download_on_iTunes_Badge_US-UK_110x40_1004"] forState:UIControlStateNormal];
    [iTuneButton addTarget:self action:@selector(buyInItune) forControlEvents:UIControlEventTouchUpInside];
    [_buyInView addSubview:iTuneButton];
}
- (void)buyInItune
{
    NSString *alertString = [NSString stringWithFormat:@"You are about to switch to iTune for the song %@ in %@ by %@.", _songTitle, _songAlbum, _songArtist];
    _alertBeforeSwitchToITune = [[UIAlertView alloc] initWithTitle: @"Reminder" message:alertString delegate: self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
    [_alertBeforeSwitchToITune show];

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Switch Webview
    if([alertView isEqual:_alertBeforeSwitchToITune] && buttonIndex == 0){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_collectionViewUrl]];
    }
}
- (void)addListenInView
{
    _listenInView = [[UIView alloc] initWithFrame:CGRectMake(0, currentHeight, width, buttonHeight)];
    [scrollView addSubview:_listenInView];
    
    float buttonWidth = buttonHeight;
    float labelWidth = 80;
    float leftOffset = buttonLeft;
    UILabel *listenButton = [[UILabel alloc] initWithFrame:CGRectMake(leftOffset, 0, labelWidth, buttonHeight)];
    [listenButton setText:@"Listen in: "];
    [listenButton setTextColor:textColor];
//    [listenButton setTitle:@"Listen in " forState:UIControlStateNormal];
//    [listenButton setTitleColor:textColor forState:UIControlStateNormal];
//    [listenButton setTitleColor:textHighlightColor forState:UIControlStateHighlighted];
//    listenButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    listenButton.backgroundColor = [UIColor blackColor];
    [_listenInView addSubview:listenButton];
    
    leftOffset += labelWidth;
    UIButton *youtubeButton = [[UIButton alloc] initWithFrame:CGRectMake(leftOffset, 0, buttonWidth, buttonHeight)];
    [youtubeButton setBackgroundImage:[UIImage imageNamed:@"youtube-48.png"] forState:UIControlStateNormal];
    [youtubeButton setBackgroundImage:[UIImage imageNamed:@"youtube-48-highlight.png"] forState:UIControlStateHighlighted];
    [youtubeButton addTarget:self action:@selector(listenInYoutube) forControlEvents:UIControlEventTouchUpInside];
    [_listenInView addSubview:youtubeButton];
    
    leftOffset += buttonWidth*4/3;
    UIButton *iTuneButton = [[UIButton alloc] initWithFrame:CGRectMake(leftOffset, 0, buttonWidth, buttonHeight)];
    [iTuneButton setBackgroundImage:[UIImage imageNamed:@"iTunes-10-icon.png"] forState:UIControlStateNormal];
    [iTuneButton addTarget:self action:@selector(listenInItune) forControlEvents:UIControlEventTouchUpInside];
    [_listenInView addSubview:iTuneButton];
    
}
- (void)addMoreLikeThisView
{
    UILabel *moreLabel = [[UILabel alloc] initWithFrame:CGRectMake(buttonLeft, currentHeight, width, buttonHeight)];
    moreLabel.backgroundColor = backgroundColor;
    moreLabel.text = @"More Like This:";
    moreLabel.textColor = textColor;
    [scrollView addSubview:moreLabel];
}

#pragma mark - ListenIn Button Method

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
    NSLog(@"results: %@", entry);
    
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
    
    // here your link is converted in embed format.
//    NSString *embedHTML = [NSString stringWithFormat:@"<iframe id=\"ytplayer\" type=\"text/html\" width=\"640\" height=\"390\" src=\"%@\" frameborder=\"0\"/>", videoURL];
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
    _sampleMusicWebView.delegate = self;
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

#pragma mark - iTune Music
- (void)listenInItune
{
    [_sampleMusicWebView removeFromSuperview];

    if (_player) {
        [_spinner stopAnimating];
        [scrollView addSubview:_sampleMusicITuneView];
    }else{
        [self setupITuneMusicView];
        NSDictionary *dict = [[NSDictionary alloc] initWithObjects:@[_songTitle, _songAlbum, _songArtist] forKeys:@[@"title", @"album", @"artist"]];
        _samepleMusic = [[SampleMusic_iTune alloc] init];
        _samepleMusic.delegate = self;
        [_samepleMusic startSearch:dict];
    }
}
- (void)setupITuneMusicView
{
    
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
    [_playButton removeFromSuperview];
    _playButton = [[UIButton alloc] initWithFrame:CGRectMake(width/2-playerButtonWidth/2, playerImageHeight+playerProgressHeight, playerButtonWidth, playerButtonHeight)];
    [_playButton addTarget:self action:@selector(playOrPause) forControlEvents:UIControlEventTouchUpInside];
    [_playButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_playButton setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [_playButton setTitle:@"▶︎" forState:UIControlStateNormal];
    [_playButton setTitle:@"◼︎" forState:UIControlStateSelected];
    [_sampleMusicITuneView addSubview:_playButton];
    
    //Spinner
    _spinner = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.center = CGPointMake(_sampleMusicITuneView.frame.size.width/2, _sampleMusicITuneView.frame.size.height/2);
    _spinner.hidesWhenStopped = YES;
    [_sampleMusicITuneView addSubview:_spinner];
    [_spinner startAnimating];
}
- (void)finishFetchData:(NSData *)song andInfo:(NSDictionary *)songInfo
{
    //Enable User interaction
//    self.view.userInteractionEnabled = YES;
    [_spinner stopAnimating];
    
    //Update origin song
    _songTitle = [songInfo objectForKey:@"title"];
    _songAlbum = [songInfo objectForKey:@"album"];
    _songArtist = [songInfo objectForKey:@"artist"];
    _collectionViewUrl = [songInfo objectForKey:@"collectionViewUrl"];
    
    //Set Song Title
    _titleLabel.text = [songInfo objectForKey:@"title"];
    _infoLabel.text = [NSString stringWithFormat:@"%@ by %@", [songInfo objectForKey:@"album"], [songInfo objectForKey:@"artist"]];
    
    //Album image
    [self handleAlbumImage:[songInfo objectForKey:@"imageURL"]];
    
    
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
//    self.view.userInteractionEnabled = YES;
    [_spinner stopAnimating];

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
    int secPlayed = round(self.player.currentTime-minPlayed*60);
    int minLeft = (self.player.duration-self.player.currentTime)/60;
    int secLeft = round((self.player.duration-self.player.currentTime)-minLeft*60);
    
    _playedTime.text = [NSString stringWithFormat:@"%d:%02d", minPlayed, secPlayed];
    _leftTime.text = [NSString stringWithFormat:@"%d:%02d", minLeft, secLeft];
    
//    _progress.value = _player.currentTime;
    [_progress setProgress:_player.currentTime/_player.duration animated:YES];
}

#pragma mark - Handle album image
/**
 * Get Image from PFObject image url
 * If fails, then get album image from iTune
 */
- (void)handleAlbumImage:(NSString*)imageUrlFromITune
{
    //Parse image
    NSString *imageUrlFromParse = [_pfObject objectForKey:kClassSongAlbumURL];
    if (imageUrlFromParse) {
        NSData *imageDataFromParse = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrlFromParse]];
        if (imageDataFromParse) {
            _albumImage = [UIImage imageWithData:imageDataFromParse];
            return;
        }
    }
    
    //iTune image
    if(imageUrlFromITune){
        NSData *imageDataFromITune = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrlFromITune]];
        _albumImage = [UIImage imageWithData:imageDataFromITune];
    }
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

#pragma mark - Button Method
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
    UIBarButtonItem *leftDrawerButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(leftDrawerButtonPress)];
    [self.mm_drawerController.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    [self.mm_drawerController.navigationItem setRightBarButtonItem:nil];
}
-(void)leftDrawerButtonPress{
    [self.mm_drawerController setCenterViewController:self.delegate withCloseAnimation:YES completion:nil];
}

@end
