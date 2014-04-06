//
//  GlobalPlayer.m
//  Avibe
//
//  Created by Yuhua Mai on 3/20/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "GlobalPlayer.h"

#import "SampleMusic.h"
#import "SampleMusicViewController.h"

@interface GlobalPlayer() <SampleMusicDelegate,AVAudioPlayerDelegate,NSXMLParserDelegate>


@property SampleMusic *sampleMusic; //search iTune

@property NSMutableArray *playlist;
@property NSMutableDictionary *dict; // md5 <-> NSMutableDictionary[title,album,artist,url,songdata,image...]

@property (strong, nonatomic) NSTimer *progressTimer;


@property NSString *currentAlbumParseUrl;
@property NSString *currentAlbumITuneUrl;

@property (nonatomic)  NSString *currentDataUrl;


@property BOOL foundSevenDigitalImage;
@property NSString *sevenDigitalImageUrl;

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
        _playlist = [[NSMutableArray alloc] init];
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
- (NSString *)currentMd5
{
    if (!_currentMd5) {
        if(_playlist) _currentMd5 = _playlist[0];
    }
    return _currentMd5;
}

- (void)clearPlaylist
{
    [_playlist removeAllObjects];
}
/*
 * Keep the order of the sequence md5 inserted
 */
- (void)insertMd5:(NSString *)md5
{
    [_playlist addObject:md5];
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
    _currentAlbumParseUrl = _dict[md5][kSongAlbumUrl];
    _currentDataUrl = _dict[md5][kSongDataUrl];
    
    [self prepareCurrentSong];
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
    //Check valid info for dict
    if(!_currentTitle) _currentTitle = @" ";
    if(!_currentAlbum) _currentAlbum = @" ";
    if(!_currentArtist) _currentArtist = @" ";
    
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
    _currentAlbumITuneUrl = [songInfo objectForKey:@"imageURL"];
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

    self.audioPlayer = newPlayer;
    _audioPlayer.delegate = self;

    //Image
    [self handleAlbumImage];
    
    
    
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
    NSUInteger index = [_playlist indexOfObject:self.currentMd5];
    if (index == 0) {
        index = [_playlist count];
    }
    
    NSString *previousMd5 = _playlist[index-1];
    [self setCurrentSongByMd5:previousMd5];
}
- (void)playNextSong
{
    
    NSUInteger index = [_playlist indexOfObject:self.currentMd5];
    
    if (index == [_playlist count]-1) {
        index = -1;
    }
    
    NSString *nextMd5 = _playlist[index+1];
    [self setCurrentSongByMd5:nextMd5];
}
- (void)playPauseSong
{
    //If no default current song, play first one in playlist
    if (!_audioPlayer && _playlist) {
        [self setCurrentSongByMd5:_playlist[0]];
    }else{
        if (self.audioPlayer.playing) {
            [self.audioPlayer pause];
            [_progressTimer invalidate];
        } else {
            [self.audioPlayer play];
            
            if (self.delegate && [self.delegate isKindOfClass:[SampleMusicViewController class]]) {
                _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self.delegate selector:@selector(updateProgress) userInfo:nil repeats:YES];
                
                ;
            }
        }
    }
}


#pragma mark - Handle album image
/**
 * Get Image from PFObject image url
 * If fails, then get album image from iTune
 */
- (void)setAlbumImage:(UIImage *)albumImage
{
//    _albumImage = albumImage;
//    [_sampleMusicImageView setImage:albumImage];
    
    //Set background image for scroll view when setting album image
    //    float imageHeight = albumImage.size.height;
    //    float imageWidth = albumImage.size.width;
    //    float portion = imageHeight/imageWidth;
    
//    UIImageView *scrollBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(-width/2, barHeight, height, height)];
//    [scrollBackgroundView setImage:albumImage];
//    //Mask for ScrollBackgroundView
//    UIView *scrollBackgroundViewMask = [[UIView alloc] initWithFrame:CGRectMake(width/2, 0, width, height)];
//    [scrollBackgroundViewMask setBackgroundColor:[ColorConstant backgroundViewMaskColor]];
//    [scrollBackgroundView addSubview:scrollBackgroundViewMask];
//    
//    [self.view addSubview:scrollBackgroundView];
//    [self.view sendSubviewToBack:scrollBackgroundView];
}
/**
 * Get image from Echo Nest
 * Then try saved album url
 * Last try iTune image
 */
