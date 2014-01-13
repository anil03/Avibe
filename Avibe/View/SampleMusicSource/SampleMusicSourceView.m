//
//  SampleMusicSourceView.m
//  Avibe
//
//  Created by Yuhua Mai on 1/12/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "SampleMusicSourceView.h"

@implementation SampleMusicSourceView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithPosition:(CGPoint)position
{
    self = [super initWithFrame:CGRectMake(position.x, position.y, 80, 40)];
    if (self) {
        float icon_width = 30.0f;
        float icon_height = 30.0f;
        
        self.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5];
        
        UIButton *iTuneButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, icon_width, icon_height)];
        [iTuneButton setBackgroundImage:[UIImage imageNamed:@"iTuneLogo.png"] forState:UIControlStateNormal];
        [iTuneButton addTarget:self action:@selector(listeniTuneMusic) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:iTuneButton];
        
        UIButton *spotifyButton = [[UIButton alloc] initWithFrame:CGRectMake(40, 5, icon_width, icon_height)];
        [spotifyButton setBackgroundImage:[UIImage imageNamed:@"spotifyLogo.png"] forState:UIControlStateNormal];
        [spotifyButton addTarget:self action:@selector(listenSpotifyMusic) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:spotifyButton];
    }
    return self;
}

- (void)listeniTuneMusic
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(listenSampleMusic:)]) {
        [self.delegate listenSampleMusic:@"iTune"];
    }
}

- (void)listenSpotifyMusic
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(listenSampleMusic:)]) {
        [self.delegate listenSampleMusic:@"Spotify"];
    }
}

@end
