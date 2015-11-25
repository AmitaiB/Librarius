//
//  AppDelegate.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/23/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import <GoogleSignIn.h>
#import "BookDetailViewController.h"
#import "BookCollection_TableViewController.h"
#import "LBRDataManager.h"
//#import <UIKit+AFNetworking.h>
//#import <AFNetworking.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
    //#import "Library.h"

#import <AVFoundation/AVFoundation.h>
#import "UIColor+ABBColors.h"
#import "UIColor+FlatUI.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark - Developer Lazy methods
/**
 *  Delete before shipping! Alerts the Dev that Xcode has finished compiling! 😃
 */
-(void)awakeFromNap {
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}


#pragma mark

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        // Override point for customization after application launch.
    [self awakeFromNap];
    
    [self setupAppearance];
    [self setupCocoaLumberjack];
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    
        //What is this? ↓ Why did I need those references...?
//    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
//    MasterViewController *controller = (MasterViewController *)navigationController.topViewController;
//    controller.managedObjectContext = self.managedObjectContext;
    
    
//#pragma mark - GoogleSignIn
//    NSError* configureError = nil;
//    [[GGLContext sharedInstance] configureWithError:&configureError];
//    NSAssert(!configureError, @"Error configuring Google services: %@", configureError.localizedDescription);
//
//    [GIDSignIn sharedInstance].delegate = self;

    return YES;
}

#pragma mark - === private setup methods ===

- (void)setupCocoaLumberjack
{
        ///CocoaLumberjack Initialization files.
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor redColor] backgroundColor:nil forFlag:DDLogFlagError];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor carrotColor] backgroundColor:nil forFlag:DDLogFlagWarning];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor peterRiverColor] backgroundColor:nil forFlag:DDLogFlagInfo];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor wisteriaColor] backgroundColor:nil forFlag:DDLogFlagDebug];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor emerlandColor] backgroundColor:nil forFlag:DDLogFlagVerbose];

    /*
     DDLogError(@"Error");
     DDLogWarn(@"Warn");
     DDLogInfo(@"Info");
     DDLogDebug(@"Debug");
     DDLogVerbose(@"Verbose");
     */
    
    [[LBRDataManager sharedDataManager] generateDefaultLibraryIfNeeded];
}

- (void)setupAppearance {
    UINavigationBar *navigationbarAppearance = [UINavigationBar appearance];
    navigationbarAppearance.barTintColor = [UIColor colorWithRed:77.0/255.0 green:164.0/255.0 blue:191.0/255.0 alpha:1.0f];
    navigationbarAppearance.tintColor = [UIColor whiteColor];
    navigationbarAppearance.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
}

#pragma mark - UIApplicationDelegate methods

    //Added at GoogleSignIn's behest...
-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation {
    
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:sourceApplication
                                      annotation:annotation];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//    [MagicalRecord cleanUp];
    LBRDataManager *dataManager = [LBRDataManager sharedDataManager];
    [dataManager saveContextAndCheckForDuplicateVolumes:YES];
}



@end
