//
//  TestXMLParser.m
//  Beet
//
//  Created by Yuhua Mai on 12/10/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ScrobbleListenedMusic.h"

static NSString *const kURLString = @"http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=myhgew&api_key=55129edf3dc293c4192639caedef0c2e&limit=10";

@interface TestXMLParser : XCTestCase<XMLParserDelegate>

@property (nonatomic, strong) ScrobbleListenedMusic *parser;
@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation TestXMLParser

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    self.data = [[NSMutableArray alloc] init];
    
    NSURL *url = [NSURL URLWithString:kURLString];
    self.parser = [[ScrobbleListenedMusic alloc] initWithURL:url AndData:self.data];
    self.parser.delegate = self;
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    self.data = nil;
    self.parser = nil;
    
    [super tearDown];
}

- (void)testExample
{
    [self.parser startParsing];
    XCTAssertNotNil(self.data, @"Data Not Empty.");

}

#pragma mark - XMLParserDelegate method
- (void)finishParsing
{
}

@end
