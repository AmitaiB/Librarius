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

//#import <UIButton+AFNetworking.h>

@interface LBRGoogleSignInViewController ()

@end

@implementation LBRGoogleSignInViewController

static NSString * const signInToTabBarSegueID = @"signInToTabBarSegueID";

- (void)viewDidLoad {
    [super viewDidLoad];
    GIDSignIn *signInManager = [GIDSignIn sharedInstance];
        //TODO(developer) Configure the sign-in button look/feel
    signInManager.uiDelegate = self;
    
        // Uncomment to automatically sign in the user.
//    !!!: Uncomment before shipping
//        [[GIDSignIn sharedInstance] signInSilently];
    
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
