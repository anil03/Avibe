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
@property (strong, nonatomic) UIImageView *albumImage;
@property (strong, nonatomic) UIView *mainView;


@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;
@property (weak, nonatomic) IBOutlet UILabel *webLabel;
@property (weak, nonatomic) IBOutlet UIButton *webButton;
@property (weak, nonatomic) IBOutlet UIImageView *twImage;
@property (weak, nonatomic) IBOutlet UIButton *twButton;
@property (weak, nonatomic) IBOutlet UIImageView *fbImage;
@property (weak, nonatomic) IBOutlet UIButton *fbButton;

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
        whiteRoundedCornerView.backgroundColor = [UIColor whiteColor];
        whiteRoundedCornerView.layer.masksToBounds = NO;
        whiteRoundedCornerView.layer.cornerRadius = 3.0;
        whiteRoundedCornerView.layer.shadowOffset = CGSizeMake(-1, 1);
        whiteRoundedCornerView.layer.shadowOpacity = 0.5;
        [self.contentView addSubview:whiteRoundedCornerView];
        [self.contentView sendSubviewToBack:whiteRoundedCornerView];
        
//        _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-10, self.frame.size.height)];
//        _mainView.backgroundColor = [UIColor redColor];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 300, 50)];
        _albumLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, 200, 50)];
        _artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 30, 300, 50)];
        _albumImage = [[UIImageView alloc] initWithFrame:CGRectMake(30, 0, 200, 50)];
        
        [self addSubview:_mainView];
        [self addSubview:_titleLabel];
        [self addSubview:_albumLabel];
        [self addSubview:_artistLabel];
        [self addSubview:_albumImage];

    }
    return self;
}

- (void)setupWithDictionary:(NSDictionary *)dictionary
{
    _titleLabel.text = [dictionary valueForKey:@"title"];
//    _albumLabel.text = [dictionary valueForKey:@"album"];
    _artistLabel.text = [dictionary valueForKey:@"artist"];

    
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
