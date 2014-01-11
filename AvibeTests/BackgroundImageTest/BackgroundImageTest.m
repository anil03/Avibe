//
//  BackgroundImageTest.m
//  Avibe
//
//  Created by Yuhua Mai on 1/11/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ImageFetcher.h"

@interface BackgroundImageTest : XCTestCase

@property ImageFetcher *fetcher;
@property int limit;
@end

@implementation BackgroundImageTest

- (void)setUp
{
    [super setUp];

    _limit = 12;
    _fetcher = [[ImageFetcher alloc] initWithLimit:_limit andTerm:@"*"];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    _fetcher = nil;
    
    [super tearDown];
}

- (void)testExample
{
    NSArray *imageURLs = [_fetcher getAlbumImages];
    XCTAssertTrue([imageURLs count] == _limit, @"Count should be equal to limit");
    XCTAssertTrue(imageURLs != nil, @"Images not nil");
}

@end
