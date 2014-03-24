//
//  GlobalPlayer.h
//  Avibe
//
//  Created by Yuhua Mai on 3/20/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GlobalPlayerDelegate <NSObject>

- (void)prepareCurrentSongSucceed;
- (void)prepareCurrentSongFailed;

@end

@interface GlobalPlayer : NSObject

@property (nonatomic,weak) id<GlobalPlayerDelegate> delegate;

//current playing song
@property NSString *currentMd5;
@property NSString *currentTitle;
@property NSString *currentAlbum;
@property NSString *currentArtist;

@property NSString *currentAlbumUrl;
@property NSString *currentDataUrl;

@property NSData *currentData;
@property UIImage *currentImage;


- (void)insertBasicInfoByMd5:(NSString*)md5 title:(NSString*)title album:(NSString*)album artist:(NSString*)artist;
- (void)insertAlbumUrlByMd5:(NSString*)md5 albumUrl:(NSString*)albumUrl;
- (void)insertDataUrlByMd5:(NSString*)md5 dataUrl:(NSString*)dataUrl;

- (void)setCurrentSongByMd5:(NSString*)md5;
- (void)prepareCurrentSong;

- (void)playPreviousSong;
- (void)playNextSong;
- (void)playPauseSong;

@end
