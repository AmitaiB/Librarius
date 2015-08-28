//
//  AppDelegate.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/23/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import <GoogleSignIn.h>
#import "DetailViewController.h"
#import "MasterViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        // Override point for customization after application launch.
#pragma mark - CoreData
        //Love Magical Record! Thank you Ray W. http://www.raywenderlich.com/56879/magicalrecord-tutorial-ios
    [MagicalRecord setupCoreDataStack];
        //What is this? ↓
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    MasterViewController *controller = (MasterViewController *)navigationController.topViewController;
//    controller.managedObjectContext = self.managedObjectContext;
    
    
#pragma mark - GoogleSignIn
    NSError* configureError = nil;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError.localizedDescription);
    
    [GIDSignIn sharedInstance].delegate = self;
    
    return YES;
}

#pragma mark GoogleSignIn methods

-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation {
    
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:sourceApplication
                                      annotation:annotation];
}

-(void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
        //Perform any operations on signed in user here.
        //???Probably not needed...
    NSString *userId = user.userID; // For client-side use only!
    NSString *idToken = user.authentication.idToken; // Safe to send to the server
    NSString *name = user.profile.name;
    NSString *email = user.profile.email;
        // ...
}

-(void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
        // Perform any operations when the user disconnects from app, here.
        // ...
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
    [MagicalRecord cleanUp];
}

//#pragma mark - Core Data stack
//
//@synthesize managedObjectContext       = _managedObjectContext;
//@synthesize managedObjectModel         = _managedObjectModel;
//@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
//
//-(NSURL *)applicationDocumentsDirectory {
//        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.objective-v.HisMovies"(???) in the application's documents directory.
//    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
//}
///**
// *  This overridden getter for the managed object model for the application is standard boilerplate. It is a fatal error for the application not to be able to find and load its model, so if _managedObjectModel is nil, a new one is created.
// *
// *  @return _managedObjectModel
// */
//-(NSManagedObjectModel *)managedObjectModel {
//    if (_managedObjectModel != nil) {
//        return _managedObjectModel;
//    }
//    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"HisMovies" withExtension:@"momd"]; //???HisMovies
////    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
//    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
//    return _managedObjectModel;
//}
//
//-(NSPersistentStoreCoordinator *)persistentStoreCoordinator {
//        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
//    if (_persistentStoreCoordinator != nil) {
//        return _persistentStoreCoordinator;
//    }
//    
//        // Create the coordinator and store (if there was none before)
//    
//    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
//    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"HisMovies.sqlite"];
//    NSError *error = nil;
//    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
//    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
//            // Report any error we got.
//        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
//        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
//        dict[NSUnderlyingErrorKey] = error;
//        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
//            //Replace this with code to handle the error appropriately.
//            //abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//    return _persistentStoreCoordinator;
//}
//
//-(NSManagedObjectContext *)managedObjectContext {
//        //Returns the managed object context for the application (which is already bound to the persisstent store coordinator for the application.)
//    if (_managedObjectContext != nil) {
//        return _managedObjectContext;
//    }
//    
//    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
//    if (!coordinator) {
//        return nil;
//    }
//    /**
//     Changed the template's `init` → `initWi..Co..Type` since this app is basic with relatively small data requirements. ("Everything on the main queue" == "Must be performed in blocks".) May want to change if performance becomes an issue.
//     */
//    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
//    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
//    return  _managedObjectContext;
//}
//
//#pragma mark - Core Data Saving Support
//
//-(void)saveContext {
//    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
//    if (managedObjectContext != nil) {
//        NSError *error = nil;
//        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
//                // Replace this impl with code to handle the error appropriately.
//                // abort() causes the application to general a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
//    }
//}


@end
