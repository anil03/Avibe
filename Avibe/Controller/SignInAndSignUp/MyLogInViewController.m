//
//  MyLogInViewController.m
//  LogInAndSignUpDemo
//
//  Created by Mattieu Gamache-Asselin on 6/15/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "MyLogInViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "BackgroundImageView.h"
#import "SubclassConfigViewController.h"

@interface MyLogInViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
@property (nonatomic, strong) UIImageView *fieldsBackground;
@end

@implementation MyLogInViewController

@synthesize fieldsBackground;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    self.delegate = self;
//    self.facebookPermissions = @[@"friends_about_me", @"user_actions.music"];
    self.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsPasswordForgotten | PFLogInFieldsDismissButton;
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set buttons appearance
//    [self.logInView.dismissButton setHidden:YES];
//    [self.logInView.dismissButton setImage:[UIImage imageNamed:@"Exit.png"] forState:UIControlStateNormal];
//    [self.logInView.dismissButton setImage:[UIImage imageNamed:@"ExitDown.png"] forState:UIControlStateHighlighted];
    
//    [self.logInView.facebookButton setImage:nil forState:UIControlStateNormal];
//    [self.logInView.facebookButton setImage:nil forState:UIControlStateHighlighted];
//    [self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"FacebookDown.png"] forState:UIControlStateHighlighted];
//    [self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"Facebook.png"] forState:UIControlStateNormal];
//    [self.logInView.facebookButton setTitle:@"" forState:UIControlStateNormal];
//    [self.logInView.facebookButton setTitle:@"" forState:UIControlStateHighlighted];
    
    //Log in
//    [self.logInView.logInButton setBackgroundImage:[UIImage imageNamed:@"LogIn.png"] forState:UIControlStateNormal];
//    [self.logInView.logInButton setBackgroundImage:[UIImage imageNamed:@"LogInDown.png"] forState:UIControlStateHighlighted];
//    [self.logInView.logInButton setTitle:@"" forState:UIControlStateNormal];
//    [self.logInView.logInButton setTitle:@"" forState:UIControlStateHighlighted];
    
    //Sign up
//    [self.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@"Signup.png"] forState:UIControlStateNormal];
//    [self.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@"SignupDown.png"] forState:UIControlStateHighlighted];
//    [self.logInView.signUpButton setTitle:@"" forState:UIControlStateNormal];
//    [self.logInView.signUpButton setTitle:@"" forState:UIControlStateHighlighted];
    
    //passwordForgottenButton
//    [self.logInView.passwordForgottenButton setBackgroundImage:[UIImage imageNamed:@"PasswordForgotten.png"] forState:UIControlStateNormal];
//    [self.logInView.passwordForgottenButton setBackgroundImage:[UIImage imageNamed:@"PasswordForgottenDown.png"] forState:UIControlStateHighlighted];
//    [self.logInView.passwordForgottenButton setTitle:@"" forState:UIControlStateNormal];
//    [self.logInView.passwordForgottenButton setTitle:@"" forState:UIControlStateHighlighted];
//    
//    [self.logInView.externalLogInLabel setHidden:YES];
//    [self.logInView.signUpLabel setHidden:YES];
    
    // Add login field background
//    fieldsBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LoginFieldBG.png"]];
//    [self.logInView addSubview:self.fieldsBackground];
//    [self.logInView sendSubviewToBack:self.fieldsBackground];
    
    // Remove text shadow
//    CALayer *layer = self.logInView.usernameField.layer;
//    layer.shadowOpacity = 0.0f;
//    layer = self.logInView.passwordField.layer;
//    layer.shadowOpacity = 0.0f;
    
    
    
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    //Variables
    float width = [[UIScreen mainScreen] bounds].size.width;
    float height = [[UIScreen mainScreen] bounds].size.height;
    float fieldWidth = width;
    float fieldHeight = 60.0f;
    float buttonWidth = width/2;
    float buttonHeight = fieldHeight;
    float currentHeight = 0.0f;
    
    //Background Logo
