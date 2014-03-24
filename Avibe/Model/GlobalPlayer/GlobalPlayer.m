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

@end

@implementation GlobalPlayer

NSString *const kSongTitle = @"title";
NSString *const kSongAlbum = @"album";
NSString *const kSongArtist = @"artist";
NSString *const kSongAlbumUrl = @"albumUrl";
NSString *const kSongDataUrl = @"dataUrl";

NSString *const kSongData = @"data";


#pragma mark - Init global player
- (id)init
{
    self = [super init];
    if (self) {
        _dict = [[NSMutableDictionary alloc] init];
    }
    return self;
}
- (NSMutableDictionary*)songByMd5:(NSString*)md5
{
    NSMutableDictionary *song = _dict[md5];
    if (!song) {
        song = [[NSMutableDictionary alloc] init];
        [_dict setValue:song forKey:md5];
    }
    return song;
}
- (void)insertBasicInfoByMd5:(NSString *)md5 title:(NSString *)title album:(NSString *)album artist:(NSString *)artist
{
    NSMutableDictionary *song = [self songByMd5:md5];
    if(title) song[kSongTitle] = title;
    if(album) song[kSongAlbum] = album;
    if(artist) song[kSongArtist] = artist;
}
- (void)insertAlbumUrlByMd5:(NSString *)md5 albumUrl:(NSString *)albumUrl
{
    if (albumUrl) {
        NSMutableDictionary *song = [self songByMd5:md5];
        song[kSongAlbumUrl] = albumUrl;
    }
}
- (void)insertDataUrlByMd5:(NSString *)md5 dataUrl:(NSString *)dataUrl
{
    if (dataUrl) {
        NSMutableDictionary *song = [self songByMd5:md5];
        song[kSongDataUrl] = dataUrl;
    }
}
- (void)setCurrentSongByMd5:(NSString *)md5
{
    _currentMd5 = md5;
    _currentTitle = _dict[md5][kSongTitle];
    _currentAlbum = _dict[md5][kSongAlbum];
    _currentArtist = _dict[md5][kSongArtist];
    _currentAlbumUrl = _dict[md5][kSongAlbumUrl];
    _currentDataUrl = _dict[md5][kSongDataUrl];
}
- (void)prepareCurrentSong
{
    /**
     * Preview Url existed, then no need to search from iTune
     */
    if (_currentDataUrl) {
        [self handleAudioPlayer:_currentDataUrl];
    }else{
        [self listenInItune];
    }
}

#pragma mark - iTune Music
- (void)listenInItune
{
    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:@[_currentTitle, _currentAlbum, _currentArtist] forKeys:@[@"title", @"album", @"artist"]];
    _sampleMusic = [[SampleMusic alloc] init];
    _sampleMusic.delegate = self;
    [_sampleMusic startSearch:dict];
    
}
- (void)finishFetchData:(NSDictionary *)songInfo
{
    //Update origin song info
    _currentTitle = [songInfo objectForKey:@"title"];
    _currentAlbum = [songInfo objectForKey:@"album"];
    _currentArtist = [songInfo objectForKey:@"artist"];
//    _collectionViewUrlLinkToITuneStore = [songInfo objectForKey:@"collectionViewUrl"];
//    _songImageUrlString = [songInfo objectForKey:@"imageURL"];
    _currentDataUrl = [songInfo objectForKey:@"previewUrl"];
    
    
    //Music Player
    [self handleAudioPlayer:_currentDataUrl];
}
- (void)finishFetchDataWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(prepareCurrentSongFailed)]) {
        [self.delegate prepareCurrentSongFailed];
    }
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
    _currentData = songData;
    _dict[_currentMd5][kSongData] = songData;
    
    NSError* audioError = nil;
    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithData:songData error:&audioError];
    if (audioError) {
        NSLog(@"Audio error:%@", audioError.description);
    }

    _player = newPlayer;

    if (self.delegate && [self.delegate respondsToSelector:@selector(prepareCurrentSongSucceed)]) {
        [self.delegate prepareCurrentSongSucceed];
    }

    
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
}

#pragma mark - Play method
- (void)playPreviousSong
{
    
}
- (void)playNextSong
{
    
}
- (void)playPauseSong
{
    if (_player.playing) {
        [_player pause];
//        [_progressTimer invalidate];
    } else {
        [_player play];
//        _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    }

}

@end
