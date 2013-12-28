//
//  AddFriendsViewController.m
//  Beet
//
//  Created by Yuhua Mai on 12/27/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "AddFriendsViewController.h"

#import "FriendsViewController.h"

#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>


@interface AddFriendsViewController ()

@property (nonatomic, strong) NSMutableArray *contactList;

@end

@implementation AddFriendsViewController

@synthesize contactList = _contactList;

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

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupBarMenuButton];
    
    [self searchAddressBook];

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
        ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
        
        CFStringRef firstName, lastName;
        firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
        [dOfPerson setObject:[NSString stringWithFormat:@"%@ %@", firstName, lastName] forKey:@"name"];
        
        //For Email ids
        ABMutableMultiValueRef eMail  = ABRecordCopyValue(ref, kABPersonEmailProperty);
        if(ABMultiValueGetCount(eMail) > 0) {
            [dOfPerson setObject:(__bridge NSString *)ABMultiValueCopyValueAtIndex(eMail, 0) forKey:@"email"];
            
        }
        
        //For Phone number
        NSString* mobileLabel;
        
        for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
            mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
            NSLog(@"Phone %@ at %d", (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i), i);
//            if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
//            {
//                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
//            }else if ([mobileLabel isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]){
//                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"iPhone"];
//            }else if ([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMainLabel]){
//                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Main"];
//            }
            
        }
        [_contactList addObject:dOfPerson];
        
    }
    NSLog(@"Contacts = %@",_contactList);
}

/*
 // All Personal Information Properties
 kABPersonFirstNameProperty;          // First name - kABStringPropertyType
 kABPersonLastNameProperty;           // Last name - kABStringPropertyType
 kABPersonMiddleNameProperty;         // Middle name - kABStringPropertyType
 kABPersonPrefixProperty;             // Prefix ("Sir" "Duke" "General") - kABStringPropertyType
 kABPersonSuffixProperty;             // Suffix ("Jr." "Sr." "III") - kABStringPropertyType
 kABPersonNicknameProperty;           // Nickname - kABStringPropertyType
 kABPersonFirstNamePhoneticProperty;  // First name Phonetic - kABStringPropertyType
 kABPersonLastNamePhoneticProperty;   // Last name Phonetic - kABStringPropertyType
 kABPersonMiddleNamePhoneticProperty; // Middle name Phonetic - kABStringPropertyType
 kABPersonOrganizationProperty;       // Company name - kABStringPropertyType
 kABPersonJobTitleProperty;           // Job Title - kABStringPropertyType
 kABPersonDepartmentProperty;         // Department name - kABStringPropertyType
 kABPersonEmailProperty;              // Email(s) - kABMultiStringPropertyType
 kABPersonBirthdayProperty;           // Birthday associated with this person - kABDateTimePropertyType
 kABPersonNoteProperty;               // Note - kABStringPropertyType
 kABPersonCreationDateProperty;       // Creation Date (when first saved)
 kABPersonModificationDateProperty;   // Last saved date
 
 // All Address Information Properties
 kABPersonAddressProperty;            // Street address - kABMultiDictionaryPropertyType
 kABPersonAddressStreetKey;
 kABPersonAddressCityKey;
 kABPersonAddressStateKey;
 kABPersonAddressZIPKey;
 kABPersonAddressCountryKey;
 kABPersonAddressCountryCodeKey;
 */

#pragma mark - TableView method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_contactList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    
    cell.textLabel.text = @"2";
    cell.detailTextLabel.text = @"3";
    
    return cell;
}


#pragma mark - BarMenuButton
-(void)setupBarMenuButton{
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
