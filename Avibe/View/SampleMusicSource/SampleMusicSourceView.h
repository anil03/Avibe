//
//  SampleMusicSourceView.h
//  Avibe
//
//  Created by Yuhua Mai on 1/12/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SampleMusicSourceViewDelegate <NSObject>

- (void)listenSampleMusic:(NSString*)source;

@end

@interface SampleMusicSourceView : UIView

@property (nonatomic, weak) id<SampleMusicSourceViewDelegate> delegate;

- (id)initWithPosition:(CGPoint)position;

@end
