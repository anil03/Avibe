//
//  YMGenericCollectionViewCell.h
//  Beet
//
//  Created by Yuhua Mai on 12/28/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YMGenericCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *label;

- (void)setupWithDictionary:(NSDictionary *)dictionary;

@end
