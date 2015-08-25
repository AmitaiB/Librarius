//
//  LBRGoogleSignInViewController.h
//  Librarius
//
//  Created by Amitai Blickstein on 8/24/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus.h>

@class GPPSignInButton;
@interface LBRGoogleSignInViewController : UIViewController <GPPSignInDelegate>

@property (retain, nonatomic) IBOutlet GPPSignInButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;
- (IBAction)signOutButtonTapped:(id)sender;

@end
