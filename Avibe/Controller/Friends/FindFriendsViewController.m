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

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

enum FindFriendTableViewSection {
    RegisteredUserSection = 0,
    UnRegisteredUserSection = 1
};

@interface FindFriendsViewController ()

@property (nonatomic, strong) NSMutableArray *contactList;
@property (nonatomic, strong) NSMutableArray *registeredUsers;
@property (nonatomic, strong) NSMutableArray *unRegisteredUsers;

@end

@implementation FindFriendsViewController

@synthesize contactList = _contactList;

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
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

    _registeredUsers = [[NSMutableArray alloc] init];
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
            [person setObject:[NSString stringWithFormat:@"%@ %@", firstName, lastName] forKey:kClassUserUsername];
        }else if (firstName != nil){
            [person setObject:[NSString stringWithFormat:@"%@", firstName] forKey:kClassUserUsername];
        }else if (lastName != nil){
            [person setObject:[NSString stringWithFormat:@"%@", lastName] forKey:kClassUserUsername];
        }
        
        //For Email ids
        ABMutableMultiValueRef eMail  = ABRecordCopyValue(ref, kABPersonEmailProperty);
        NSMutableArray *emailArray = [[NSMutableArray alloc] init];
        for(CFIndex i = 0; i < ABMultiValueGetCount(eMail); i++) {
            NSString *currentEmail = (__bridge NSString*)ABMultiValueCopyValueAtIndex(eMail, i);
            [emailArray addObject:currentEmail];
        }
        [person setObject:emailArray forKey:kClassUserEmail];
        
        //For Phone number
        ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
        NSString* mobileLabel;
        NSMutableArray *phoneNumberArray = [[NSMutableArray alloc] init];
        
        for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
            mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
            NSString *currentPhoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
            [phoneNumberArray addObject:currentPhoneNumber];
        }
        [person setObject:phoneNumberArray forKey:kClassUserPhoneNumber];
        
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
            NSString *contactUsername = [person objectForKey:kClassUserUsername];
            NSArray *contactEmailArray = [person objectForKey:kClassUserEmail];
            NSArray *contactPhoneNumberArray = [person objectForKey:kClassUserPhoneNumber];
            
            
            //Cross Search For Contact List
            BOOL isRegistered = NO;
            for(PFObject *object in result){
                NSString *username = [object objectForKey:kClassUserUsername];
                NSString *email = [object objectForKey:kClassUserEmail];
                NSString *phoneNumber = [object objectForKey:kClassUserPhoneNumber];
            
                if([contactEmailArray containsObject:email]) isRegistered = YES;
                if([contactPhoneNumberArray containsObject:phoneNumber]) isRegistered = YES;
            }
            
            /**
             * Add to registered/unregistered and remove current entry
             */
            if(isRegistered){
                [_registeredUsers addObject:person];
            }else{
                [_unRegisteredUsers addObject:person];
            }
        }
        [self.tableView reloadData];
    }else{
        //Handle Error Fetching User List from Parse.com
        NSLog(@"Error:%@", error);
    }
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
            return [_registeredUsers count];
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
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    [cell setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.detailTextLabel setTextColor:[UIColor whiteColor]];
    
    
    switch (indexPath.section) {
        case RegisteredUserSection:
        {
            NSMutableDictionary *person = [_registeredUsers objectAtIndex:indexPath.row];
            cell.textLabel.text = [person objectForKey:kClassUserUsername];
            break;
        }
        case UnRegisteredUserSection:
        {
            NSMutableDictionary *person = [_unRegisteredUsers objectAtIndex:indexPath.row];
            cell.textLabel.text = [person objectForKey:kClassUserUsername];
            break;
        }
        default:
            break;
    }
    
    return cell;
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
