//
//  XMLParser.m
//  Beet
//
//  Created by Yuhua Mai on 12/9/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#import "ScrobbleListenedMusic.h"

#import "Song.h"

@interface ScrobbleListenedMusic() <NSXMLParserDelegate>

@property (nonatomic, strong) NSXMLParser *parser;

@property (nonatomic, strong) PFObject *tempSong;
@property NSMutableString *text;
@property NSMutableString *tempText;

@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation ScrobbleListenedMusic

- (id)initWithURL:(NSURL*)url
{
    self = [super init];
    
    if(self){
        NSData *scrobllerData = [NSData dataWithContentsOfURL:url];
        self.parser = [[NSXMLParser alloc] initWithData:scrobllerData];
        [self.parser setDelegate:self];
        
        _data = [[NSMutableArray alloc] init];
    }
    
    return self;
}
- (id)initWithURL:(NSURL*)url AndData:(NSMutableArray*)data
{
    self = [super init];
    
    if(self){
        NSData *scrobllerData = [NSData dataWithContentsOfURL:url];
        self.parser = [[NSXMLParser alloc] initWithData:scrobllerData];
        [self.parser setDelegate:self];
        
        self.data = data;
    }

    return self;
}

- (void)startParsing
{
    [self.parser parse];
}


#pragma mark - NSXMLParser delegate method
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"track"]){
        //New record for Song
        self.tempSong = [PFObject objectWithClassName:@"Song"];
    }
//    else if([elementName isEqualToString:@"artist"] || [elementName isEqualToString:@"name"] || [elementName isEqualToString:@"album"]){
//        self.text = [[NSMutableString alloc] init];
//    }
    self.tempText = nil;
    
//    NSLog(@"%@ %@ %@", elementName, namespaceURI, qName);
    
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
    if(!self.tempText){
        //skip if nil
        return;
    }
    
    if ([elementName isEqualToString:@"track"]) {
        //End of the element, store song
        NSString *currentUsername = [[PFUser currentUser] username];
        [self.tempSong setObject:currentUsername forKey:kClassSongUsername];
        [self.tempSong setObject:@"Scrobble" forKey:kClassSongSource];
        [self.data addObject:self.tempSong];
    }else if([elementName isEqualToString:@"artist"]){
        [self.tempSong setObject:self.tempText forKey:kClassSongArtist];
    }else if([elementName isEqualToString:@"name"]){
        [self.tempSong setObject:self.tempText forKey:kClassSongTitle];
    }else if([elementName isEqualToString:@"album"]){
        [self.tempSong setObject:self.tempText forKey:kClassSongAlbum];
    }
    self.tempText = nil;
    
}

#pragma mark - ScrobbleXMLParser delegate method
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    //Finish parsing, call delegate
    if(self.delegate && [self.delegate respondsToSelector:@selector(finishParsing:)]){
        [self.delegate finishParsing:_data];
    }
}

@end