//
//  BackgroundImageViewTest.m
//  Avibe
//
//  Created by Yuhua Mai on 1/11/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BackgroundImageView.h"

@interface BackgroundImageViewTest : XCTestCase

@property UIView *backgroundImageView;

@end

@implementation BackgroundImageViewTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    _backgroundImageView = [[BackgroundImageView alloc] init];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    _backgroundImageView = nil;
    
    [super tearDown];
}

- (void)testExample
{


}

@end