//    UIImage *image = [UIImage imageNamed:@"background.png"];
//    [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:image]];
    [self.logInView setBackgroundColor:[UIColor clearColor]];
    
    //BackgroundImageView
    UIView *backgroundView = [[BackgroundImageView alloc] initWithFrame:self.view.frame];
    [self.logInView addSubview:backgroundView];
    [self.logInView sendSubviewToBack:backgroundView];
    
    //Avibe Label
    float labelWidth = 200.0f;
    float labelHeight = 50.0f;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(width/2-labelWidth/2, 60.0f, labelWidth, labelHeight)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"Avibe";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:56.0f];
    [self.view addSubview:label];
    self.logInView.logo = label;
    
    
    //Input Field
    currentHeight = fieldHeight*2 + 30.0f;
    UIColor *fieldBackgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
    [self.logInView.usernameField setFrame:CGRectMake(0, currentHeight, fieldWidth, fieldHeight)];
    [self.logInView.usernameField setBackgroundColor:fieldBackgroundColor];
    [self.logInView.usernameField setBackground:nil];

    currentHeight += fieldHeight;
    [self.logInView.passwordField setFrame:CGRectMake(0, currentHeight, fieldWidth, fieldHeight)];
    [self.logInView.passwordField setBackgroundColor:fieldBackgroundColor];
    // Field default text
    self.logInView.usernameField.text = @"myhgew2";
    self.logInView.passwordField.text = @"1989723";


    //Log In
    currentHeight += fieldHeight;
    [self.logInView.logInButton setBackgroundColor:[UIColor clearColor]];
    [self.logInView.logInButton setTitle:@"Log In" forState:UIControlStateNormal];
    [self.logInView.logInButton setTitle:@"Log In" forState:UIControlStateHighlighted];
    [self.logInView.logInButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.logInView.logInButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.logInButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.logInView.logInButton setFrame:CGRectMake(0, currentHeight, buttonWidth, buttonHeight)];
    
    //Facebook
    [self.logInView.externalLogInLabel setHidden:YES];
    UIButton *facebookButton = [[UIButton alloc] init];
    [facebookButton setBackgroundColor:[UIColor clearColor]];
    [facebookButton setTitle:@"Facebook" forState:UIControlStateNormal];
    [facebookButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [facebookButton setBackgroundImage:nil forState:UIControlStateNormal];
    [facebookButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [facebookButton setFrame:CGRectMake(buttonWidth, currentHeight, buttonWidth, buttonHeight)];
    [facebookButton addTarget:self action:@selector(facebookLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:facebookButton];
    
    //Fogotton button
    buttonHeight = 20.0f;
    float bottom = 35.0f;
    float fontsize = 14.0f;
    currentHeight = height-buttonHeight*2-bottom;
    [self.logInView.passwordForgottenButton setBackgroundColor:[UIColor clearColor]];
    [self.logInView.passwordForgottenButton setTitle:@"Forgot" forState:UIControlStateNormal];
    [self.logInView.passwordForgottenButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.logInView.passwordForgottenButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.passwordForgottenButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.logInView.passwordForgottenButton setFrame:CGRectMake(0, currentHeight, width, buttonHeight)];
    [self.logInView.passwordForgottenButton.titleLabel setFont:[UIFont systemFontOfSize:fontsize]];
    
    //Dismiss
    currentHeight = height-buttonHeight-bottom;
    [self.logInView.dismissButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [self.logInView.dismissButton setBackgroundColor:[UIColor clearColor]];
    [self.logInView.dismissButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.logInView.dismissButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.logInView.dismissButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.dismissButton setImage:nil forState:UIControlStateHighlighted];
    [self.logInView.dismissButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.dismissButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.logInView.dismissButton setFrame:CGRectMake(0, currentHeight, width, fieldHeight)];
    [self.logInView.dismissButton.titleLabel setFont:[UIFont systemFontOfSize:fontsize]];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Facebook Login Method
- (void)facebookLogin
{
    [PFFacebookUtils logInWithPermissions:@[@"user_actions.music"] block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
            [self.delegate logInViewControllerDidCancelLogIn:self];
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");

            
            // Create request for user's Facebook data
            FBRequest *request = [FBRequest requestForMe];
            
            // Send request to Facebook
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    // result is a dictionary with the user's Facebook data
                    NSDictionary *userData = (NSDictionary *)result;

                    [user setObject:userData[@"id"] forKey:kClassUserUsername];
                    [user setObject:userData[@"name"] forKey:kClassUserDisplayname];
//                    [user setObject:userData[@"email"] forKey:kClassUserEmail];
                    
                    [user setObject:@YES forKey:kClassUserFacebookIntegratedWithParse];
                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            NSLog(@"Facebook User saved.");
                            [self.delegate logInViewController:self didLogInUser:nil];
                        }
                        
                    }];
                }
            }];
            
            
            
        } else {
            NSLog(@"User logged in through Facebook!");

            [self.delegate logInViewController:self didLogInUser:nil];
        }
    }];
}


@end
