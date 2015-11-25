//
//  LBRDataManager.h
//  Librarius
//
//  Created by Amitai Blickstein on 8/26/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class Bookcase;
@class Volume;
@class GTLBooksVolume;
@class GTLBooksVolumes;
//@class LBRGoogleGTLClient;
@class Library;
@class RootCollection;

@interface LBRDataManager : NSObject <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSMutableArray *uniqueCodes;
//@property (nonatomic, strong) NSArray *parsedVolumesToEitherSaveOrDiscard;
//@property (nonatomic, strong) LBRParsedVolume *parsedVolumeFromLastBarcode; //<-- Use this to confirm user's selection, then enter it into Persistent Data.
@property (nonatomic, strong) Volume *volumeFromLastBarcode; //CLEAN: Probably not actually needed.
@property (nonatomic, strong) NSMutableArray <Volume*> *volumesRecentlyAddedToContext;
@property (nonatomic, strong) NSDictionary *sortDescriptors;

+(instancetype)sharedDataManager;


//-(void)updateWithNewTransientVolume:(LBRParsedVolume*)volumeToAdd;
//-(void)saveParsedVolumesToEitherSaveOrDiscardToPersistentStore;

    //CLEAN: debug only
-(void)logCurrentLibrary;
-(void)logCurrentLibraryTitles;
-(void)deleteAllObjectsOfEntityName:(NSString*)entityName;


//============== CoreData @interface

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
    //Other properties to store and fetch, e.g., NSArray *messages...

@property (nonatomic, strong) NSArray *libraries;
@property (nonatomic, strong) RootCollection *userRootCollection;
@property (nonatomic, strong) Library *currentLibrary;
@property (nonatomic, strong) Bookcase *currentBookcase;
    //http://stackoverflow.com/questions/14671478/coredata-error-failed-to-call-designated-initializer-on-nsmanagedobject-class


    //======== Global Property, BAD!
    //@property (nonatomic, strong) NSMutableDictionary *transientLibraryLayoutInformation;


    //====== New Core-Data-Only methods/properties

@property (nonatomic, strong) NSFetchRequest *volumesRequest;
@property (nonatomic, strong) NSFetchRequest *bookcasesRequest;
-(NSFetchedResultsController*)currentLibraryVolumesFetchedResultsController;
-(NSFetchedResultsController*)currentLibraryVolumesFetchedResultsController:(UIViewController<NSFetchedResultsControllerDelegate> *)sender;
-(NSFetchedResultsController*)currentLibraryBookcasesFetchedResultsController;
-(NSFetchedResultsController*)currentLibraryBookcasesFetchedResultsController:(UIViewController<NSFetchedResultsControllerDelegate> *)sender;



-(void) fetchData;
- (void) saveContext;
//- (void)saveContextAndCheckForDuplicateVolumes:(BOOL)permissionToCheckForDuplicates;


-(void) generateUserRootCollectionIfNeeded; ///Should only be needed first use.

// =================== Should not be needed, except for generating test data.
-(void) generateTestDataIfNeeded;
-(void) generateDefaultLibraryIfNeeded;
-(void) generateDefaultBookcaseIfNeeded;

-(void) generateBookcasesForLibrary:(Library *)library withDimensions:(NSDictionary <NSNumber*, NSNumber*> *)dimensions;

//    =============== migration related
-(void)giveCurrentLibraryADateIfNeeded;
-(void)giveVolumeADateIfNeeded:(Volume*)volume;
-(void)giveBookcaseANameAndFullIfNeeded:(Bookcase*)bookcase;

//    =============== Debug Related
-(void)refreshLibrary:(Library*)library;

@end
