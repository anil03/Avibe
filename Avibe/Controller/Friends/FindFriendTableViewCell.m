//
//  FindFriendTableViewCell.m
//  Avibe
//
//  Created by Yuhua Mai on 1/20/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "FindFriendTableViewCell.h"
#import "FindFriendButton.h"

@implementation FindFriendTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        float width = [[UIScreen mainScreen] bounds].size.width;
        float topOffset = 6.5f;
        float rightOffset = 10.0f;
        float buttonWidth = 70.0f;
        float buttonHeight = 30.0f;
        
        _followButton = [[FindFriendButton alloc] initWithFrame:CGRectMake(width-rightOffset-buttonWidth, topOffset, buttonWidth, buttonHeight)];
        [_followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_followButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_followButton setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
        _followButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_followButton setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.05]];
        [self addSubview:_followButton];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
