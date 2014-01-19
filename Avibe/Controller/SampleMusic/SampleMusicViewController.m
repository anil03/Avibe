//
//  SampleMusicViewController.m
//  AddCurrentMusicThenPlaySample
//
//  Created by Yuhua Mai on 11/24/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "SampleMusicViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"

#import "SampleMusic_iTune.h"

#define kLatestKivaLoansURL [NSURL URLWithString:@"http://api.kivaws.org/v1/loans/search.json?status=fundraising"]
#define kiTUNESearchAPI [NSURL URLWithString:@"https://itunes.apple.com/search?term=jack+johnson&limit=1"]
//#define kiTUNESearchAPI [NSURL URLWithString:@"https://itunes.apple.com/search?term=jack+johnson&entity=musicVideo"]

@interface SampleMusicViewController () <AVAudioPlayerDelegate, UIAlertViewDelegate, SampleMusicDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *songImage;

@property (weak, nonatomic) IBOutlet UILabel *playedTime;
@property (weak, nonatomic) IBOutlet UILabel *leftTime;

@property (weak, nonatomic) IBOutlet UISlider *progress;
@property (strong, nonatomic) NSTimer *progressTimer;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistAlbumLabel;

@property (weak, nonatomic) IBOutlet UIButton *playButton;


@property (nonatomic, retain) AVAudioPlayer *player;
@property (strong, nonatomic) MPMoviePlayerController* theMovie;

@property (nonatomic, strong) id timeObserver;

@property (nonatomic, strong) UIViewController *centerViewController;
@property (nonatomic, strong) UIViewController *leftViewController;

@property (nonatomic, strong) UIActivityIndicatorView *spinner;


@end

@implementation SampleMusicViewController

@synthesize pfObject = _pfObject;

@synthesize player; // the player object
@synthesize theMovie;

@synthesize sampleMusic = _sampleMusic;

-(void)viewDidDisappear:(BOOL)animated
{
    [self.player stop];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupLeftMenuButton];
    
    //Spinner
    _spinner = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.center = CGPointMake(160, 240);
    _spinner.hidesWhenStopped = YES;
    [self.view addSubview:_spinner];
    [_spinner startAnimating];

    
    //View Setup
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];

    
    //Disable Left to avoid pan by mistake
    self.centerViewController = self.mm_drawerController.centerViewController;

    //Set AVAudioSesson
    [[AVAudioSession sharedInstance] setDelegate: self];
    NSError *setCategoryError = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &setCategoryError];
    if (setCategoryError)
        NSLog(@"Error setting category! %@", setCategoryError);

    //Search Music
    _sampleMusic.delegate = self;
    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:@[[_pfObject objectForKey:@"title"]] forKeys:@[@"title"]];
    [_sampleMusic startSearch:dict];
}

#pragma mark - Sample Music Data Delegate Method
- (void)finishFetchData:(NSData *)song andInfo:(NSDictionary *)songInfo
{
    [self updateViewInfo:songInfo];
    
    NSError* __autoreleasing audioError = nil;
    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithData:song error:&audioError];

    if (!audioError) {
        self.player = newPlayer;
        self.player.delegate = self;
        
        //Update Progress Slider
        self.progress.maximumValue = self.player.duration;
        self.progress.userInteractionEnabled = NO;
        
        [player prepareToPlay];
    }else{
        NSLog(@"Audio Error!");
    }
    
    [_spinner stopAnimating];
}

- (void)updateViewInfo:(NSDictionary *)result {
    NSURL *imageUrl = [NSURL URLWithString:[result objectForKey:@"imageURL"]];
    NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
    UIImage *image = [UIImage imageWithData:imageData];
    [self.songImage setImage:image];
    
    //Comment out to fit to original size
    int scale = 2;
    float imageWidth = image.size.width*scale;
    float imageHeight = image.size.height*scale;
    self.songImage.frame = CGRectMake(self.songImage.center.x-imageWidth/2, self.songImage.center.y-imageHeight/2,imageWidth, imageHeight);
    
    self.titleLabel.text = [result objectForKey:@"title"];
    self.artistAlbumLabel.text = [NSString stringWithFormat:@"%@ - %@", [result objectForKey:@"artist"], [result objectForKey:@"album"]];
    
    self.playedTime.text = @"0:00";
    int min = self.player.duration/60;
    int sec = ceil(self.player.duration-min*60);
    self.leftTime.text = [NSString stringWithFormat:@"%d:%02d", min, sec];
}


- (IBAction) playOrPause: (id) sender {
    
    self.playButton.selected = !self.playButton.selected;
    // if already playing, then pause
    if (self.player.playing) {
        [self.player pause];
        [self.progressTimer invalidate];
    } else {
        [self.player play];
        
        self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    }
}

- (void)updateProgress
{
    
    int minPlayed = self.player.currentTime/60;
    int secPlayed = ceil(self.player.currentTime-minPlayed*60);
    int minLeft = (self.player.duration-self.player.currentTime)/60;
    int secLeft = ceil((self.player.duration-self.player.currentTime)-minLeft*60);
    
    self.playedTime.text = [NSString stringWithFormat:@"%d:%02d", minPlayed, secPlayed];
    self.leftTime.text = [NSString stringWithFormat:@"%d:%02d", minLeft, secLeft];
    
    self.progress.value = self.player.currentTime;
}



#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.progressTimer invalidate];
    [self leftDrawerButtonPress:nil];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    [self.progressTimer invalidate];
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

#pragma mark - UIAlertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
//        NSLog(@"user pressed OK");
        [self leftDrawerButtonPress:nil];
    } else {
        NSLog(@"user pressed Cancel");
    }
}

#pragma mark - Movie Method
//- (IBAction)moviePlay:(id)sender
//{
//    [self.view addSubview:theMovie.view];
//    [theMovie play];
//}

-(void) playMovieAtURL: (NSURL*) theURL {
    
    theMovie = [[MPMoviePlayerController alloc] initWithContentURL: theURL];
    
    [theMovie.view setFrame:self.view.bounds];
    
    //    theMovie.scalingMode = MPMovieScalingModeAspectFill;
    theMovie.controlStyle = MPMovieControlStyleFullscreen;
    //    theMovie.fullscreen=NO;
    //    theMovie.allowsAirPlay=YES;
    //    theMovie.shouldAutoplay=NO;
    //    theMovie.controlStyle=MPMovieControlStyleEmbedded;
    
    // Register for the playback finished notification
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(myMovieFinishedCallback:)
     name: MPMoviePlayerPlaybackDidFinishNotification
     object: theMovie];
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(myMovieFinishedCallback:)
     name: MPMoviePlayerDidExitFullscreenNotification
     object: theMovie];
    
    [theMovie prepareToPlay];
    
    // Movie playback is asynchronous, so this method returns immediately.
    //    [theMovie play];
}

// When the movie is done, release the controller.
-(void) myMovieFinishedCallback: (NSNotification*) aNotification
{
    [theMovie.view removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name: MPMoviePlayerPlaybackDidFinishNotification
     object: theMovie];
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name: MPMoviePlayerDidExitFullscreenNotification
     object: theMovie];
}


@end
