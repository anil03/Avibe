//
//  Color.m
//  Avibe
//
//  Created by Yuhua Mai on 2/27/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "ColorConstant.h"

@implementation ColorConstant

+ (int)hexValue:(char)character
{
    switch (character) {
        case '0':
            return 0;
        case '1':
            return 1;
        case '2':
            return 2;
        case '3':
            return 3;
        case '4':
            return 4;
        case '5':
            return 5;
        case '6':
            return 6;
        case '7':
            return 7;
        case '8':
            return 8;
        case '9':
            return 9;
        case 'A':
            return 10;
        case 'B':
            return 11;
        case 'C':
            return 12;
        case 'D':
            return 13;
        case 'E':
            return 14;
        case 'F':
            return 15;
        default:
            [NSException raise:@"Hex value not valid" format:nil];
            return -1;
    }
}

+ (float)convertFromHexToDec:(NSString*)hex
{
    int a = [ColorConstant hexValue:[hex characterAtIndex:0]];
    int b = [ColorConstant hexValue:[hex characterAtIndex:1]];
    
    return (a*16+b);
}

+ (UIColor*)color:(NSString*)redString green:(NSString*)greenString blue:(NSString*)blueString alpha:(float)alpha
{
    float red = [ColorConstant convertFromHexToDec:redString]/255.0;
    float green = [ColorConstant convertFromHexToDec:greenString]/255.0;
    float blue = [ColorConstant convertFromHexToDec:blueString]/255.0;
    
    assert(red >= 0.0f && red <= 1.0f);
    assert(green >= 0.0f && green <= 1.0f);
    assert(blue >= 0.0f && blue <= 1.0f);
    assert(alpha >= 0.0f && alpha <= 1.0f);
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor*)sideMenuBackgroundColor
{
    return [UIColor colorWithRed:246.0 green:246.0 blue:246.0 alpha:1.0];
//    return [ColorConstant color:@"FF" green:@"FF" blue:@"FF" alpha:1.0f];
}
+ (UIColor*)sideMenuHeaderBackgroundColor
{
    return [ColorConstant color:@"45" green:@"45" blue:@"46" alpha:0.5];
}
+ (UIColor*)sideMenuCellColor
{
    return [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:0.05];
}
+ (UIColor*)sideMenuCellTextColor
{
    return [UIColor colorWithRed:28.0/255.0 green:51.0/255.0 blue:107.0/255.0 alpha:1.0];
//    return [ColorConstant color:@"00" green:@"00" blue:@"00" alpha:1.0f];
}

@end
