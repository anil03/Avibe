//
//  AddFriendsViewController.m
//  Beet
//
//  Created by Yuhua Mai on 12/27/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//
// UITableViewController

#import "FindFriendsViewController.h"

#import "FriendsViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "BackgroundImageView.h"
#import "FindFriendTableViewCell.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

enum FindFriendTableViewSection {
    RegisteredUserSection = 0,
    UnRegisteredUserSection = 1
};

@interface FindFriendsViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *contactList;
@property (nonatomic, strong) NSMutableArray *registeredFollowingUsers;
@property (nonatomic, strong) NSMutableArray *registeredNotFollowedUsers;
@property (nonatomic, strong) NSMutableArray *unRegisteredUsers;

@property (nonatomic, strong) UIAlertView *alertForUnFollow;
@property (nonatomic, strong) FindFriendButton *currentButtonSender;
@end

@implementation FindFriendsViewController

@synthesize contactList = _contactList;

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        [self.tableView registerClass:[FindFriendTableViewCell class] forCellReuseIdentifier:@"Cell"];
        [self.tableView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5]];
        
        //BackgroundView
        UIView *backgroundView = [[BackgroundImageView alloc] initWithFrame:self.tableView.frame];
        self.tableView.backgroundView = backgroundView;
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
	[self setupBarMenuButton];
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    _registeredFollowingUsers = [[NSMutableArray alloc] init];
    _registeredNotFollowedUsers = [[NSMutableArray alloc] init];
    _unRegisteredUsers = [[NSMutableArray alloc] init];
    
    [self searchAddressBook];
    [self searchDatabaseForRegisteredUser];
}

#pragma mark - Address Book
- (void)searchAddressBook
{
    //Address Book
    ABAddressBookRef addressBook = ABAddressBookCreate();
    __block BOOL accessGranted = NO;
    
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // We are on iOS 6
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }else { // We are on iOS 5 or Older
        accessGranted = YES;
        [self getContactsWithAddressBook:addressBook];
    }
    
    if (accessGranted) {
        [self getContactsWithAddressBook:addressBook];
    }
}


// Get the contacts.
- (void)getContactsWithAddressBook:(ABAddressBookRef )addressBook {
    
    _contactList = [[NSMutableArray alloc] init];
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex peopleNumber = ABAddressBookGetPersonCount(addressBook);
    
    for (int i=0;i < peopleNumber;i++) {
        NSMutableDictionary *person= [NSMutableDictionary dictionary];
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
        
        //For username and surname
        CFStringRef firstName, lastName;
        firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
        if (firstName != nil && lastName != nil) {
            [person setObject:[NSString stringWithFormat:@"%@ %@", firstName, lastName] forKey:kClassContactUsername];
        }else if (firstName != nil){
            [person setObject:[NSString stringWithFormat:@"%@", firstName] forKey:kClassContactUsername];
        }else if (lastName != nil){
            [person setObject:[NSString stringWithFormat:@"%@", lastName] forKey:kClassContactUsername];
        }
        
        //For Email ids
        ABMutableMultiValueRef eMail  = ABRecordCopyValue(ref, kABPersonEmailProperty);
        NSMutableArray *emailArray = [[NSMutableArray alloc] init];
        for(CFIndex i = 0; i < ABMultiValueGetCount(eMail); i++) {
            NSString *currentEmail = (__bridge NSString*)ABMultiValueCopyValueAtIndex(eMail, i);
            [emailArray addObject:currentEmail];
        }
        [person setObject:emailArray forKey:kClassContactEmail];
        
        //For Phone number
        ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
        NSString* mobileLabel;
        NSMutableArray *phoneNumberArray = [[NSMutableArray alloc] init];
        
        for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
            mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
            NSString *currentPhoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
            [phoneNumberArray addObject:currentPhoneNumber];
        }
        [person setObject:phoneNumberArray forKey:kClassContactPhoneNumber];
        
        //Finsih add to contactList
        [_contactList addObject:person];
        
    }
    NSLog(@"Contacts = %@",_contactList);
}

#pragma mark - Data Source
/*
 * Fetch from Parse.com to get all registered username
 * Compared user's contact list
 * Show registered and unregistered users in tableview
 */
