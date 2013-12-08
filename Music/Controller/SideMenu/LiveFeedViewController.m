//
//  LiveFeedViewController.m
//  Beet
//
//  Created by Yuhua Mai on 12/7/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "LiveFeedViewController.h"

#import "MMExampleDrawerVisualStateManager.h"
#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "MMLogoView.h"
#import "MMCenterTableViewCell.h"
#import "MMExampleLeftSideDrawerViewController.h"
#import "MMExampleRightSideDrawerViewController.h"
#import "MMNavigationController.h"

#import <QuartzCore/QuartzCore.h>

#import <MediaPlayer/MediaPlayer.h>
#import <Parse/Parse.h>

#import "AppDelegate.h"
#import "SampleMusicViewController.h"
#import "Song.h"

#import "Cell.h"

typedef NS_ENUM(NSInteger, MMCenterViewControllerSection){
    MMCenterViewControllerSectionLeftViewState,
    MMCenterViewControllerSectionLeftDrawerAnimation,
    MMCenterViewControllerSectionRightViewState,
    MMCenterViewControllerSectionRightDrawerAnimation,
};

@interface LiveFeedViewController ()

@property (weak, atomic) UIViewController *viewController;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *CurrPlaying;

@property (nonatomic, strong) NSArray *songs;

@end

@implementation LiveFeedViewController

@synthesize songs = _songs;


- (id)initWithSelf:(UIViewController*)controller
{
    self.viewController = controller;
    return [self init];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setRestorationIdentifier:@"MMExampleCenterControllerRestorationKey"];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setupLeftMenuButton];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[Cell class] forCellReuseIdentifier:@"Cell"];
    
    [self refreshCoreData:nil];
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
    SampleMusicViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SampleMusicViewController"];
    controller.pfObject = [_songs objectAtIndex:indexPath.row];
    controller.delegate = self;
    
    [self.mm_drawerController setCenterViewController:controller withFullCloseAnimation:YES completion:nil];
    
//    [self performSegueWithIdentifier:@"SampleMusicSegue" sender:[_songs objectAtIndex:indexPath.row]];
}

#pragma mark Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SampleMusicSegue"])
    {
        // Get reference to the destination view controller
        SampleMusicViewController *controller = [segue destinationViewController];
        //        controller.song = [[Song alloc] init];
        controller.pfObject = sender;
        
        //        controller.song.title = [sender objectForKey:@"title"];
        //        controller.song.album = [sender objectForKey:@"album"];
        //        controller.song.artist = [sender objectForKey:@"artist"];
        
        
    }
}

#pragma mark Bar Button
- (IBAction)AddSong:(id)sender {
    MPMediaItem *currentPlayingSong = [[MPMusicPlayerController iPodMusicPlayer] nowPlayingItem];
    Song *song = [[Song alloc] init];
    
    if (!currentPlayingSong) {
        //deal with nil, hardcode for demo
        song.title = @"Mirrors";
        song.album = @"The 20/20 Experience";
        song.artist = @"JustinTimberlake";
    }else{
        song.title = [currentPlayingSong valueForProperty:MPMediaItemPropertyTitle];;
        song.album = [currentPlayingSong valueForProperty:MPMediaItemPropertyAlbumTitle];
        song.artist = [currentPlayingSong valueForProperty:MPMediaItemPropertyArtist];
        
        
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



#pragma mark - Button Handlers
-(void)setupLeftMenuButton{
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.mm_drawerController.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}

-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

@end