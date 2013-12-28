//
//  FriendsViewController.m
//  Beet
//
//  Created by Yuhua Mai on 12/7/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "FriendsViewController.h"

#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"

#import "MMNavigationController.h"

#import "SampleMusicViewController.h"

#import "AddFriendsViewController.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface FriendsViewController ()

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSArray *friends;

@end

@implementation FriendsViewController

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
    
	[self setupRefreshControl];
    [self refreshView:self.refreshControl];
}

#pragma mark Bar Button
- (IBAction)addFriend:(id)sender {
   PFObject *songRecord = [PFObject objectWithClassName:@"Friend"];
    [songRecord setObject:[[PFUser currentUser] username] forKey:@"user"];
    [songRecord setObject:@"myhgew3" forKey:@"friend"];
    [songRecord saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Save Friends Succeed!");
        }
    }];
    
    [self.tableView reloadData];
    [self refreshView:self.refreshControl];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject *friend = [self.friends objectAtIndex:indexPath.row];
    cell.textLabel.text = [friend objectForKey:@"friend"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    SampleMusicViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SampleMusicViewController"];
//    controller.pfObject = [self.friends objectAtIndex:indexPath.row];
//    //    controller.delegate = self;
//    
//    [self.mm_drawerController setCenterViewController:controller withFullCloseAnimation:YES completion:nil];
    
    //    [self performSegueWithIdentifier:@"SampleMusicSegue" sender:[_songs objectAtIndex:indexPath.row]];
}

#pragma mark - RefreshControl Method
- (void)setupRefreshControl
{
    // Inside a Table View Controller's viewDidLoad method
	UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
	refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
	[refresh addTarget:self
                action:@selector(refreshView:)
      forControlEvents:UIControlEventValueChanged];
	self.refreshControl = refresh;
    
    [self.refreshControl addTarget:self
                            action:@selector(refreshView:)
                  forControlEvents:UIControlEventValueChanged];
}


-(void)refreshView:(UIRefreshControl *)refresh {
	refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    
    // custom refresh logic would be placed here...
    [self fetchData:refresh];
    
    
}

-(void)fetchData:(UIRefreshControl*)refresh
{
    //Create query for all Post object by the current user
    PFQuery *postQuery = [PFQuery queryWithClassName:@"Friend"];
    [postQuery whereKey:@"user" equalTo:[[PFUser currentUser] username]];
    // Run the query
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //Save results and update the table
            self.friends = objects;
            [self.tableView reloadData];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMM d, h:mm a"];
            NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",[formatter stringFromDate:[NSDate date]]];
            refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
            [refresh endRefreshing];
        }
    }];
}



#pragma mark - Button Handlers
-(void)setupMenuButton{
	MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
	[self.mm_drawerController.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
    UIBarButtonItem * rightDrawerButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFriendButtonPress)];
    [self.mm_drawerController.navigationItem setRightBarButtonItem:rightDrawerButton];
}

-(void)leftDrawerButtonPress:(id)sender{
	[self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)addFriendButtonPress{
    //Add friend
    /*
    PFObject *friend = [PFObject objectWithClassName:@"Friend"];
//    BOOL friendNotExisted = YES;
    
    NSString *userToSave = [[PFUser currentUser] username];
    NSString *friendToSave = @"DemoFriend2";
    [friend setObject:userToSave forKey:@"user"];
    [friend setObject:friendToSave forKey:@"friend"];
    
    PFQuery *postQuery = [PFQuery queryWithClassName:@"Friend"];
    [postQuery whereKey:@"user" equalTo:userToSave];
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        //Fetch Objects
        for(PFObject *pf in objects){
            NSString *existingUser = [pf objectForKey:@"user"];
            NSString *existingFriend = [pf objectForKey:@"friend"];
            
            if ([existingUser isEqualToString:userToSave] && [existingFriend isEqualToString:friendToSave]) {
                NSLog(@"Duplicated friend");
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Sorry, the friend you add already exists" delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
                return;
            }
        }
        
        //No duplicate, save
        [friend saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Save Friend!");
                [self refreshView:self.refreshControl];
                [self.tableView reloadData];
            }else{
                NSLog(@"Erorr:%@", error);
            }
            
        }];
    }];
*/
    
    
    //Pop from bottom
    AddFriendsViewController *addFriendsViewController = [[AddFriendsViewController alloc] init];
//    MMNavigationController *navigationAddFriendsViewController = [[MMNavigationController alloc] initWithRootViewController:addFriendsViewController];
//    [self.mm_drawerController setCenterViewController:navigationAddFriendsViewController withFullCloseAnimation:YES completion:nil];
    [self.mm_drawerController.navigationController pushViewController:addFriendsViewController animated:YES];
//    [self presentViewController:navigationAddFriendsViewController animated:YES completion:nil];
    
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
    
    NSMutableArray *contactList = [[NSMutableArray alloc] init];
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
            if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
            {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
            }
            else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel])
            {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
                break ;
            }
            
        }
        [contactList addObject:dOfPerson];
        
    }
    NSLog(@"Contacts = %@",contactList);
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
 

@end

