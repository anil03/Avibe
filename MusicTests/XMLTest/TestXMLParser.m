//
//  TestXMLParser.m
//  Beet
//
//  Created by Yuhua Mai on 12/9/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "YMXMLParseViewController.h"

@interface TestXMLParser : XCTestCase

@end

@implementation TestXMLParser

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    YMXMLParseViewController *controller = [[YMXMLParseViewController alloc] init];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
