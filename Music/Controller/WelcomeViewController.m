//
//  WelcomeViewController.m
//  Beet
//
//  Created by Yuhua Mai on 12/27/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;


@end

@implementation WelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    _pageControl.numberOfPages = 6;
}

- (IBAction)logInButtonPressed {
}

- (IBAction)SignUpButtonPressed {
}


@end
