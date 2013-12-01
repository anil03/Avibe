//
//  ViewController.m
//  AddCurrentMusicThenPlaySample
//
//  Created by Yuhua Mai on 11/24/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "TableViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <Parse/Parse.h>

#import "AppDelegate.h"
#import "SampleMusicViewController.h"
#import "Song.h"


@interface TableViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *CurrPlaying;

@property (nonatomic, strong) NSArray *songs;


@end

@implementation TableViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize songs = _songs;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];

//    [self fetechData];
    [self refreshCoreData:nil];
}


#pragma mark Core Data
- (void)fetechData
{
    //Fetech
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Song" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    _songs = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];

}

- (void) deleteAllObjects: (NSString *) entityDescription  {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items) {
    	[_managedObjectContext deleteObject:managedObject];
    	NSLog(@"%@ object deleted",entityDescription);
    }
    if (![_managedObjectContext save:&error]) {
    	NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
    }
    
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
    return [_songs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject *song = [_songs objectAtIndex:indexPath.row];
    cell.textLabel.text = [song objectForKey:@"title"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", [song objectForKey:@"title"], [song objectForKey:@"album"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self performSegueWithIdentifier:@"SampleMusicSegue" sender:[_songs objectAtIndex:indexPath.row]];
}

#pragma mark Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SampleMusicSegue"])
    {
        // Get reference to the destination view controller
        SampleMusicViewController *controller = [segue destinationViewController];
        controller.song = sender;
    }
}

#pragma mark Bar Button
- (IBAction)AddSong:(id)sender {
    MPMediaItem *currentPlayingSong = [[MPMusicPlayerController iPodMusicPlayer] nowPlayingItem];
    Song *song = [NSEntityDescription insertNewObjectForEntityForName:@"Song" inManagedObjectContext:_managedObjectContext];

    if (!currentPlayingSong) {
        //deal with nil, hardcode for demo
        song.title = @"Mirrors";
        song.album = @"The 20/20 Experience";
        song.artist = @"JustinTimberlake";
    }else{    
        song.title = [currentPlayingSong valueForProperty:MPMediaItemPropertyTitle];;
        song.album = [currentPlayingSong valueForProperty:MPMediaItemPropertyAlbumTitle];
        song.artist = [currentPlayingSong valueForProperty:MPMediaItemPropertyArtist];
        
        NSError *error;
        if (![_managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
    
    PFObject *songRecord = [PFObject objectWithClassName:@"Song"];
    [songRecord setObject:song.title forKey:@"title"];
    [songRecord setObject:song.album forKey:@"album"];
    [songRecord setObject:song.artist forKey:@"artist"];
    [songRecord setObject:[PFUser currentUser] forKey:@"author"];
    [songRecord save];
    
//    [self fetechData];
    [self refreshCoreData:nil];
    [self.tableView reloadData];
    
}

- (IBAction)refreshCoreData:(id)sender {
//    [self deleteAllObjects:@"Song"];
//    _songs = nil;
    
    //Create query for all Post object by the current user
    PFQuery *postQuery = [PFQuery queryWithClassName:@"Song"];
    [postQuery whereKey:@"author" equalTo:[PFUser currentUser]];
    
    // Run the query
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //Save results and update the table
            _songs = objects;
            [self.tableView reloadData];
        }
    }];
}

@end
