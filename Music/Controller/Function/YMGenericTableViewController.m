//
//  YMGenericTableViewController.m
//  Beet
//
//  Created by Yuhua Mai on 12/9/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "YMGenericTableViewController.h"
#import "YMGenericTableViewCell.h"

#import "UIViewController+MMDrawerController.h"

#import "SampleMusicViewController.h"
#import "MMNavigationController.h"
#import "MMDrawerBarButtonItem.h"

@interface YMGenericTableViewController ()

@property (assign, nonatomic) CATransform3D initialTransformation;
@property (nonatomic, strong) NSMutableSet *shownIndexes;

@end

@implementation YMGenericTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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

    //View Setup
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _shownIndexes = [NSMutableSet set];
    
    CGFloat rotationAngleDegrees = -15;
    CGFloat rotationAngleRadians = rotationAngleDegrees * (M_PI/180);
    CGPoint offsetPositioning = CGPointMake(-20, -20);
    
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DRotate(transform, rotationAngleRadians, 0.0, 0.0, 1.0);
    transform = CATransform3DTranslate(transform, offsetPositioning.x, offsetPositioning.y, 0.0);
    _initialTransformation = transform;
    
    [self.tableView registerClass:[YMGenericTableViewCell class] forCellReuseIdentifier:@"Cell"];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SampleMusicViewController *controller = [[UIStoryboard storyboardWithName:SAMPLEMUSIC_STORYBOARD_NAME bundle:nil] instantiateViewControllerWithIdentifier:SAMPLEMUSIC_CONTROLLER_NAME];
    controller.pfObject = [self.PFObjects objectAtIndex:indexPath.row];
    controller.delegate = self;
    
    MMNavigationController *navigationController = [[MMNavigationController alloc] initWithRootViewController:controller];
    
    [self.mm_drawerController setCenterViewController:navigationController withFullCloseAnimation:YES completion:nil];
    
    //Set view
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.layer.opacity = 0.7;

//    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];

////    cell.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.0];
//    UIView *whiteRoundedCornerView = [[UIView alloc] initWithFrame:CGRectMake(10,10,300,60)];
//    whiteRoundedCornerView.backgroundColor = [UIColor whiteColor];
//    whiteRoundedCornerView.layer.masksToBounds = NO;
//    whiteRoundedCornerView.layer.cornerRadius = 3.0;
//    whiteRoundedCornerView.layer.shadowOffset = CGSizeMake(-1, 1);
//    whiteRoundedCornerView.layer.shadowOpacity = 0.5;
//    [cell.contentView addSubview:whiteRoundedCornerView];
//    [cell.contentView sendSubviewToBack:whiteRoundedCornerView];
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.layer.opacity = 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.shownIndexes containsObject:indexPath]) {
        [self.shownIndexes addObject:indexPath];
        
        UIView *card = cell;//[(CTCardCell* )cell mainView];
        
        card.layer.transform = self.initialTransformation;
        card.layer.opacity = 0.8;
        
        [UIView animateWithDuration:0.4 animations:^{
            card.layer.transform = CATransform3DIdentity;
            card.layer.opacity = 1;
        }];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"Cell";
    YMGenericTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject *song = [self.PFObjects objectAtIndex:indexPath.row];
    NSDictionary *dictionary;
    
    if ([song objectForKey:@"author"]) {
        dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[song objectForKey:@"title"], @"title", [song objectForKey:@"album"], @"album", [song objectForKey:@"artist"], @"artist", [song objectForKey:@"author"], @"author", nil];
        
    }else{
        dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[song objectForKey:@"title"], @"title", [song objectForKey:@"album"], @"album", [song objectForKey:@"artist"], @"artist", nil];
    }
    
    [cell setupWithDictionary:dictionary];
    
    return cell;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark - Button Handlers
-(void)setupLeftMenuButton{
	MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
	[self.mm_drawerController.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
    [self.mm_drawerController.navigationItem setRightBarButtonItem:nil];
}

-(void)leftDrawerButtonPress:(id)sender{
	[self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

@end
