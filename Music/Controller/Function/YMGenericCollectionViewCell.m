//
//  YMGenericCollectionViewCell.m
//  Beet
//
//  Created by Yuhua Mai on 12/28/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "YMGenericCollectionViewCell.h"

#import "Setting.h"

@interface YMGenericCollectionViewCell ()

//@property (nonatomic, strong) UILabel *titleLabel;
//@property (strong, nonatomic) UILabel *albumLabel;
//@property (strong, nonatomic) UILabel *artistLabel;
//@property (strong, nonatomic) UILabel *userLabel;

@end

@implementation YMGenericCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [[Setting sharedSetting] sharedCellColor];
        
        _label = [[UILabel alloc] initWithFrame:self.bounds];
//        _label.text = @"test";
        _label.font = [UIFont fontWithName:@"Helvetica Neue" size:(12.0)];
        _label.textAlignment = NSTextAlignmentCenter;
//        _label.adjustsFontSizeToFitWidth = YES;
        [self addSubview:_label];
        
//        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 200, 30)];
//        _titleLabel.text = @"test";
//
//        _albumLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 20, 200, 30)];
//        _albumLabel.text = @"_albumLabel";
//        
//        _artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 35, 200, 30)];
//        _artistLabel.text = @"_artistLabel";
//        
//        _userLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 50, 200, 30)];
//        _userLabel.text = @"_userLabel";
//        
//        [self addSubview:_titleLabel];
//        [self addSubview:_albumLabel];
//        [self addSubview:_artistLabel];
//        [self addSubview:_userLabel];
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

- (void)setupWithDictionary:(NSDictionary *)dictionary
{
    
}

@end
