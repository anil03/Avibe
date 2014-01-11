//
//  TestNSXMLParser.m
//  Beet
//
//  Created by Yuhua Mai on 12/9/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Avibe-Prefix.pch"

//Usage:
//http://stackoverflow.com/questions/8813968/parsing-xml-in-nsxmlparser

@interface TestNSXMLParser : XCTestCase<NSXMLParserDelegate>

@property (nonatomic, strong) NSXMLParser *parser;
@property BOOL parsingExecuted;

@property NSMutableString *text;
@property NSMutableString *tempText;

@end

@implementation TestNSXMLParser

- (void)setUp
{
    [super setUp];
    
    NSURL *url = [NSURL URLWithString:@"http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=myhgew&api_key=55129edf3dc293c4192639caedef0c2e&limit=10"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    self.parser = [[NSXMLParser alloc] initWithData:data];
    self.parser.delegate = self;
    
    self.parsingExecuted = NO;
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testExample
{
    XCTAssertTrue([self.parser parse]);
    XCTAssertTrue(self.parsingExecuted, @"Parsing Executed");
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"artist"]){
        self.text = [[NSMutableString alloc] init];
    }
    self.tempText = nil;
    NSLog(@"%@ %@ %@", elementName, namespaceURI, qName);
    self.parsingExecuted = YES;

}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if(!self.tempText){
        self.tempText = [[NSMutableString alloc] initWithString:string];
    }else{
        [self.tempText appendString:string];
    }
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"artist"]){
        self.text = self.tempText;
    }
    self.tempText = nil;

}



@end
