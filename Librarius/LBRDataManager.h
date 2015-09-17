//
//  LBRDataManager.h
//  Librarius
//
//  Created by Amitai Blickstein on 8/26/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GTLBooksVolume;
@class GTLBooksVolumes;
@class LBRParsedVolume;
//@class LBRGoogleGTLClient;
@class Library;
@interface LBRDataManager : NSObject

    // ScannerVC:GoogleBooksClient → VolumePresentationTVC
@property (nonatomic, strong) NSMutableArray *uniqueCodes;
//@property (nonatomic, strong) LBRGoogleGTLClient *googleClient;
/**
 *  CLEAN: consider changing "parsed_X" to "transient_X"
 */
@property (nonatomic, strong) NSArray *parsedVolumesToEitherSaveOrDiscard;
@property (nonatomic, strong) LBRParsedVolume *parsedVolumeFromLastBarcode; //<-- Use this to confirm user's selection, then enter it into Persistent Data.


+(instancetype)sharedDataManager;

-(void)updateWithNewTransientVolume:(LBRParsedVolume*)volumeToAdd;
-(void)saveParsedVolumesToEitherSaveOrDiscardToPersistentStore;
    //debug only
-(void)logCurrentLibrary;


//============== CoreData functions here

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
    //Other properties to store and fetch, e.g., NSArray *messages...

@property (nonatomic, strong) NSArray *libraries;
//FIXME: CoreData: error: Failed to call designated initializer on NSManagedObject class 'Library'
@property (nonatomic, strong) Library *currentLibrary;
    //http://stackoverflow.com/questions/14671478/coredata-error-failed-to-call-designated-initializer-on-nsmanagedobject-class

-(NSFetchedResultsController*)preconfiguredLBRFetchedResultsController:(UIViewController<NSFetchedResultsControllerDelegate> *)sender;
-(void) saveContext;
-(void) generateTestDataIfNeeded;
-(void) generateDefaultLibraryIfNeeded;
-(void) fetchData;


@end
