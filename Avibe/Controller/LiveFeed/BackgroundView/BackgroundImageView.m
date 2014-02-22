//
//  BackgroundImageView.m
//  Avibe
//
//  Created by Yuhua Mai on 1/11/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "BackgroundImageView.h"

#import "ImageFetcher.h"
#import "PublicMethod.h"
#import "YMGenericCollectionViewCell.h"

@interface BackgroundImageView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property NSArray *images;

@property int row;
@property int column;

@end

@implementation BackgroundImageView

- (id)initWithFrame:(CGRect)frame
{
    float imageHeight = 80.0f;
    float imageWidth = 80.0f;
    
    _row = 8;//frame.size.height/imageHeight; //10;
    _column = 4;//frame.size.width/imageWidth; //4;
    
    UICollectionViewFlowLayout *backgroundFlowLayout =[[UICollectionViewFlowLayout alloc] init];
    [backgroundFlowLayout setItemSize:CGSizeMake([UIScreen mainScreen].bounds.size.width/_column, [UIScreen mainScreen].bounds.size.height/_row)];
    [backgroundFlowLayout setSectionInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [backgroundFlowLayout setMinimumInteritemSpacing:0.0f]; //Between items
    [backgroundFlowLayout setMinimumLineSpacing:0.0f]; //Between lines
    
    self = [super initWithFrame:frame collectionViewLayout:backgroundFlowLayout];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.delegate = self;
        self.dataSource = self;
        [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
        
        float barHeight = 30.0f;
        UIView *mask = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height+barHeight)];
        [mask setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8]];
        [self addSubview:mask];
        [self bringSubviewToFront:mask];
        
        //Load background images
//        ImageFetcher *fetcher = [[ImageFetcher alloc] initWithLimit:_row*_column andTerm:@"*"];
//        ImageFetcher *fetcher = [PublicMethod sharedInstance].imageFetcher;
        _images = [PublicMethod sharedInstance].backgroundImages;
        
        self.userInteractionEnabled = NO;
    }
    
    return self;
}


#pragma mark - Layout


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _row*_column;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:_images[indexPath.row%[_images count]]];
//    imageView.alpha = 0.4;
    cell.backgroundView = imageView;
    
    return cell;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return CGSizeMake([[UIScreen mainScreen] bounds].size.width/3, 50);
//}

@end
