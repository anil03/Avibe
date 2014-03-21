//
//  GlobalPlayer.m
//  Avibe
//
//  Created by Yuhua Mai on 3/20/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "GlobalPlayer.h"

#import <AVFoundation/AVFoundation.h>
#import "SampleMusic.h"

@interface GlobalPlayer() <SampleMusicDelegate>

@property (nonatomic, retain) AVAudioPlayer *player;

@property SampleMusic *sampleMusic; //search iTune

@property NSMutableDictionary *dict; // md5 <-> NSMutableDictionary[title,album,artist,url,songdata,image...]

//current playing song
@property NSString *currentTitle;
@property NSString *currentAlbum;
@property NSString *currentArtist;
@property UIImage *currentImage;

@end

@implementation GlobalPlayer

#pragma mark - iTune Music
- (void)listenInItune
{
    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:@[_currentTitle, _currentAlbum, _currentArtist] forKeys:@[@"title", @"album", @"artist"]];
    _sampleMusic = [[SampleMusic alloc] init];
    _sampleMusic.delegate = self;
    [_sampleMusic startSearch:dict];
    
}
//- (void)finishFetchData:(NSDictionary *)songInfo
//{
//    //Update origin song info
//    _songTitle = [songInfo objectForKey:@"title"];
//    _songAlbum = [songInfo objectForKey:@"album"];
//    _songArtist = [songInfo objectForKey:@"artist"];
//    _collectionViewUrlLinkToITuneStore = [songInfo objectForKey:@"collectionViewUrl"];
//    _songImageUrlString = [songInfo objectForKey:@"imageURL"];
//    _songPreviewUrlString = [songInfo objectForKey:@"previewUrl"];
//    _navigationBarTitleLabel.text = [NSString stringWithFormat:@"%@ - %@", _songTitle, _songArtist];
//    
//    
//    //Music Player
//    [self handleAudioPlayer:_songPreviewUrlString];
//}
//- (void)finishFetchDataWithError:(NSError *)error
//{
//    _iTuneFetchErrorAlertView = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Sorry, can't find the sample song." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [_iTuneFetchErrorAlertView show];
//    
//    //    [_spinner stopAnimating];
//    //    [self fetchFromEchoNest];
//}
//- (void)handleAudioPlayer:(NSString*)previewUrlString
//{
//    dispatch_async(kBgQueue, ^{
//        NSURL* previewUrl = [NSURL URLWithString:previewUrlString];
//        NSError* soundFileError = nil;
//        NSData *songFile = [[NSData alloc] initWithContentsOfURL:previewUrl options:NSDataReadingMappedIfSafe error:&soundFileError ];
//        if (soundFileError) {
//            NSLog(@"Sound file error:%@", soundFileError.description);
//            return;
//        }
//        
//        [self performSelectorOnMainThread:@selector(fetchSongData:)
//                               withObject:songFile waitUntilDone:YES];
//    });
//}
//- (void)fetchSongData:(NSData*)songData
//{
//    NSError* audioError = nil;
//    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithData:songData error:&audioError];
//    if (audioError) {
//        NSLog(@"Audio error:%@", audioError.description);
//    }
//    
//    _player = newPlayer;
//    _player.delegate = self;
//    
//    //Update Progress Slider
//    //        self.progress.maximumValue = self.player.duration;
//    self.progress.userInteractionEnabled = NO;
//    
//    _playedTime.text = @"0:00";
//    int minLeft = self.player.duration/60;
//    int secLeft = ceil(self.player.duration-minLeft*60);
//    _leftTime.text = [NSString stringWithFormat:@"%d:%02d", minLeft, secLeft];
//    
//    [_player prepareToPlay];
//    
//    //User interface
//    [_playButton setHidden:NO];
//    [_shareButton setHidden:NO];
//    [_playSourceButton setHidden:NO];
//    [_iTuneButton setHidden:NO];
//    [_addMoreLikeThisView setHidden:NO];
//    
//    //Spinner
//    [_spinner stopAnimating];
//    //Album image
//    [self handleAlbumImage];
//    //Recommended songs
//    [self fetchFromEchoNest];
//}

@end
