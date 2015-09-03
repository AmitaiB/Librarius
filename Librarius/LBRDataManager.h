//
//  LBRDataManager.h
//  Librarius
//
//  Created by Amitai Blickstein on 8/26/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LBRGoogleGTLClient.h"


@interface LBRDataManager : NSObject

    // ScannerVC:GoogleBooksClient → VolumePresentationTVC
@property (nonatomic, strong) NSMutableArray *uniqueCodes;
@property (nonatomic, strong) GTLBooksVolumes *responseCollectionOfPotentialVolumeMatches;

+(instancetype)sharedDataManager;

-(void)addVolumeToCollectionAndSave:(GTLBooksVolume*)volumeToAdd;

//============== adding CoreData functions here

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
    //Other properties to store and fetch, e.g., NSArray *messages...

-(void) saveContext;
-(void) generateTestData;
-(void) fetchData;



@end
