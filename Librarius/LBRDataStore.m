//
//  LBRDataStore.m
//  Librarius
//
//  Created by Amitai Blickstein on 9/1/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBRDataStore.h"
    // Import your NSManagedObjectContext objects.
#import "Library.h"
#import "Bookcase.h"
#import "Volume.h"


@implementation LBRDataStore

+ (instancetype)sharedDataStore {
    static LBRDataStore *_sharedDataStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDataStore = [LBRDataStore new];
    });
    
    return _sharedDataStore;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

    // Returns the managed object context for the application.
    // If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Librarius.sqlite"];
    
    NSError *error = nil;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Librarius" withExtension:@"momd"];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

#pragma mark - Application's Documents directory

    // Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

/**
 *  May not be necessary.
 */
- (void)generateTestData
{
    
    [self saveContext];
    [self fetchData];
}

- (void)fetchData
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@""];
    
    NSSortDescriptor *createdAtSorter = [NSSortDescriptor sortDescriptorWithKey:@"" ascending:YES];
    fetchRequest.sortDescriptors = @[createdAtSorter];
    
//    self.messages = [self.managedObjectContext executeFetchRequest:messagesRequest error:nil];
    
//    if ([self.messages count]==0) {
//        [self generateTestData];
//    }
}
@end

