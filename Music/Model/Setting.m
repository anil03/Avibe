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

- (UIColor*)sharedBackgroundColor
{
    return [UIColor colorWithRed:102.0/255.0
                           green:163.0/255.0
                            blue:210.0/255.0
                           alpha:1.0];
}


@end
