//
//  Setting.m
//  Beet
//
//  Created by Yuhua Mai on 12/28/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "Setting.h"

@implementation Setting

+ (Setting *)sharedSetting
{
    static Setting *sharedSetting;
    
    @synchronized(self)
    {
        if (!sharedSetting)
            sharedSetting = [[Setting alloc] init];
        
        return sharedSetting;
    }
}

- (UIColor*)barTintColor
{
    return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
}

- (UIColor*)sharedBackgroundColor
{
    return [UIColor colorWithRed:0.0/255.0
                           green:0.0/255.0
                            blue:0.0/255.0
                           alpha:0.8];
//    return [UIColor colorWithRed:102.0/255.0
//                           green:163.0/255.0
//                            blue:210.0/255.0
//                           alpha:1.0];
}

- (UIColor*)primary1Color
{
    return [UIColor colorWithRed:0.0/255.0
                           green:0.0/255.0
                            blue:0.0/255.0
                           alpha:0.8];
//    return [UIColor colorWithRed:11.0/255.0
//                           green:97.0/255.0
//                            blue:164.0/255.0
//                           alpha:1.0];
}

- (UIColor*)sharedCellColor
{
    return [UIColor colorWithRed:6.0/255.0
                           green:0.0/255.0
                            blue:0.0/255.0
                           alpha:0.8];
//    return [UIColor colorWithRed:63.0/255.0
//                           green:146.0/255.0
//                            blue:210.0/255.0
//                           alpha:1.0];
}


@end
