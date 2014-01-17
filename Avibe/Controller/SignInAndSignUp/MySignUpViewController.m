//
//  MySignUpViewController.m
//  LogInAndSignUpDemo
//
//  Created by Mattieu Gamache-Asselin on 6/15/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "MySignUpViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface MySignUpViewController ()
@property (nonatomic, strong) UIImageView *fieldsBackground;
@end

@implementation MySignUpViewController

@synthesize fieldsBackground;

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self.signUpView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"MainBG.png"]]];
//    [self.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo.png"]]];
//    
//    // Change button apperance
//    [self.signUpView.dismissButton setImage:[UIImage imageNamed:@"Exit.png"] forState:UIControlStateNormal];
////    [self.signUpView.dismissButton setImage:[UIImage imageNamed:@"ExitDown.png"] forState:UIControlStateHighlighted];
//    
//    [self.signUpView.signUpButton setBackgroundImage:[UIImage imageNamed:@"SignUp.png"] forState:UIControlStateNormal];
//    [self.signUpView.signUpButton setBackgroundImage:[UIImage imageNamed:@"SignUpDown.png"] forState:UIControlStateHighlighted];
//    [self.signUpView.signUpButton setTitle:@"" forState:UIControlStateNormal];
//    [self.signUpView.signUpButton setTitle:@"" forState:UIControlStateHighlighted];
//    
//    // Add background for fields
//    [self setFieldsBackground:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SignUpFieldBG.png"]]];
//    [self.signUpView insertSubview:fieldsBackground atIndex:1];
//    
//    // Remove text shadow
//    CALayer *layer = self.signUpView.usernameField.layer;
//    layer.shadowOpacity = 0.0f;
//    layer = self.signUpView.passwordField.layer;
//    layer.shadowOpacity = 0.0f;
//    layer = self.signUpView.emailField.layer;
//    layer.shadowOpacity = 0.0f;
//    layer = self.signUpView.additionalField.layer;
//    layer.shadowOpacity = 0.0f;
//    
//    // Set text color
//    [self.signUpView.usernameField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
//    [self.signUpView.passwordField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
//    [self.signUpView.emailField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
//    [self.signUpView.additionalField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    

    
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
    UIImage *image = [UIImage imageNamed:@"background.png"];
    [self.signUpView setBackgroundColor:[UIColor colorWithPatternImage:image]];
    
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

    //Input Field
    currentHeight = fieldHeight*2 + 70.0f;
    UIColor *fieldBackgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
    UIColor *placeHolderColor = [UIColor grayColor];
    [self.signUpView.usernameField setFrame:CGRectMake(0, currentHeight, fieldWidth, fieldHeight)];
    [self.signUpView.usernameField setBackgroundColor:fieldBackgroundColor];
    [self.signUpView.usernameField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: placeHolderColor}]];

    currentHeight += fieldHeight;
    [self.signUpView.emailField setFrame:CGRectMake(0, currentHeight, fieldWidth, fieldHeight)];
    [self.signUpView.emailField setBackgroundColor:fieldBackgroundColor];
    [self.signUpView.emailField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: placeHolderColor}]];

    
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
    [self.signUpView.signUpButton setBackgroundColor:[UIColor clearColor]];
    [self.signUpView.signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [self.signUpView.signUpButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.signUpView.signUpButton setImage:nil forState:UIControlStateNormal];
    [self.signUpView.signUpButton setImage:nil forState:UIControlStateHighlighted];
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.signUpView.signUpButton setFrame:CGRectMake(0, currentHeight, width, fieldHeight)];

    
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
    
    
//    
//    
//    
//    // Move all fields down on smaller screen sizes
//    float yOffset = [UIScreen mainScreen].bounds.size.height <= 480.0f ? 30.0f : 0.0f;
//
//    CGRect fieldFrame = self.signUpView.usernameField.frame;
//
//    [self.signUpView.dismissButton setFrame:CGRectMake(0.0f, 15.0f, 87.5f, 45.5f)];
//    [self.signUpView.logo setFrame:CGRectMake(66.5f, 70.0f, 187.0f, 58.5f)];
//    [self.signUpView.signUpButton setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-60.0f, 385.0f, 120.0f, 40.0f)];
//    
//    [self.fieldsBackground setFrame:CGRectMake(35.0f, fieldFrame.origin.y + yOffset, 250.0f, 174.0f)];
//    
//    [self.signUpView.usernameField setFrame:CGRectMake(fieldFrame.origin.x + 5.0f,
//                                                       fieldFrame.origin.y + yOffset,
//                                                       fieldFrame.size.width - 10.0f,
//                                                       fieldFrame.size.height)];
//    yOffset += fieldFrame.size.height;
//    
//    [self.signUpView.passwordField setFrame:CGRectMake(fieldFrame.origin.x + 5.0f,
//                                                       fieldFrame.origin.y + yOffset,
//                                                       fieldFrame.size.width - 10.0f,
//                                                       fieldFrame.size.height)];
//    yOffset += fieldFrame.size.height;
//    
//    [self.signUpView.emailField setFrame:CGRectMake(fieldFrame.origin.x + 5.0f,
//                                                    fieldFrame.origin.y + yOffset,
//                                                    fieldFrame.size.width - 10.0f,
//                                                    fieldFrame.size.height)];
//    yOffset += fieldFrame.size.height;
//    
//    [self.signUpView.additionalField setFrame:CGRectMake(fieldFrame.origin.x + 5.0f,
//                                                         fieldFrame.origin.y + yOffset,
//                                                         fieldFrame.size.width - 10.0f,
//                                                         fieldFrame.size.height)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
