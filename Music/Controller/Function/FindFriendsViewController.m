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

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>


@interface FindFriendsViewController ()

@property (nonatomic, strong) NSMutableArray *contactList;
@property (nonatomic, strong) NSMutableArray *registeredUsers;
@property (nonatomic, strong) NSMutableArray *unRegisteredUsers;

@end

@implementation FindFriendsViewController

@synthesize contactList = _contactList;

- (void)viewDidLoad
{
    [super viewDidLoad];

    _registeredUsers = [[NSMutableArray alloc] init];
    _unRegisteredUsers = [[NSMutableArray alloc] init];
    
    [self setupBarMenuButton];
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
    }
    
    else { // We are on iOS 5 or Older
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
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    for (int i=0;i < nPeople;i++) {
        NSMutableDictionary *dOfPerson=[NSMutableDictionary dictionary];
        
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
        
        //For username and surname
        
        
        CFStringRef firstName, lastName;
        firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
        
        if (firstName != nil && lastName != nil) {
            [dOfPerson setObject:[NSString stringWithFormat:@"%@ %@", firstName, lastName] forKey:@"name"];
        }else if (firstName != nil){
            [dOfPerson setObject:[NSString stringWithFormat:@"%@", firstName] forKey:@"name"];
        }else if (lastName != nil){
            [dOfPerson setObject:[NSString stringWithFormat:@"%@", lastName] forKey:@"name"];
        }
        
        //For Email ids
//        ABMutableMultiValueRef eMail  = ABRecordCopyValue(ref, kABPersonEmailProperty);
//        if(ABMultiValueGetCount(eMail) > 0) {
//            [dOfPerson setObject:(__bridge NSString *)ABMultiValueCopyValueAtIndex(eMail, 0) forKey:@"email"];
//        }
        
        //For Phone number
        ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
        NSString* mobileLabel;
        NSString* phoneNumber = @"";
        
        for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
            mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
            NSString *currentPhoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
//            NSLog(@"Phone %@ at %ld", (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i), i);
            phoneNumber = [[phoneNumber stringByAppendingString:currentPhoneNumber] stringByAppendingString:@" "];
            
//            if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
//            {
//            [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"phone"]; //Now just save one phone number

//            }else if ([mobileLabel isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]){
//                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"iPhone"];
//            }else if ([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMainLabel]){
//                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Main"];
//            }
            
        }
        [dOfPerson setObject:phoneNumber forKey:@"phone"];
        
        [_contactList addObject:dOfPerson];
        
    }
    NSLog(@"Contacts = %@",_contactList);
}


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
        
    }else{
        //Handle Error Fetching User List from Parse.com
    }
}

#pragma mark - TableView method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [_registeredUsers count];
            break;
        case 1:
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
    
    NSMutableDictionary *dictionary = [_contactList objectAtIndex:indexPath.row];
    cell.textLabel.text = [dictionary objectForKey:@"name"];
    cell.detailTextLabel.text = [dictionary objectForKey:@"phone"];
    
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
    
//    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    UIBarButtonItem * leftDrawerButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    self.mm_drawerController.navigationItem.leftBarButtonItem = leftDrawerButton;
//    [self.mm_drawerController.navigationController.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
    UIBarButtonItem * rightDrawerButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(popCurrentView)];    
    [self.mm_drawerController.navigationItem setRightBarButtonItem:rightDrawerButton];
}

-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)popCurrentView
{
    [self.mm_drawerController setCenterViewController:self.friendsViewController];
//    [self.mm_drawerController.navigationController popViewControllerAnimated:YES];
}

@end