- (void)handleAlbumImage
{
    BOOL sevenDigitalSource = NO;
    BOOL echoNestSource = NO;
    BOOL parseSource = NO;
    BOOL iTuneSource = NO;
    
    sevenDigitalSource = [self getImageFromSevenDigital];
    if (!sevenDigitalSource) {
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
    }
    
    
    //After getting the image url, update parse in class song
//    [self updateSongInfo];
}
- (BOOL)getImageFromSevenDigital
{
    NSString *title = [_currentTitle stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *artist = [_currentArtist stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    /*
     * For release cover art images the following sizes are supported:
        33, 50, 100, 180, 182, 200, 350, 500* and 800* pixels
     * Cover art at this size is not available for some releases (less than 0.1% of the catalogue)
     */
    int imageSize = 500;
    NSString *urlString = [NSString stringWithFormat:@"http://api.7digital.com/1.2/track/search?q=%@+%@&oauth_consumer_key=7ddy52asmehf&pageSize=1&imageSize=%d",title,artist,imageSize];
    NSURL *searchUrl = [NSURL URLWithString:urlString];
    NSData* responseData = [NSData dataWithContentsOfURL:
                            searchUrl];
    
    //XML Parser
    _foundSevenDigitalImage = NO;
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:responseData];
    parser.delegate = self;
    [parser parse];
    
    
    /*
     * Postpone loading image data in Sample Music
     */
    if(_sevenDigitalImageUrl){
        _currentImageUrl = _sevenDigitalImageUrl;
        return YES;
//        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_sevenDigitalImageUrl]];
//        if (imageData) {
//            _currentImage = [UIImage imageWithData:imageData];
//            return YES;
//        }
    }
    
    return NO;
}
#pragma mark - XMLParser Delegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
//    NSLog(@"didStartElement: %@", elementName);
    
    if ([elementName isEqualToString:@"image"]) {
        _foundSevenDigitalImage = YES;
    }
    
//    if (namespaceURI != nil)
//        NSLog(@"namespace: %@", namespaceURI);
//    
//    if (qName != nil)
//        NSLog(@"qualifiedName: %@", qName);
//    
//    // print all attributes for this element
//    NSEnumerator *attribs = [attributeDict keyEnumerator];
//    NSString *key, *value;
//    
//    while((key = [attribs nextObject]) != nil) {
//        value = [attributeDict objectForKey:key];
//        NSLog(@"  attribute: %@ = %@", key, value);
//    }
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
//    NSLog(@"didEndElement: %@", elementName);
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if(_foundSevenDigitalImage)
    {
//        NSLog(@"Value %@",string);
        _foundSevenDigitalImage = NO;
        _sevenDigitalImageUrl = string;
    }
    
}


- (BOOL)getImageFromEchoNest
{
    NSString *title = [_currentTitle stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *artist = [_currentArtist stringByReplacingOccurrencesOfString:@" " withString:@"+"];
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
            
            if (imageUrl) {
                _currentImageUrl = imageUrl;
                return YES;
            }
            
//            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
//            if (imageData) {
////                _currentAlbumUrl = imageUrl; //Update song image url
//                _currentImage = [UIImage imageWithData:imageData];
//                return YES;
//            }
        }
    }
    
    return NO;
}
- (BOOL)getImageFromParse
{
    NSString *imageUrlFromParse = _currentAlbumParseUrl;
    if (imageUrlFromParse) { //Parse image
        
        _currentImageUrl = imageUrlFromParse;
        return YES;
        
//        NSData *imageDataFromParse = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrlFromParse]];
//        if (imageDataFromParse) {
////            _songImageUrlString = imageUrlFromParse;
//            _currentImage = [UIImage imageWithData:imageDataFromParse];
//            return YES;
//        }
    }
    return NO;
}
- (BOOL)getImageFromITune
{
    NSString *imageUrlFromITune = _currentAlbumITuneUrl;
//    NSData *imageDataFromITune;
    if (imageUrlFromITune) {
        
        _currentImageUrl = imageUrlFromITune;
        return YES;
        
//        imageDataFromITune = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrlFromITune]];
    }
//    if (imageDataFromITune) {
//        _currentImage = [UIImage imageWithData:imageDataFromITune];
//        return YES;
//    }
    return NO;
}
- (void)getImageFromDefault
{
    
    _currentImage = [UIImage imageNamed:@"avibe_icon_120_120.png"];
}

#pragma mark - AVAudio player method
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playCurrentSongFinished)]) {
        [self.delegate playCurrentSongFinished];
    }
    
}

@end
