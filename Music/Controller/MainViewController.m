//
//  LiveFeedViewController.m
//  Beet
//
//  Created by Yuhua Mai on 12/5/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "MainViewController.h"

#import "MMDrawerController.h"
#import "MMExampleCenterTableViewController.h"
#import "MMExampleLeftSideDrawerViewController.h"
#import "MMExampleRightSideDrawerViewController.h"
#import "MMDrawerVisualState.h"
#import "MMExampleDrawerVisualStateManager.h"
#import "MMNavigationController.h"

#import "MMDrawerBarButtonItem.h"

#import "SideMenuViewController.h"
#import "LiveFeedViewController.h"

#import <QuartzCore/QuartzCore.h>

@interface MainViewController ()

//@property (weak, nonatomic) UIViewController *centerViewController;

@end

@implementation MainViewController

//@synthesize centerViewController;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    UIViewController * leftSideDrawerViewController = [[SideMenuViewController alloc] init];
    UIViewController *centerViewController = [[LiveFeedViewController alloc] init];
   
    UINavigationController * navigationController = [[MMNavigationController alloc] initWithRootViewController:centerViewController];
    [navigationController setRestorationIdentifier:@"MMExampleCenterNavigationControllerRestorationKey"];
    
    
    if(OSVersionIsAtLeastiOS7()){
        UINavigationController * leftSideNavController = [[MMNavigationController alloc] initWithRootViewController:leftSideDrawerViewController];
		[leftSideNavController setRestorationIdentifier:@"MMExampleLeftNavigationControllerRestorationKey"];
        
        self = [super initWithCenterViewController:navigationController
                                 leftDrawerViewController:leftSideNavController];
        [self setShowsShadow:NO];
    }

    
    [self setRestorationIdentifier:@"MMDrawer"];
    [self setMaximumRightDrawerWidth:200.0];
    [self setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    [self
     setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
         MMDrawerControllerDrawerVisualStateBlock block;
         block = [[MMExampleDrawerVisualStateManager sharedManager]
                  drawerVisualStateBlockForDrawerSide:drawerSide];
         if(block){
             block(drawerController, drawerSide, percentVisible);
         }
     }];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self setupLeftMenuButton];
//    [self setupRightMenuButton];
//    
//    UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
//    [doubleTap setNumberOfTapsRequired:2];
//    [self.view addGestureRecognizer:doubleTap];
//    
//    UITapGestureRecognizer * twoFingerDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerDoubleTap:)];
//    [twoFingerDoubleTap setNumberOfTapsRequired:2];
//    [twoFingerDoubleTap setNumberOfTouchesRequired:2];
//    [self.view addGestureRecognizer:twoFingerDoubleTap];
//    
//    if(OSVersionIsAtLeastiOS7()){
//        UIColor * barColor = [UIColor
//                              colorWithRed:247.0/255.0
//                              green:249.0/255.0
//                              blue:250.0/255.0
//                              alpha:1.0];
//        [self.navigationController.navigationBar setBarTintColor:barColor];
//    }
//    else {
//        UIColor * barColor = [UIColor
//                              colorWithRed:78.0/255.0
//                              green:156.0/255.0
//                              blue:206.0/255.0
//                              alpha:1.0];
//        [self.navigationController.navigationBar setTintColor:barColor];
//    }

}

//#pragma mark - Button
//-(void)setupLeftMenuButton{
//    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
//    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
//}
//
//-(void)setupRightMenuButton{
//    MMDrawerBarButtonItem * rightDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(rightDrawerButtonPress:)];
//    [self.navigationItem setRightBarButtonItem:rightDrawerButton animated:YES];
//}
//
//#pragma mark - Button Handlers
//-(void)leftDrawerButtonPress:(id)sender{
//    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
//}
//
//-(void)rightDrawerButtonPress:(id)sender{
//    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
//}
//
//-(void)doubleTap:(UITapGestureRecognizer*)gesture{
//    [self.mm_drawerController bouncePreviewForDrawerSide:MMDrawerSideLeft completion:nil];
//}
//
//-(void)twoFingerDoubleTap:(UITapGestureRecognizer*)gesture{
//    [self.mm_drawerController bouncePreviewForDrawerSide:MMDrawerSideRight completion:nil];
//}

@end