- (void)searchDatabaseForRegisteredUser
{
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithTarget:self selector:@selector(handleUsernameInDatabase:error:)];
}
- (void)handleUsernameInDatabase:(NSArray *)result error:(NSError *)error
{
    if (!error) {
        for(NSMutableDictionary *person in _contactList){
            NSString *contactUsername = [person objectForKey:kClassContactUsername];
            NSArray *contactEmailArray = [person objectForKey:kClassContactEmail];
            NSArray *contactPhoneNumberArray = [person objectForKey:kClassContactPhoneNumber];
            
            
            //Cross Search For Contact List
            BOOL isRegistered = NO;
            for(PFObject *object in result){
                NSString *username = [object objectForKey:kClassUserUsername];
                NSString *email = [object objectForKey:kClassUserEmail];
                NSString *phoneNumber = [object objectForKey:kClassUserPhoneNumber];
            
                //Can't following myself
                if ([username isEqualToString:[[PFUser currentUser] username]]) {
                    continue;
                }
                
                if([contactEmailArray containsObject:email]) isRegistered = YES;
                if([contactPhoneNumberArray containsObject:phoneNumber]) isRegistered = YES;
                
                //Add username to the person if registered
                if(isRegistered){
                   [person setObject:username forKey:kClassUserUsername];
                    break;
                }
            }
            
            /**
             * Add to registered/unregistered and remove current entry
             */
            if(isRegistered){
                [_registeredNotFollowedUsers addObject:person];
            }else{
                [_unRegisteredUsers addObject:person];
            }
        }
        [self handleRegisteredUserInFriendList];
//        [self.tableView reloadData];

    }else{
        //Handle Error Fetching User List from Parse.com
        NSLog(@"Error:%@", error);
    }
    
}

- (void)handleRegisteredUserInFriendList
{
    PFQuery *friendQuery = [PFQuery queryWithClassName:kClassFriend];
    [friendQuery whereKey:kClassFriendFromUsername equalTo:[[PFUser currentUser] username]];
    [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            for(NSMutableDictionary *person in _registeredNotFollowedUsers){
                NSString *username = [person objectForKey:kClassUserUsername];
                
                BOOL isFriend = NO;
                for(PFObject *object in objects){
                    NSString *friendUsername = [object objectForKey:kClassFriendToUsername];
                    NSString *objectId = [object objectId];
                    //Save ObjectId
                    [person setObject:objectId forKey:kClassFriendObjectId];
                    
                    if([username isEqualToString:friendUsername]){
                        isFriend = YES;
                        break;
                    }
                }
                
                if(isFriend){
                    [_registeredFollowingUsers addObject:person];
                    [_registeredNotFollowedUsers removeObject:person];
                }
            }
            [self.tableView reloadData];
        }else{
            NSLog(@"Error:%@", error);
        }
    }];
}

