//
//  YoutubeOAuth.m
//  Avibe
//
//  Created by Yuhua Mai on 2/7/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "YoutubeOAuth.h"

/**
 * Using OAuth 2.0 for Installed Applications
 * https://developers.google.com/accounts/docs/OAuth2InstalledApp#choosingredirecturi
 */

@interface YoutubeOAuth() <UIWebViewDelegate, NSURLConnectionDataDelegate>


@end

@implementation YoutubeOAuth

-(void)formingURL
{
    NSURL *url = [NSURL URLWithString:@"https://accounts.google.com/o/oauth2/auth?client_id=4881560502-uteihtgcnas28bcjmnh0hfrbk4chlmsa.apps.googleusercontent.com&redirect_uri=http://localhost&scope=https://gdata.youtube.com&response_type=code&access_type=offline"];
//    [[UIApplication sharedApplication] openURL:url];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    [connection start];
//    UIWebView *webView = [[UIWebView alloc] init];
//    webView.delegate = self;
//    [webView loadRequest:request];
    

    
    //    NSData *data = [NSData dataWithContentsOfURL:url];
    //
    //
    //    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //    NSLog(@"ret=%@", ret);
    
}
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    NSURLRequest *newRequest = request;
    if (response) {
        newRequest = nil;
    }
    return newRequest;
    
}

//- (void)webViewDidStartLoad:(UIWebView *)webView
//{
//    NSURL *currentURL = webView.request.URL;
//    NSLog(@"%@", currentURL);
//}
//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    NSURL *currentURL = webView.request.URL;
//    NSLog(@"%@", currentURL);
//}


@end
