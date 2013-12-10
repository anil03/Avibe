//
//  XMLParser.m
//  Beet
//
//  Created by Yuhua Mai on 12/9/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "XMLParser.h"

@interface XMLParser()

@property (nonatomic, strong) NSXMLParser *parser;

@end

@implementation XMLParser

- (id)initWithURL:(NSURL*)url AndDelegate:(id)delegate
{
    self = [super init];
    
    if(!self){
        self.parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        self.parser.delegate = delegate;
    }

    return self;
}

- (BOOL)startParse
{
    return [self.parser parse];
}

@end
