//
//  YoutubeAuthorizeViewController.m
//  Avibe
//
//  Created by Yuhua Mai on 2/10/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import "ScrobbleAuthorizeViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "NSString+MD5.h"

@interface ScrobbleAuthorizeViewController ()

@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSURLConnection *urlConnection;

@end

@implementation ScrobbleAuthorizeViewController

- (void)viewWillAppear:(BOOL)animated
{
    [self setupMenuButton];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor redColor]];
//    self.view = [[UIWebView alloc] initWithFrame:self.view.frame];
    
    _receivedData = [[NSMutableData alloc] init];
    _urlConnection = [[NSURLConnection alloc] init];
    
    [self makePostRequestToGetMobileSession];
}

#pragma mark - Authorization
- (void)makePostRequestToGetMobileSession
{
    //api_keyxxxxxxxxmethodauth.getMobileSessionpasswordxxxxxxxusernamexxxxxxxx
//    Ensure your parameters are utf8 encoded. Now append your secret to this string.
    NSString *md5String = [NSString stringWithUTF8String:[@"api_key862a61374f83fe58088571f3134b88bcmethodauth.getMobileSessionpassword1989723usernamemyhgewa5bfdfebc2ef66b04984d78c116b88fb" UTF8String]];
    
    NSString *sig = [md5String MD5];
    NSLog(@"%@ %@", md5String, sig);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://ws.audioscrobbler.com/2.0/"]];
    [request setHTTPMethod:@"POST"];
    NSString *postParams = [NSString stringWithFormat: @"api_key=862a61374f83fe58088571f3134b88bc&format=json&method=auth.getMobileSession&password=1989723&username=myhgew&api_sig=%@",sig];
    [request setHTTPBody:[postParams dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [self makeRequest:request];
}
-(void)makeRequest:(NSMutableURLRequest *)request{
    // Set the length of the _receivedData mutableData object to zero.
    [_receivedData setLength:0];
    
    // Make the request.
    _urlConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *responseJSON;
    responseJSON = [[NSString alloc] initWithData:(NSData *)_receivedData encoding:NSUTF8StringEncoding];
    NSLog(responseJSON);
    
    NSError* error = nil;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:(NSData *)_receivedData
                          options:kNilOptions
                          error:&error];
    NSMutableDictionary *session = [json objectForKey:@"session"];
    NSString *name = [session objectForKey:@"name"];
    NSString *key = [session objectForKey:@"key"];
    NSLog(@"%@ %@", name, key);
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    // Append any new data to the _receivedData object.
    [_receivedData appendData:data];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSLog(@"%d", [httpResponse statusCode]);
    //200 means successful
}


#pragma mark - Button Handlers
-(void)setupMenuButton{
    //Navigation Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = @"Scrobble Authorization";
    titleLabel.textColor = [UIColor colorWithRed:3.0/255.0
                                           green:49.0/255.0
                                            blue:107.0/255.0
                                           alpha:1.0];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [titleLabel sizeToFit];
    self.mm_drawerController.navigationItem.titleView = titleLabel;
    
    /*
     MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
     [self.mm_drawerController.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
     */
    UIBarButtonItem * leftDrawerButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    self.mm_drawerController.navigationItem.leftBarButtonItem = leftDrawerButton;
    
    UIBarButtonItem * rightDrawerButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(popCurrentView)];
    [self.mm_drawerController.navigationItem setRightBarButtonItem:rightDrawerButton];
}
-(void)leftDrawerButtonPress:(id)sender{
	[self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}
- (void)popCurrentView
{
    [self.mm_drawerController setCenterViewController:self.previousViewController];
}

@end
