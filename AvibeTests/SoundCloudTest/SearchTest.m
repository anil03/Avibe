//
//  SearchTest.m
//  Avibe
//
//  Created by Yuhua Mai on 4/20/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface SearchTest : XCTestCase

@end

@implementation SearchTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
//    [self getTracks];
}

- (void)getTracks
{
//    SCAccount *account = [SCSoundCloud account];
//    if (account == nil) {
//        UIAlertView *alert = [[UIAlertView alloc]
//                              initWithTitle:@"Not Logged In"
//                              message:@"You must login first"
//                              delegate:nil
//                              cancelButtonTitle:@"OK"
//                              otherButtonTitles:nil];
//        [alert show];
//        return;
//    }
//
//    SCRequestResponseHandler handler;
//    handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
//        NSError *jsonError = nil;
//        NSJSONSerialization *jsonResponse = [NSJSONSerialization
//                                             JSONObjectWithData:data
//                                             options:0
//                                             error:&jsonError];
//        if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
//            SCTTrackListViewController *trackListVC;
//            trackListVC = [[SCTTrackListViewController alloc]
//                           initWithNibName:@"SCTTrackListViewController"
//                           bundle:nil];
//            trackListVC.tracks = (NSArray *)jsonResponse;
//            [self presentViewController:trackListVC
//                               animated:YES completion:nil];
//        }
//    };
    
//    NSString *resourceURL = @"https://api.soundcloud.com/me/tracks.json";
//    [SCRequest performMethod:SCRequestMethodGET
//                  onResource:[NSURL URLWithString:resourceURL]
//             usingParameters:nil
//                 withAccount:account
//      sendingProgressHandler:nil
//             responseHandler:handler];
}


- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
