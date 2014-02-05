//
//  TestIPodListenedMusic.m
//  Avibe
//
//  Created by Yuhua Mai on 2/4/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "IPodListenedMusic.h"

@interface TestIPodListenedMusic : XCTestCase
@property (nonatomic, strong) IPodListenedMusic *music;
@end

@implementation TestIPodListenedMusic

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    _music = [[IPodListenedMusic alloc] init];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testExample
{
    NSDictionary *musicDict = [_music iPodPlayedMusic];
    XCTAssertNil(musicDict, @"iPodPlayedMusic should be nil");
    //    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
