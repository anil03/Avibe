//
//  XMLParser.h
//  Beet
//
//  Created by Yuhua Mai on 12/9/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XMLParserDelegate <NSObject>

- (void)finishParsing:(NSMutableArray*)result;

@end

@interface ScrobbleListenedMusic : NSObject

@property (nonatomic, weak) id<XMLParserDelegate> delegate;

- (id)initWithURL:(NSURL*)url;
- (id)initWithURL:(NSURL*)url AndData:(NSMutableArray*)data;
- (void)startParsing;

@end
