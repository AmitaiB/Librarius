//
//  LBRDataManager.h
//  Librarius
//
//  Created by Amitai Blickstein on 8/26/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GTLBooksVolume;
@class GTLBooksVolumes;
@class LBRParsedVolume;
@class LBRGoogleGTLClient;
@class Library;
@interface LBRDataManager : NSObject

    // ScannerVC:GoogleBooksClient → VolumePresentationTVC
@property (nonatomic, strong) NSMutableArray *uniqueCodes;
@property (nonatomic, strong) LBRGoogleGTLClient *googleClient;
/**
 *  CLEAN: consider changing "parsed_X" to "transient_X"
 */
@property (nonatomic, strong) NSArray *parsedVolumes;
@property (nonatomic, strong) LBRParsedVolume *parsedVolumeFromLastBarcode; //<-- Use this to confirm user's selection, then enter it into Persistent Data.

@property (nonatomic, strong) GTLBooksVolumes *responseCollectionOfPotentialVolumeMatches;

+(instancetype)sharedDataManager;

-(void)addGTLVolumeToCurrentLibrary:(GTLBooksVolume*)volumeToAdd andSaveContext:(BOOL)saveContext;

//============== adding CoreData functions here

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
    //Other properties to store and fetch, e.g., NSArray *messages...

@property (nonatomic, strong) NSArray *libraries;
@property (nonatomic, strong) Library *currentLibrary;


-(void) saveContext;
-(void) generateTestDataIfNeeded;
-(void) fetchData;


@end
