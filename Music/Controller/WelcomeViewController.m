//
//  WelcomeViewController.m
//  Beet
//
//  Created by Yuhua Mai on 12/27/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController () <UIGestureRecognizerDelegate>
{
    int currentImageIndex;
    int numberOfImage;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (strong, nonatomic) UIImage *image1;
@property (strong, nonatomic) UIImage *image2;
@property (strong, nonatomic) UIImage *image3;

@end

@implementation WelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    currentImageIndex = 0;
    numberOfImage = 3;
    _pageControl.numberOfPages = numberOfImage;
    
    _image1 = [UIImage imageNamed:@"welcome0.png"];
//    _image2 = [UIImage imageNamed:@"welcome2.png"];
//    _image3 = [UIImage imageNamed:@"welcome3.png"];
    
    _imageView.image = _image1;
    
    [self addSwipeEvent:self.view];
}

- (IBAction)logInButtonPressed {
    
}

- (IBAction)SignUpButtonPressed {
    
}

#pragma mark - gesture
-(void)addSwipeEvent:(UIView*)subView{
    
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(SwipeRecognizer:)];
    rightRecognizer.numberOfTouchesRequired = 1;
    rightRecognizer.delegate = self;
    [subView addGestureRecognizer:rightRecognizer];
    
    UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(SwipeRecognizer:)];
    leftRecognizer.direction=UISwipeGestureRecognizerDirectionLeft;
    leftRecognizer.numberOfTouchesRequired = 1;
    leftRecognizer.delegate = self;
    [subView addGestureRecognizer:leftRecognizer];
}

- (void) SwipeRecognizer:(UISwipeGestureRecognizer *)sender {
    if ( sender.direction == UISwipeGestureRecognizerDirectionRight){
        NSLog(@" *** SWIPE LEFT ***");
        
        currentImageIndex--;
        if (currentImageIndex < 0) {
            currentImageIndex = 0;
        }
    }
    if ( sender.direction == UISwipeGestureRecognizerDirectionLeft ){
        NSLog(@" *** SWIPE RIGHT ***");
        
        currentImageIndex++;
        if (currentImageIndex >= numberOfImage) {
            currentImageIndex = numberOfImage-1;
        }
    }
    
    NSLog(@"%d", currentImageIndex);
    
    _pageControl.currentPage = currentImageIndex;
    _imageView.image = [UIImage imageNamed:[NSString stringWithFormat: @"welcome%d.png", currentImageIndex]];
}


-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIView class]])
    {
        return YES;
    }
    return NO;
}




@end
