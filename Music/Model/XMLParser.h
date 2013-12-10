//
//  XMLParser.h
//  Beet
//
//  Created by Yuhua Mai on 12/9/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLParser : NSObject

- (id)initWithURL:(NSURL*)url AndDelegate:(id)delegate;
- (BOOL)startParse;

@end
