//
//  UserViewController.m
//  Beet
//
//  Created by Yuhua Mai on 12/7/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//
// CustomViewController

#import "UserViewController.h"

#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"

#import "Setting.h"

@interface UserViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *numberOfSongs;
@property (weak, nonatomic) IBOutlet UITextField *lastFMAccountInput;

@end

@implementation UserViewController

- (void)viewWillAppear:(BOOL)animated
{
	[self setupMenuButton];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //View Parameters
    float width = [[UIScreen mainScreen] bounds].size.width;
    float height = [[UIScreen mainScreen] bounds].size.height;
    float barHeight = 50.0f;
    float currentHeight = 0.0f;

    //Set up View
    self.view.backgroundColor = [[Setting sharedSetting] sharedBackgroundColor];
    
    currentHeight += barHeight;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, currentHeight, width, 50)];
    label.text = @"Profile";
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor blueColor];
    [self.view addSubview:label];
    [self.view bringSubviewToFront:label];
    
    currentHeight += 50;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, currentHeight, width, 30)];
    [button setTitle:@"button" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor redColor];
    [self.view addSubview:button];
    
    //Delegate
//    _lastFMAccountInput.delegate = self;
//
//    self.username.text = [[PFUser currentUser] username];
//    [self updateInfo];
//    
//    //Update textfield
//    if(self.delegate && [self.delegate respondsToSelector:@selector(getLastFMAccount)]){
//        _lastFMAccountInput.text = [self.delegate getLastFMAccount];
//    }
    
    
    
 

}

- (void)updateInfo{
    PFQuery *postQuery = [PFQuery queryWithClassName:@"Song"];
    [postQuery whereKey:@"user" equalTo:[[PFUser currentUser] username]];
    // Run the query
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.numberOfSongs.text = [NSString stringWithFormat:@"Own: %lu songs.", (unsigned long)[objects count]];
        }
    }];
}

#pragma mark - Button Handlers
-(void)setupMenuButton{
    //Navigation Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = @"Profile";
    titleLabel.textColor = [UIColor colorWithRed:3.0/255.0
                                           green:49.0/255.0
                                            blue:107.0/255.0
                                           alpha:1.0];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [titleLabel sizeToFit];
    self.mm_drawerController.navigationItem.titleView = titleLabel;
    
    
	MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
	[self.mm_drawerController.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
    [self.mm_drawerController.navigationItem setRightBarButtonItem:nil];
}

-(void)leftDrawerButtonPress:(id)sender{
	[self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

#pragma mark - Call UserViewController Delegate
- (void)callUserViewController:(NSString*)input
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(setLastFMAccount:)]){
        [self.delegate setLastFMAccount:input];
    }
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //hide the keyboard
    [self callUserViewController:textField.text];
    [textField resignFirstResponder];
    
    //return NO or YES, it doesn't matter
    return YES;
}

#pragma mark - Touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UIView * txt in self.view.subviews){
        if ([txt isKindOfClass:[UITextField class]] && [txt isFirstResponder]) {
            UITextField *textField = (UITextField*)txt;
            [self callUserViewController:textField.text];
            [txt resignFirstResponder];
        }
    }
}

@end
