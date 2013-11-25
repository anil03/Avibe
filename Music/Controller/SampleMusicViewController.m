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


#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define kLatestKivaLoansURL [NSURL URLWithString:@"http://api.kivaws.org/v1/loans/search.json?status=fundraising"]
#define kiTUNESearchAPI [NSURL URLWithString:@"https://itunes.apple.com/search?term=jack+johnson&limit=1"]
//#define kiTUNESearchAPI [NSURL URLWithString:@"https://itunes.apple.com/search?term=jack+johnson&entity=musicVideo"]

@interface SampleMusicViewController ()
@property (weak, nonatomic) IBOutlet UILabel *songInfo;
@property (nonatomic, retain) AVAudioPlayer *player;
@property (strong, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) MPMoviePlayerController* theMovie;
@end

@implementation SampleMusicViewController
@synthesize song = _song;
@synthesize songInfo = _songInfo;

@synthesize player; // the player object
@synthesize button;
@synthesize theMovie;

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
	// Do any additional setup after loading the view.
    _songInfo.text = [NSString stringWithFormat:@"%@, %@, %@", _song.title, _song.album, _song.artist];
    
    NSString *searchTitle = [_song.title stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSURL *searchURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&limit=10", searchTitle]];
    
    //JSON
    [[AVAudioSession sharedInstance] setDelegate: self];
    NSError *setCategoryError = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &setCategoryError];
    if (setCategoryError)
        NSLog(@"Error setting category! %@", setCategoryError);
    
    
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        searchURL];
        [self performSelectorOnMainThread:@selector(fetchedData:)
                               withObject:data waitUntilDone:YES];
    });
}



- (IBAction)Back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - JSON

- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error = nil;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    NSArray* results = [json objectForKey:@"results"];
    
    NSLog(@"results: %@", results);
    
    // 1) Get the latest loan
    NSDictionary* result = [results objectAtIndex:0];
    
    // 2) Get the funded amount and loan amount
    NSString* type = [result objectForKey:@"wrapperType"];
    NSString* kind = [result objectForKey:@"kind"];
    NSURL* previewUrl = [NSURL URLWithString:[result objectForKey:@"previewUrl"]];
    
    //    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:previewUrl];
    //    AVPlayer* player = [AVPlayer playerWithPlayerItem:playerItem];
    //    player = [AVPlayer playerWithURL:previewUrl];
    //    [player play];
    NSLog(@"URL: %@", previewUrl);
    
    if([kind isEqualToString:@"song"]){
        NSError* __autoreleasing soundFileError = nil;
        NSError* __autoreleasing audioError = nil;
        
        NSData *songFile = [[NSData alloc] initWithContentsOfURL:previewUrl options:NSDataReadingMappedIfSafe error:&soundFileError ];
        
        AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithData:songFile error:nil];
        
        self.player = newPlayer;
        
        [player prepareToPlay];
        [player setDelegate: self];
    }else if([kind isEqualToString:@"music-video"]){
        [self playMovieAtURL:previewUrl];
    }
}

- (IBAction) playOrPause: (id) sender {
    
    // if already playing, then pause
    if (self.player.playing) {
        [self.button setTitle: @"Play" forState: UIControlStateHighlighted];
        [self.button setTitle: @"Play" forState: UIControlStateNormal];
        [self.player pause];
        
        // if stopped or paused, start playing
    } else {
        [self.button setTitle: @"Pause" forState: UIControlStateHighlighted];
        [self.button setTitle: @"Pause" forState: UIControlStateNormal];
        [self.player play];
    }
}

- (IBAction)moviePlay:(id)sender
{
    [self.view addSubview:theMovie.view];
    [theMovie play];
}

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
