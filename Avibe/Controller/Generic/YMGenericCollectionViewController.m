//
//  YMGenericCollectionViewController.m
//  Beet
//
//  Created by Yuhua Mai on 12/30/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "YMGenericCollectionViewController.h"

#import "Setting.h"

@interface YMGenericCollectionViewController ()

@end

@implementation YMGenericCollectionViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(80, 100)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:10.0f]; //Between items
    [flowLayout setMinimumLineSpacing:10.0f]; //Between lines
    flowLayout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20); //Between sections
    
    self = [super initWithCollectionViewLayout:flowLayout];
    
    if(self){
        // setup
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.collectionView setBackgroundColor:[[Setting sharedSetting] sharedBackgroundColor]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
