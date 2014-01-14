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

@interface SampleMusicYoutubeViewController () <UIWebViewDelegate>

@property (strong, nonatomic) MPMoviePlayerController* moviePlayer;
@property (strong, nonatomic) UIWebView *webView;

@end

@implementation SampleMusicYoutubeViewController
@synthesize moviePlayer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupLeftMenuButton];
    [self.view setBackgroundColor:[UIColor grayColor]];
    
    //ScrollView
    float width = [[UIScreen mainScreen] bounds].size.width;
    float height = [[UIScreen mainScreen] bounds].size.height;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 30, 20)];
    testLabel.text = @"test";
    [scrollView addSubview:testLabel];
    [scrollView setContentSize:CGSizeMake(width, height*2)];
    [self.view addSubview:scrollView];
    
    [self playYoutube];
//    [self embedYouTube:@"https://www.youtube.com/v/SB-DA6hyuj4?version=3&f=videos&app=youtube_gdata" frame:CGRectMake(10, 100, 300, 450)];
    
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
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 300, 460)];
    [self.view addSubview:self.webView];
    [self.webView loadHTMLString:embedHTML baseURL:nil];
}

- (void)embedYouTube:(NSString *)urlString frame:(CGRect)frame {
    NSString *embedHTML = @"\
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
    NSString *html = [NSString stringWithFormat:embedHTML, urlString, frame.size.width, frame.size.height];
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
-(void)setupLeftMenuButton{
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
