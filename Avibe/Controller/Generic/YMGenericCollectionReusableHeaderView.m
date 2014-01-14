//
//  YMGenericCollectionReusableView.m
//  Beet
//
//  Created by Yuhua Mai on 12/31/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "YMGenericCollectionReusableHeaderView.h"

@implementation YMGenericCollectionReusableHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
//        self.backgroundColor = [UIColor colorWithRed:79.0/255.0
//                                               green:79.0/255.0
//                                                blue:217.0/255.0
//                                               alpha:1.0];
//        self.backgroundColor = [UIColor colorWithRed:115.0/255.0
//                                               green:115.0/255.0
//                                                blue:217.0/255.0
//                                               alpha:1.0];
        
        float width = [UIScreen mainScreen].bounds.size.width/4;
        float height = 20.0f;
        UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        [button1 setTitle:@"Song" forState:UIControlStateNormal];
        button1.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:12.0f];
        
        UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(width, 0, width, height)];
        [button2 setTitle:@"Album" forState:UIControlStateNormal];
        button2.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:12.0f];
        
        UIButton *button3 = [[UIButton alloc] initWithFrame:CGRectMake(width*2, 0, width, height)];
        [button3 setTitle:@"Artist" forState:UIControlStateNormal];
        button3.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:12.0f];
        
        UIButton *button4 = [[UIButton alloc] initWithFrame:CGRectMake(width*3, 0, width, height)];
        [button4 setTitle:@"Friend" forState:UIControlStateNormal];
        button4.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:12.0f];
        
        [self addSubview:button1];
        [self addSubview:button2];
        [self addSubview:button3];
        [self addSubview:button4];

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
