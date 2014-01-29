//
//  Cell.h
//  Beet
//
//  Created by Yuhua Mai on 12/7/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YMTableViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *albumLabel;
@property (strong, nonatomic) UILabel *artistLabel;
@property (strong, nonatomic) UILabel *userLabel;

- (void)setupWithDictionary:(NSDictionary *)dictionary;

@end
