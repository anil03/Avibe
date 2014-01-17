//
//  WelcomeViewController.m
//  Beet
//
//  Created by Yuhua Mai on 12/27/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "WelcomeViewController.h"

#import "MainViewController.h"

#import "MyLogInViewController.h"
#import "MySignUpViewController.h"

@interface WelcomeViewController () <UIGestureRecognizerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
{
    int currentImageIndex;
    int numberOfImage;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (strong, nonatomic) UIImage *image1;
@property (strong, nonatomic) UIImage *image2;
@property (strong, nonatomic) UIImage *image3;

@property (nonatomic, strong) MyLogInViewController *logInViewController;
@property (nonatomic, strong) MySignUpViewController *signUpViewController;


@end

@implementation WelcomeViewController

- (void)setUpView
{
    float width = [[UIScreen mainScreen] bounds].size.width;
    float height = [[UIScreen mainScreen] bounds].size.height;
    float buttonWidth = width/2;
    float buttonHeight = 80.0f;
    
    //NavigationBar
    [self.navigationController setNavigationBarHidden:YES];
    
    //BackgroundImage
    UIImage *image = [UIImage imageNamed:@"background.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    imageView.image = image;
    [self.view addSubview:imageView];
    
    //Button
    UIButton *logInButton = [[UIButton alloc] initWithFrame:CGRectMake(0, height-buttonHeight, buttonWidth, buttonHeight)];
    [logInButton setTitle:@"Log In" forState:UIControlStateNormal];
    [logInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [logInButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [logInButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4]];
    [logInButton addTarget:self action:@selector(logInButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logInButton];
    
    UIButton *signUpButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth, height-buttonHeight, buttonWidth, buttonHeight)];
    [signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [signUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signUpButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [signUpButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4]];
    [signUpButton addTarget:self action:@selector(SignUpButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signUpButton];
    
    //Avibe Label
    float labelWidth = 200.0f;
    float labelHeight = 50.0f;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(width/2-labelWidth/2, 60.0f, labelWidth, labelHeight)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"Avibe";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:56.0f];
    [self.view addSubview:label];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setUpView];
    [self.navigationController setNavigationBarHidden:YES];

    
    //Log In Controller
    _logInViewController = [[MyLogInViewController alloc] initWithCoder:nil];
    _logInViewController.delegate = self;
    
    // Customize the Sign Up View Controller
    //Should swtich to main view
    _signUpViewController = [[MySignUpViewController alloc] init];
    _signUpViewController.delegate = self;
    _signUpViewController.fields = PFSignUpFieldsDefault | PFSignUpFieldsAdditional;

    
    
    currentImageIndex = 0;
    numberOfImage = 3;
    _pageControl.numberOfPages = numberOfImage;
    
    _image1 = [UIImage imageNamed:@"welcome0.png"];
//    _image2 = [UIImage imageNamed:@"welcome2.png"];
//    _image3 = [UIImage imageNamed:@"welcome3.png"];
    
    _imageView.image = _image1;
    
    [self addSwipeEvent:self.view];
    
    //Skip if already log in
    if ([PFUser currentUser]) {
        [self finishVerification];
//        return;
    }
}

#pragma mark - Button Pressed
- (IBAction)logInButtonPressed {
    [self presentViewController:_logInViewController animated:YES completion:NULL];
}

- (IBAction)SignUpButtonPressed {
    [self presentViewController:_signUpViewController animated:YES completion:NULL];
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
//        NSLog(@" *** SWIPE LEFT ***");
        
        currentImageIndex--;
        if (currentImageIndex < 0) {
            currentImageIndex = 0;
        }
    }
    if ( sender.direction == UISwipeGestureRecognizerDirectionLeft ){
//        NSLog(@" *** SWIPE RIGHT ***");
        
        currentImageIndex++;
        if (currentImageIndex >= numberOfImage) {
            currentImageIndex = numberOfImage-1;
        }
    }
    
//    NSLog(@"%d", currentImageIndex);
    
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



#pragma mark - Handle SignIn & SignUp evenet
- (void)finishVerification
{
    //    [self performSegueWithIdentifier:@"MainViewSegue" sender:nil];
    [self.navigationController setNavigationBarHidden:NO];
    
    MainViewController *mainViewController = [[MainViewController alloc] initWithCoder:nil];
    [self.navigationController pushViewController:mainViewController animated:YES];
}

- (void)failToLogIn
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Fail", nil) message:NSLocalizedString(@"Sorry, not able to Log In!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    
}


#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    if (username && password && username.length && password.length) {
        return YES;
    }
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    return NO;
}



// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    [self finishVerification];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
    [self failToLogIn];
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    NSLog(@"User dismissed the logInViewController");
}

#pragma mark - PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) {
            informationComplete = NO;
            break;
        }
    }
    
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    [self finishVerification];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
    [self failToLogIn];
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}




@end
