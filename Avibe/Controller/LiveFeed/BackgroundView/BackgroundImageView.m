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
    _row = 8;
    _column = 4;
    
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
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:_images[indexPath.row]];
    imageView.alpha = 0.4;
    cell.backgroundView = imageView;
    
    return cell;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return CGSizeMake([[UIScreen mainScreen] bounds].size.width/3, 50);
//}

@end
