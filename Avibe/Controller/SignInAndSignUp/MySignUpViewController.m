//
//  MySignUpViewController.m
//  LogInAndSignUpDemo
//
//  Created by Mattieu Gamache-Asselin on 6/15/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "MySignUpViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "BackgroundImageView.h"

@interface MySignUpViewController ()
@property (nonatomic, strong) UIImageView *fieldsBackground;
@property UITextField *fullnameTextField;
@end

@implementation MySignUpViewController

@synthesize fieldsBackground;
@synthesize fullnameTextField;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

//    self.fields = PFSignUpFieldsUsernameAndPassword;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    //Variables
    float width = [[UIScreen mainScreen] bounds].size.width;
    float height = [[UIScreen mainScreen] bounds].size.height;
    float fieldWidth = width;
    float fieldHeight = 40.0f;
    float buttonWidth = width/2;
    float buttonHeight = fieldHeight;
    float currentHeight = 0.0f;
    
    buttonHeight = 20.0f;
    float bottom = 35.0f;
    float fontsize = 14.0f;
    
    //Background Logo
//    UIImage *image = [UIImage imageNamed:@"background.png"];
//    [self.signUpView setBackgroundColor:[UIColor colorWithPatternImage:image]];
    [self.signUpView setBackgroundColor:[UIColor clearColor]];

    //BackgroundImageView
    UIView *backgroundView = [[BackgroundImageView alloc] initWithFrame:self.view.frame];
    [self.signUpView addSubview:backgroundView];
    [self.signUpView sendSubviewToBack:backgroundView];
    
    //Avibe Label
    float labelWidth = 200.0f;
    float labelHeight = 50.0f;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(width/2-labelWidth/2, 60.0f, labelWidth, labelHeight)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"Avibe";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:56.0f];
    [self.view addSubview:label];
    self.signUpView.logo = label;

  
    
    //Input Field - Username
    currentHeight = fieldHeight*2 + 70.0f;
    UIColor *fieldBackgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
    UIColor *placeHolderColor = [UIColor grayColor];
    [self.signUpView.usernameField setFrame:CGRectMake(0, currentHeight, fieldWidth, fieldHeight)];
    [self.signUpView.usernameField setBackgroundColor:fieldBackgroundColor];
    [self.signUpView.usernameField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: placeHolderColor}]];

    //Full Name
//    currentHeight += fieldHeight;
//    fullnameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, currentHeight, fieldWidth, fieldHeight)];
//    [fullnameTextField setTextAlignment:NSTextAlignmentCenter];
//    [fullnameTextField setBackgroundColor:[UIColor clearColor]];
//    [fullnameTextField setTextColor:[UIColor whiteColor]];
//    [fullnameTextField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Full Name" attributes:@{NSForegroundColorAttributeName: placeHolderColor}]];
//    [self.view addSubview:fullnameTextField];
    
    //Email
    currentHeight += fieldHeight;
    [self.signUpView.emailField setFrame:CGRectMake(0, currentHeight, fieldWidth, fieldHeight)];
    [self.signUpView.emailField setBackgroundColor:fieldBackgroundColor];
    [self.signUpView.emailField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: placeHolderColor}]];

    //Password
    currentHeight += fieldHeight;
    [self.signUpView.passwordField setFrame:CGRectMake(0, currentHeight, fieldWidth, fieldHeight)];
    [self.signUpView.passwordField setBackgroundColor:fieldBackgroundColor];
    [self.signUpView.passwordField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: placeHolderColor}]];


    // Change "Additional" to match our use
    currentHeight += fieldHeight;
    [self.signUpView.additionalField setFrame:CGRectMake(0, currentHeight, fieldWidth, fieldHeight)];
    [self.signUpView.additionalField setBackgroundColor:fieldBackgroundColor];
    [self.signUpView.additionalField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Phone number" attributes:@{NSForegroundColorAttributeName: placeHolderColor}]];
    
    //Sign Up
    currentHeight += fieldHeight+10.0f;
    UIButton *signUpButton = self.signUpView.signUpButton;
    [signUpButton setFrame:CGRectMake(0, currentHeight, fieldWidth, fieldHeight)];
    [signUpButton setBackgroundColor:[UIColor clearColor]];
    [signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [signUpButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [signUpButton setImage:nil forState:UIControlStateNormal];
    [signUpButton setImage:nil forState:UIControlStateHighlighted];
    [signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [signUpButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [signUpButton setFrame:CGRectMake(0, currentHeight, width, fieldHeight)];
    
    //Dismiss
    currentHeight = height-buttonHeight-bottom;
    [self.signUpView.dismissButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [self.signUpView.dismissButton setBackgroundColor:[UIColor clearColor]];
    [self.signUpView.dismissButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.signUpView.dismissButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.signUpView.dismissButton setImage:nil forState:UIControlStateNormal];
    [self.signUpView.dismissButton setImage:nil forState:UIControlStateHighlighted];
    [self.signUpView.dismissButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.signUpView.dismissButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.signUpView.dismissButton setFrame:CGRectMake(0, currentHeight, width, fieldHeight)];
    [self.signUpView.dismissButton.titleLabel setFont:[UIFont systemFontOfSize:fontsize]];
}

//- (void)signUpUser
//{
//    PFUser *newUser = [PFUser user];
//    
//    NSString *username = self.signUpView.usernameField.text;
//    NSString *fullname = fullnameTextField.text;
//    NSString *password = self.signUpView.passwordField.text;
//    NSString *email = self.signUpView.emailField.text;
//    NSString *phonenumber = self.signUpView.additionalField.text;
//
//    BOOL authenicated = username && ![username isEqualToString:@""] &&
//                        fullname && ![fullname isEqualToString:@""] &&
//                        password && ![password isEqualToString:@""] &&
//                        email && ![email isEqualToString:@""] &&
//                        phonenumber && ![phonenumber isEqualToString:@""];
//    if (!authenicated) {
//        [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please fill in all fields." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//        return;
//    }
//    
//    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (succeeded) {
//            
//        }else{
//            NSLog(@"Error:%@",error.description);
//        }
//    }];
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