#pragma mark - TableView method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case RegisteredUserSection:
            return @"Registered Users";
        case UnRegisteredUserSection:
            return @"UnRegistered Users";
        default:
            return nil;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case RegisteredUserSection:
            return [_registeredFollowingUsers count]+[_registeredNotFollowedUsers count];
            break;
        case UnRegisteredUserSection:
            return [_unRegisteredUsers count];
            break;
        default:
            return 0;
            break;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FindFriendTableViewCell *cell = [[FindFriendTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    [cell setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.detailTextLabel setTextColor:[UIColor whiteColor]];
    
    switch (indexPath.section) {
        case RegisteredUserSection:
        {            
            int followingUsersNumber = [_registeredFollowingUsers count];
            NSMutableDictionary *person = nil;
            if(indexPath.row < followingUsersNumber){
                person = [_registeredFollowingUsers objectAtIndex:indexPath.row];
                [cell.followButton setTitle:@"Following" forState:UIControlStateNormal];
                [cell.followButton addTarget:self action:@selector(unFollowButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

            }else{
                person = [_registeredNotFollowedUsers objectAtIndex:indexPath.row-followingUsersNumber];
                [cell.followButton setTitle:@"Follow" forState:UIControlStateNormal];
                [cell.followButton addTarget:self action:@selector(followButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            }
            cell.textLabel.text = [person objectForKey:kClassContactUsername];
            cell.detailTextLabel.text = [person objectForKey:kClassUserUsername];
            cell.followButton.username = [person objectForKey:kClassUserUsername];
            cell.followButton.username_contact = [person objectForKey:kClassContactUsername];
            cell.followButton.email_contact = [person objectForKey:kClassContactEmail];
            cell.followButton.phoneNumber_contact = [person objectForKey:kClassContactPhoneNumber];
            cell.followButton.friendObjectId = [person objectForKey:kClassFriendObjectId];
            cell.followButton.person = person;
            break;
        }
        case UnRegisteredUserSection:
        {
            NSMutableDictionary *person = [_unRegisteredUsers objectAtIndex:indexPath.row];
            cell.textLabel.text = [person objectForKey:kClassContactUsername];
            cell.followButton.username_contact = [person objectForKey:kClassContactUsername];
            cell.followButton.email_contact = [person objectForKey:kClassContactEmail];
            cell.followButton.phoneNumber_contact = [person objectForKey:kClassContactPhoneNumber];
            
            [cell.followButton setTitle:@"Invite" forState:UIControlStateNormal];
            [cell.followButton setTitle:@"Invited" forState:UIControlStateSelected];
            [cell.followButton addTarget:self action:@selector(inviteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            break;
        }
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Follow Button Method
- (void)unFollowButtonPressed:(FindFriendButton*)sender
{
    _currentButtonSender = sender;
    
    _alertForUnFollow = [[UIAlertView alloc] initWithTitle: @"Warning" message: [NSString stringWithFormat:@"Are you sure to unFollowed %@?", sender.username_contact] delegate: self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
    [_alertForUnFollow show];
    
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView isEqual:_alertForUnFollow] && buttonIndex == 0) {
        PFQuery *unFriend = [PFQuery queryWithClassName:kClassFriend];
        [unFriend getObjectInBackgroundWithId:_currentButtonSender.friendObjectId block:^(PFObject *object, NSError *error) {
            if (object) {
                [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        [_registeredNotFollowedUsers addObject:_currentButtonSender.person];
                        [_registeredFollowingUsers removeObject:_currentButtonSender.person];
                        [self.tableView reloadData];
                        
                        [[[UIAlertView alloc] initWithTitle: @"Success" message: [NSString stringWithFormat:@"You have unFollowed %@.", _currentButtonSender.username_contact] delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                        
                    }
                }];
            }
        }];
    }
}
- (void)followButtonPressed:(FindFriendButton*)sender

{
    PFObject *friend = [PFObject objectWithClassName:kClassFriend];
    [friend setObject:[[PFUser currentUser] username] forKey:kClassFriendFromUsername];
    [friend setObject:sender.username forKey:kClassFriendToUsername];
    [friend saveEventually:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [_registeredFollowingUsers addObject:sender.person];
            [_registeredNotFollowedUsers removeObject:sender.person];
            [self.tableView reloadData];
            
            [[[UIAlertView alloc] initWithTitle: @"Success" message: [NSString stringWithFormat:@"You have followed %@.", sender.username_contact] delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}
- (void)inviteButtonPressed:(FindFriendButton*)sender
{
    NSLog(@"Invite %@", sender.username_contact);
}

#pragma mark - BarMenuButton
-(void)setupBarMenuButton{
    //Navigation Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = @"Find Friends";
    titleLabel.textColor = [UIColor colorWithRed:3.0/255.0
                                           green:49.0/255.0
                                            blue:107.0/255.0
                                           alpha:1.0];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [titleLabel sizeToFit];
    self.mm_drawerController.navigationItem.titleView = titleLabel;
    
    UIBarButtonItem * leftDrawerButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    self.mm_drawerController.navigationItem.leftBarButtonItem = leftDrawerButton;
    
    UIBarButtonItem * rightDrawerButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(popCurrentView)];    
    [self.mm_drawerController.navigationItem setRightBarButtonItem:rightDrawerButton];
}
-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}
- (void)popCurrentView
{
    [self.mm_drawerController setCenterViewController:self.friendsViewController];
}

@end
