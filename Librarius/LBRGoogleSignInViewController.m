//
//  LBRGoogleSignInViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/24/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#define DBLG NSLog(@"%@ reporting!", NSStringFromSelector(_cmd));


#import "LBRGoogleSignInViewController.h"
#import <GoogleSignIn.h>
#import "LBRConstants.h"
#import <GIDSignInButton.h>

//#import <UIButton+AFNetworking.h>

@interface LBRGoogleSignInViewController ()

@end

@implementation LBRGoogleSignInViewController

static NSString * const signInToTabBarSegueID = @"signInToTabBarSegueID";

- (void)viewDidLoad {
    [super viewDidLoad];
    
#pragma mark - GoogleSignIn
    NSError* configureError = nil;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError.localizedDescription);

//    ================
//    GIDSignIn
//    ================
    GIDSignIn *signInManager = [GIDSignIn sharedInstance];
    
    signInManager.scopes = @[@"https://accounts.google.com/o/oauth2/auth"];
    signInManager.shouldFetchBasicProfile = YES;
    signInManager.delegate = self;
    signInManager.uiDelegate = self;
    signInManager.clientID = GOOGLE_CLIENT_ID;
    
//  ================
//  GIDSignInButton
//  ================
//    self.signInButton.style = kGIDSignInButtonStyleWide;
//    self.signInButton.delegate = self;
//    [self.view addSubview:self.signInButton];
    
    
NSLog(@"BEFORE signInSilently, does%@ have Authentication stored in Keychain.", [[GIDSignIn sharedInstance] hasAuthInKeychain]? @"" : @" NOT");
        // Uncomment to automatically sign in the user.
//    !!!: Uncomment before shipping
        [signInManager signInSilently];
NSLog(@"AFTER signInSilently, does%@ have Authentication stored in Keychain.", [[GIDSignIn sharedInstance] hasAuthInKeychain]? @"" : @" NOT");
    
    
}

#pragma mark GoogleSignIn methods

-(void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
        //Perform any operations on signed in user here.
        //???Probably not needed...
    if (error == nil) {
        NSString *userId  = user.userID;// For client-side use only!
        NSString *idToken = user.authentication.idToken;// Safe to send to the server
        NSString *name    = user.profile.name;
        NSString *email   = user.profile.email;
        // ...
        [self performSegueWithIdentifier:signInToTabBarSegueID sender:nil];
    }
}

-(void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
        // Perform any operations when the user disconnects from app, here.
        // ...
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
