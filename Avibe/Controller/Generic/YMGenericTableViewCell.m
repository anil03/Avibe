//
//  Cell.m
//  Beet
//
//  Created by Yuhua Mai on 12/7/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "YMGenericTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface YMGenericTableViewCell ()
{
    NSString *website;
    NSString *twitter;
    NSString *facebook;
}


@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *albumLabel;
@property (strong, nonatomic) UILabel *artistLabel;
@property (strong, nonatomic) UILabel *userLabel;

@property (strong, nonatomic) UIImageView *albumImage;

@end

@implementation YMGenericTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        UIView *whiteRoundedCornerView = [[UIView alloc] initWithFrame:CGRectMake(10,10,300,60)];
        whiteRoundedCornerView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6];
        whiteRoundedCornerView.layer.masksToBounds = NO;
        whiteRoundedCornerView.layer.cornerRadius = 3.0;
        whiteRoundedCornerView.layer.shadowOffset = CGSizeMake(-1, 1);
        whiteRoundedCornerView.layer.shadowOpacity = 0.5;
        [self.contentView addSubview:whiteRoundedCornerView];
        [self.contentView sendSubviewToBack:whiteRoundedCornerView];
        
//        _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-10, self.frame.size.height)];
//        _mainView.backgroundColor = [UIColor redColor];
        
        float cellHeightForOneLine = 50;
        
        float leftOffset = 25;
        float titleLabelWidth = 100;
        float artistLabelWidth = 100;
        float userLabelWidth = 80;
        
        //Color Desgin:http://www.colourlovers.com/palette/3164361/palm_trees
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftOffset, 0, titleLabelWidth, cellHeightForOneLine)];
        _titleLabel.textColor = [[UIColor alloc] initWithRed:9.0/255.0 green:38.0/255.0 blue:0.0/255.0 alpha:1];
//        _titleLabel.adjustsFontSizeToFitWidth = YES;
        
        _artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelWidth+leftOffset, 0, artistLabelWidth, cellHeightForOneLine)];
//        _artistLabel.adjustsFontSizeToFitWidth = YES;
        
        
        _userLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelWidth+artistLabelWidth+leftOffset, 0, userLabelWidth, cellHeightForOneLine)];
        _userLabel.textColor = [[UIColor alloc] initWithRed:95.0/255.0 green:81.0/255.0 blue:0.0/255.0 alpha:1];
//        _userLabel.adjustsFontSizeToFitWidth = YES;
        
        
        _albumLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, 200, cellHeightForOneLine)];
        _albumLabel.textColor = [[UIColor alloc] initWithRed:86.0/255.0 green:107.0/255.0 blue:21.0/255.0 alpha:1];
        _albumLabel.adjustsFontSizeToFitWidth = YES;
        
        _albumImage = [[UIImageView alloc] initWithFrame:CGRectMake(30, 0, 200, cellHeightForOneLine)];
        
        [self addSubview:_titleLabel];
        [self addSubview:_albumLabel];
        [self addSubview:_artistLabel];
        [self addSubview:_userLabel];
        [self addSubview:_albumImage];

    }
    return self;
}

- (void)setupWithDictionary:(NSDictionary *)dictionary
{
    
    _titleLabel.text = [dictionary valueForKey:@"title"];
    _artistLabel.text = [dictionary valueForKey:@"artist"];
    _userLabel.text = [dictionary valueForKey:@"user"];

    _albumLabel.text = [dictionary valueForKey:@"album"];

    
//    self.mainView.layer.cornerRadius = 10;
//    self.mainView.layer.masksToBounds = YES;
//    
//    self.profilePhoto.image = [UIImage imageNamed:[dictionary valueForKey:@"image"]];
//    
//    self.nameLabel.text = [dictionary valueForKey:@"name"];
//    self.titleLabel.text = [dictionary valueForKey:@"title"];
//    self.locationLabel.text = [dictionary valueForKey:@"location"];
//    
//    NSString *aboutText = [dictionary valueForKey:@"about"];
//    NSString *newlineString = @"\n";
//    self.aboutLabel.text = [aboutText stringByReplacingOccurrencesOfString:@"\\n" withString:newlineString];
//    
//    website = [dictionary valueForKey:@"web"];
//    if (website) {
//        self.webLabel.text = [dictionary valueForKey:@"web"];
//    } else {
//        self.webLabel.hidden = YES;
//        self.webButton.hidden = YES;
//    }
//    
//    twitter = [dictionary valueForKey:@"twitter"];
//    if (!twitter) {
//        self.twImage.hidden = YES;
//        self.twButton.hidden = YES;
//    } else {
//        self.twImage.hidden = NO;
//        self.twButton.hidden = NO;
//    }
//    
//    facebook = [dictionary valueForKey:@"facebook"];
//    if (!facebook) {
//        self.fbImage.hidden = YES;
//        self.fbButton.hidden = YES;
//    } else {
//        self.fbImage.hidden = NO;
//        self.fbButton.hidden = NO;
//    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (IBAction)launchWeb:(id)sender
{
    if (website) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:website]];
    }
}

- (IBAction)launchTwitter:(id)sender
{
    if (twitter) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:twitter]];
    }
}


- (IBAction)launchFacebook:(id)sender
{
    if (facebook) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:facebook]];
    }
}



@end
