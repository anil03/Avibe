//
//  ShareCollectionViewCell.m
//  Avibe
//
//  Created by Yuhua Mai on 1/19/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "ShareCollectionViewCell.h"

@implementation ShareCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, self.frame.size.width, 30)];
        _titleLabel.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
        _titleLabel.numberOfLines = 2;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:_titleLabel];
    }
    return self;
}

@end
