//
//  YoutubeAuthorizeViewController.h
//  Avibe
//
//  Created by Yuhua Mai on 2/10/14.
//  Copyright (c) 2014 Yuhua Mai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    httpMethod_GET,
    httpMethod_POST,
    httpMethod_DELETE,
    httpMethod_PUT
} HTTP_Method;


@protocol GoogleOAuthDelegate
-(void)authorizationWasSuccessful;
-(void)accessTokenWasRevoked;
-(void)responseFromServiceWasReceived:(NSString *)responseJSONAsString andResponseJSONAsData:(NSData *)responseJSONAsData;
-(void)errorOccuredWithShortDescription:(NSString *)errorShortDescription andErrorDetails:(NSString *)errorDetails;
-(void)errorInResponseWithBody:(NSString *)errorMessage;
@end

@interface YoutubeAuthorizeViewController : UIViewController

@property (nonatomic, weak) UIViewController *previousViewController;

@property (nonatomic, strong) id<GoogleOAuthDelegate> gOAuthDelegate;
-(void)authorizeUserWithClienID:(NSString *)client_ID andClientSecret:(NSString *)client_Secret
                  andParentView:(UIView *)parent_View andScopes:(NSArray *)scopes;
-(void)revokeAccessToken;
-(void)callAPI:(NSString *)apiURL withHttpMethod:(HTTP_Method)httpMethod
postParameterNames:(NSArray *)params postParameterValues:(NSArray *)values;

@end
