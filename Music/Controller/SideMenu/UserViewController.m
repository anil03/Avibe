//
//  UserViewController.m
//  Beet
//
//  Created by Yuhua Mai on 12/7/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "UserViewController.h"

#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"

@interface UserViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *numberOfSongs;
@property (weak, nonatomic) IBOutlet UITextField *lastFMAccountInput;

@end

@implementation UserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[self setupMenuButton];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _lastFMAccountInput.delegate = self;

    self.username.text = [[PFUser currentUser] username];
    [self updateInfo];
    
    //Update textfield
    if(self.delegate && [self.delegate respondsToSelector:@selector(getLastFMAccount)]){
        _lastFMAccountInput.text = [self.delegate getLastFMAccount];
    }

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
