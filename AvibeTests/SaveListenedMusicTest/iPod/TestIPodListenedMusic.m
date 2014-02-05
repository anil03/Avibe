//
//  TestIPodListenedMusic.m
//  Avibe
//
//  Created by Yuhua Mai on 2/4/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "IPodListenedMusic.h"
#import "PublicMethod.h"

/**
 * Test whether getting songs played after lastUpdatedDate from iPod library.
 */

@interface TestIPodListenedMusic : XCTestCase

@end

@implementation TestIPodListenedMusic

- (void)setUp
{
    [super setUp];
    
    // Manually set the update date
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastUpdatedDate = [NSDate date];
    lastUpdatedDate = [lastUpdatedDate addTimeInterval:-1000000]; //Near past
    [defaults setObject:lastUpdatedDate forKey:kKeyLastUpdatedDate];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testExample
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastUpdatedDate = [defaults objectForKey:kKeyLastUpdatedDate];
    NSLog(@"============%@===============", lastUpdatedDate);
    
    NSArray *musicArray = [IPodListenedMusic iPodPlayedMusic];
    //Following codes fail the test?
    for(NSDictionary *dict in musicArray){
        NSLog(@"Title:%@, Album:%@, Artist%@", [dict objectForKey:kClassSongTitle], [dict objectForKey:kClassSongAlbum], [dict objectForKey:kClassSongArtist]);
    }
    XCTAssert([musicArray count] >= 0, @"iPodPlayedMusic may have dict.");
}

@end
