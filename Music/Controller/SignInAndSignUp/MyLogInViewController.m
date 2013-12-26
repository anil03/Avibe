//
//  MyLogInViewController.m
//  LogInAndSignUpDemo
//
//  Created by Mattieu Gamache-Asselin on 6/15/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "MyLogInViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "MySignUpViewController.h"

#import "MainViewController.h"
#import "SubclassConfigViewController.h"

@interface MyLogInViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
@property (nonatomic, strong) UIImageView *fieldsBackground;
@end

@implementation MyLogInViewController

@synthesize fieldsBackground;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    //Set up Property
    self.delegate = self;
    self.facebookPermissions = @[@"friends_about_me"];
    self.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsFacebook | PFLogInFieldsSignUpButton | PFLogInFieldsLogInButton | PFLogInFieldsPasswordForgotten;
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([PFUser currentUser]) {
        [self finishVerification];
        return;
    }
    
    // Customize the Sign Up View Controller
    //Should swtich to main view
    MySignUpViewController *signUpViewController = [[MySignUpViewController alloc] init];
    signUpViewController.delegate = self;
    signUpViewController.fields = PFSignUpFieldsDefault | PFSignUpFieldsAdditional;
    self.signUpController = signUpViewController;
    
    
    
    //Set up View
    
    [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"MainBG.png"]]];
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo.png"]]];
    
    // Set buttons appearance
    [self.logInView.dismissButton setHidden:YES];
//    [self.logInView.dismissButton setImage:[UIImage imageNamed:@"Exit.png"] forState:UIControlStateNormal];
//    [self.logInView.dismissButton setImage:[UIImage imageNamed:@"ExitDown.png"] forState:UIControlStateHighlighted];
    
    [self.logInView.facebookButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.facebookButton setImage:nil forState:UIControlStateHighlighted];
    [self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"FacebookDown.png"] forState:UIControlStateHighlighted];
    [self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"Facebook.png"] forState:UIControlStateNormal];
    [self.logInView.facebookButton setTitle:@"" forState:UIControlStateNormal];
    [self.logInView.facebookButton setTitle:@"" forState:UIControlStateHighlighted];
    
    //Log in
    [self.logInView.logInButton setBackgroundImage:[UIImage imageNamed:@"LogIn.png"] forState:UIControlStateNormal];
    [self.logInView.logInButton setBackgroundImage:[UIImage imageNamed:@"LogInDown.png"] forState:UIControlStateHighlighted];
    [self.logInView.logInButton setTitle:@"" forState:UIControlStateNormal];
    [self.logInView.logInButton setTitle:@"" forState:UIControlStateHighlighted];
    
    //Sign up
    [self.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@"Signup.png"] forState:UIControlStateNormal];
    [self.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@"SignupDown.png"] forState:UIControlStateHighlighted];
    [self.logInView.signUpButton setTitle:@"" forState:UIControlStateNormal];
    [self.logInView.signUpButton setTitle:@"" forState:UIControlStateHighlighted];
    
    //passwordForgottenButton
    [self.logInView.passwordForgottenButton setBackgroundImage:[UIImage imageNamed:@"PasswordForgotten.png"] forState:UIControlStateNormal];
    [self.logInView.passwordForgottenButton setBackgroundImage:[UIImage imageNamed:@"PasswordForgottenDown.png"] forState:UIControlStateHighlighted];
    [self.logInView.passwordForgottenButton setTitle:@"" forState:UIControlStateNormal];
    [self.logInView.passwordForgottenButton setTitle:@"" forState:UIControlStateHighlighted];
    
    [self.logInView.externalLogInLabel setHidden:YES];
    [self.logInView.signUpLabel setHidden:YES];
    
    // Add login field background
    fieldsBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LoginFieldBG.png"]];
    [self.logInView addSubview:self.fieldsBackground];
    [self.logInView sendSubviewToBack:self.fieldsBackground];
    
    // Remove text shadow
    CALayer *layer = self.logInView.usernameField.layer;
    layer.shadowOpacity = 0.0f;
    layer = self.logInView.passwordField.layer;
    layer.shadowOpacity = 0.0f;
    
    // Set field text color
    [self.logInView.usernameField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    [self.logInView.passwordField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    
    //For debug convenience
    self.logInView.usernameField.text = @"myhgew2";
    self.logInView.passwordField.text = @"1989723";
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Set frame for elements
    float column1 = 35.0f;
    float column2 = 165.0f;
    float rowField = 175.0f;
    float row1 = 330.0f;
    float row2 = 405.0f;
    
    [self.logInView.logo setFrame:CGRectMake(66.5f, 70.0f, 187.0f, 58.5f)];
    
    [self.logInView.facebookButton setFrame:CGRectMake(column1, row2, 120.0f, 40.0f)];
    [self.logInView.passwordForgottenButton setFrame:CGRectMake(column2, row2, 120.0f, 40.0f)];
    
    [self.logInView.logInButton setFrame:CGRectMake(column1, row1, 120.0f, 40.0f)];
    //Clear LogInButton Title
    [self.logInView.logInButton setTitle:@"" forState:UIControlStateNormal];
    [self.logInView.logInButton setTitle:@"" forState:UIControlStateHighlighted];
    
    [self.logInView.signUpButton setFrame:CGRectMake(column2, row1, 120.0f, 40.0f)];

    
    [self.logInView.usernameField setFrame:CGRectMake(column1, rowField, 250.0f, 50.0f)];
    [self.logInView.passwordField setFrame:CGRectMake(column1, rowField+50.0f, 250.0f, 50.0f)];
    [self.fieldsBackground setFrame:CGRectMake(column1, rowField, 250.0f, 100.0f)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
