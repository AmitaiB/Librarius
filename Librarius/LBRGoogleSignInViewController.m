//
//  LBRGoogleSignInViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/24/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#define DBLG NSLog(@"%@ reporting!", NSStringFromSelector(_cmd));


#import "LBRGoogleSignInViewController.h"
#import <GoogleOpenSource.h>
#import <GooglePlus.h>
#import "LBRConstants.h"
//#import <UIButton+AFNetworking.h>

@interface LBRGoogleSignInViewController ()

@end

@implementation LBRGoogleSignInViewController

static NSString * const signInToTabBarSegueID = @"signInToTabBarSegueID";

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
    
    
    /**
     *  Attempts to automatically sign in the user. This call succeeds if:
     i. the user has authorized your application in the past, 
     ii. they haven't revoked access to your application, and
     iii. the app isn't requesting new scopes since they last signed in.
     *
     *  @return If this call succeeds, it calls your finishedWithAuth:error: method when sign in is complete.
     */
    [signIn trySilentAuthentication];
    
    
    [self.signOutButton setImage:[UIImage imageNamed:@"signOutG+"] forState:UIControlStateSelected];
    [self.signOutButton setNeedsDisplay];
    [self.signOutButton setNeedsLayout];
    
}

#pragma mark - GPPSignInDelegate method(s)

-(void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error {
    NSLog(@"Received error %@ and auth object %@", error.localizedDescription, auth);
    if (error) {
            // Do some error handling here.
    } else {
        [self refreshInterfaceBasedOnSignIn];
    }
}

-(void)refreshInterfaceBasedOnSignIn {
    if ([[GPPSignIn sharedInstance] authentication]) {
            //The user is signed in.
        self.signInButton.hidden = YES;
            //Perform other actions here, such as showing a sign-out button.
        [self performSegueWithIdentifier:signInToTabBarSegueID sender:nil];
        
        
    } else {
        self.signInButton.hidden = NO;
            //Perform other actions here.
    }
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

- (IBAction)signOutButtonTapped:(id)sender {
    [[GPPSignIn sharedInstance] signOut];
    DBLG
}
@end
