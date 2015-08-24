//
//  LBRGoogleSignInViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/24/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBRGoogleSignInViewController.h"
#import <GoogleOpenSource.h>
#import <GooglePlus.h>
#import "LBRConstants.h"

@interface LBRGoogleSignInViewController ()

@end

@implementation LBRGoogleSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
        //signIn.shouldFetchGoogleUserEmail = YES;  // Uncomment to get the user's email
    
    signIn.clientID = GOOGLE_CLIENT_ID;
    
        // Uncomment one of these two statements for the scope you chose in the previous step
    signIn.scopes = @[ kGTLAuthScopePlusLogin ];  // ← "https://www.googleapis.com/auth/plus.login" scope
        //signIn.scopes = @[ @"profile" ];            // "profile" scope
    
        // Optional: declare signIn.actions, see "app activities"
    signIn.delegate = self;
}

#pragma mark - GPPSignInDelegate method(s)

-(void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error {
    NSLog(@"Received error %@ and auth object %@", error.localizedDescription, auth);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
