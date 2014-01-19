//
//  SampleMusicYoutubeViewController.m
//  Avibe
//
//  Created by Yuhua Mai on 1/14/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "SampleMusicYoutubeViewController.h"

#import <MediaPlayer/MediaPlayer.h>

#import "UIViewController+MMDrawerController.h"
#import "ShareMusicEntry.h"
#import "Setting.h"

@interface SampleMusicYoutubeViewController () <UIWebViewDelegate>

@property (strong, nonatomic) MPMoviePlayerController* moviePlayer;
@property (strong, nonatomic) UIWebView *webView;

@property (nonatomic, strong) NSString *songTitle;
@property (nonatomic, strong) NSString *songAlbum;
@property (nonatomic, strong) NSString *songArtist;

@property (nonatomic, strong) ShareMusicEntry *shareMusicEntry;

@end

@implementation SampleMusicYoutubeViewController
@synthesize moviePlayer;

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    
    if (self) {
        _songTitle = [dictionary objectForKey:@"title"];
        _songAlbum = [dictionary objectForKey:@"album"];
        _songArtist = [dictionary objectForKey:@"artist"];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupNavigationBar];
    
    UIColor *backgroundColor = [UIColor blackColor];
    UIColor *textColor = [UIColor whiteColor];
    UIColor *textHighlightColor = [UIColor grayColor];
    [self.view setBackgroundColor:backgroundColor];
    
    //Size Specification
    float width = [[UIScreen mainScreen] bounds].size.width;
    float height = [[UIScreen mainScreen] bounds].size.height;
    float barHeight = 10;
    float titleLabelHeight = 30;
    float infoLabelHight = 30;
    float playerHeight = 200;
    float buttonHeight = 40;
    float buttonLeft = 10;
    float currentHeight = 0;
    
    //ScrollView
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [scrollView setContentSize:CGSizeMake(width, height*2)];
    self.view = scrollView;
    
    //Song Info
    currentHeight = barHeight;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, currentHeight, width, titleLabelHeight)];
    titleLabel.backgroundColor = backgroundColor;
    titleLabel.text = _songTitle;
    titleLabel.textColor = textColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    [scrollView addSubview:titleLabel];
    
    currentHeight += titleLabelHeight;
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, currentHeight, width, infoLabelHight)];
    infoLabel.backgroundColor = backgroundColor;
    infoLabel.text = [NSString stringWithFormat:@"%@ by %@", _songAlbum, _songArtist];
    infoLabel.textColor = textColor;
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.adjustsFontSizeToFitWidth = YES;
    [scrollView addSubview:infoLabel];
    
    //PlayerView
    currentHeight += infoLabelHight;
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, currentHeight, width, playerHeight)];
    self.webView.backgroundColor = backgroundColor;
    self.webView.scrollView.backgroundColor = backgroundColor;
    [scrollView addSubview:self.webView];
    [self playYoutube];
    
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

    [self.webView loadHTMLString:embedHTML baseURL:nil];
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

#pragma mark - Button Method
- (void)shareMusic
{
    NSLog(@"Share Music");
    
    PFObject *songRecord = [PFObject objectWithClassName:@"Share"];
    [songRecord setObject:_songTitle  forKey:@"title"];
    [songRecord setObject:_songAlbum forKey:@"album"];
    [songRecord setObject:_songArtist forKey:@"artist"];
    [songRecord setObject:[[PFUser currentUser] username] forKey:@"user"];
    
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
