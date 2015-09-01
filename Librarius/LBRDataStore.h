//
//  LBRDataStore.h
//  Librarius
//
//  Created by Amitai Blickstein on 9/1/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LBRDataStore : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
    //Other properties to store and fetch, e.g., NSArray *messages...

+ (instancetype) sharedDataStore;

-(void) saveContext;
-(void) generateTestData;
-(void) fetchData;

@end
