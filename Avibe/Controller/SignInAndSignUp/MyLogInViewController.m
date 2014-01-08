//
//  MyLogInViewController.m
//  LogInAndSignUpDemo
//
//  Created by Mattieu Gamache-Asselin on 6/15/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "MyLogInViewController.h"
#import <QuartzCore/QuartzCore.h>


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
    self.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsFacebook | PFLogInFieldsLogInButton | PFLogInFieldsPasswordForgotten | PFLogInFieldsDismissButton;
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    

    //Set up View
    
    [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"MainBG.png"]]];
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo.png"]]];
    
    // Set buttons appearance
//    [self.logInView.dismissButton setHidden:YES];
    [self.logInView.dismissButton setImage:[UIImage imageNamed:@"Exit.png"] forState:UIControlStateNormal];
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
    
    float btnWidth = 120.0f;
    float btnHeight = 38.0f;
    
    [self.logInView.dismissButton setFrame:CGRectMake(0.0f, 15.0f, 87.5f, 45.5f)];
    
    [self.logInView.logo setFrame:CGRectMake(66.5f, 70.0f, 187.0f, 58.5f)];
    
    [self.logInView.facebookButton setFrame:CGRectMake(column1, row2, btnWidth, btnHeight)];
    [self.logInView.passwordForgottenButton setFrame:CGRectMake(column2, row2, btnWidth, btnHeight)];
    
    [self.logInView.logInButton setFrame:CGRectMake(column1/2+column2/2, row1, btnWidth, btnHeight)];
    //Clear LogInButton Title
    [self.logInView.logInButton setTitle:@"" forState:UIControlStateNormal];
    [self.logInView.logInButton setTitle:@"" forState:UIControlStateHighlighted];
    
    [self.logInView.signUpButton setFrame:CGRectMake(column2, row1, btnWidth, btnHeight)];

    
    [self.logInView.usernameField setFrame:CGRectMake(column1, rowField, 250.0f, 50.0f)];
    [self.logInView.passwordField setFrame:CGRectMake(column1, rowField+50.0f, 250.0f, 50.0f)];
    [self.fieldsBackground setFrame:CGRectMake(column1, rowField, 250.0f, 100.0f)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



@end
