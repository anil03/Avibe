//
//  ViewController.m
//  AddCurrentMusicThenPlaySample
//
//  Created by Yuhua Mai on 11/24/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "TableViewController.h"
#import <MediaPlayer/MediaPlayer.h>

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
 
    [self fetechData];
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
    Song *song = [_songs objectAtIndex:indexPath.row];
    cell.textLabel.text = song.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", song.album, song.artist];
    
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
        //deal with nil
        song.title = @"Sample Title";
        song.album = @"Sample Album";
        song.artist = @"Sample Artist";
    }else{    
        song.title = [currentPlayingSong valueForProperty:MPMediaItemPropertyTitle];;
        song.album = [currentPlayingSong valueForProperty:MPMediaItemPropertyAlbumTitle];
        song.artist = [currentPlayingSong valueForProperty:MPMediaItemPropertyArtist];
        
        NSError *error;
        if (![_managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
    
    [self fetechData];
    [self.tableView reloadData];
    
}

- (IBAction)ClearCoreData:(id)sender {
    [self deleteAllObjects:@"Song"];
    _songs = nil;
    [self.tableView reloadData];
}

@end
