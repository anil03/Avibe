//
//  YMGenericCollectionReusableView.m
//  Beet
//
//  Created by Yuhua Mai on 12/31/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "YMCollectionReusableFooterView.h"

@implementation YMCollectionReusableFooterView
@synthesize loadMoreButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        
        float width = [UIScreen mainScreen].bounds.size.width;
        float height = 40.0f;
        loadMoreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        [loadMoreButton setTitle:@"Load more..." forState:UIControlStateNormal];
        loadMoreButton.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:12.0f];
        
        [self addSubview:loadMoreButton];

    }
    return self;
}

@end
