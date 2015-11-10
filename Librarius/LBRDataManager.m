//  LBRDataManager.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/26/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
/**
 Abstract: This class is the central clearinghouse for data in the app.
 It manages the reception of data from the API calls, and maps them to 
 the apps internal models. It also is responsible for the CoreData stack,
 and any other matters of persistence that may come up.
 */

#define kLightweightMigration TRUE

#import "LBRDataManager.h"
#import "LBRGoogleGTLClient.h"

    //Models
#import "Library.h"
#import "Bookcase.h"
#import "Volume.h"
#import "CoverArt.h"
#import "LBRParsedVolume.h"
#import <GTLBooksVolume.h>

@implementation LBRDataManager

static NSString * const kUnknown = @"kUnknown";

+ (instancetype)sharedDataManager {
    static LBRDataManager *_sharedDataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDataManager = [self new];
    });
    return _sharedDataManager;
}

-(instancetype)init {
    if (!(self = [super init])) return nil;
    
    _uniqueCodes = [NSMutableArray new];
//FIXME:    _googleClient = [LBRGoogleGTLClient sharedGoogleGTLClient];
    _parsedVolumesToEitherSaveOrDiscard = [NSMutableArray new];
    _parsedVolumeFromLastBarcode = [LBRParsedVolume new];
    _libraries = @[];
    
    return self;
}

    //User-facing ✅
-(void)saveParsedVolumesToEitherSaveOrDiscardToPersistentStore {
        // 1. LBRParsedVolume → NSManagedObject
        // 2. Repeat for all volumes.
        // 3. Save context.
        // 4. Test.
    for (LBRParsedVolume *transientVolumeToSave in self.parsedVolumesToEitherSaveOrDiscard) {

            //CLEAN: We check before, in the ScannerViewController.
        [self checkStoreForDuplicates:transientVolumeToSave];
        [self insertVolumeToContextFromTransientVolume:transientVolumeToSave];
    }
    self.parsedVolumesToEitherSaveOrDiscard = @[];
    [self saveContext];
        NSLog(@"Context's (new) volumes saved to current library.");
}

    //FIXME: Doesn't work!
-(BOOL)checkStoreForDuplicates:(LBRParsedVolume *)volume {
//    http://www.theappcodeblog.com/?p=176#more-176
        //search to see if the entity already exists
    
        //We use an NSPredicate combined with the fetchedResultsCntroller to perform
        //the search.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isbn13 CONTAINS[cd] %@", volume.isbn];
    NSFetchRequest *duplicatesRequest = [NSFetchRequest fetchRequestWithEntityName:@"Volume"];
    duplicatesRequest.predicate = predicate;
    NSError *error = nil;
    BOOL isDuplicate = @([self.managedObjectContext countForFetchRequest:duplicatesRequest error:&error]).boolValue;
    if (error) {
            //Handle error
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1); //Fail
    }
    return isDuplicate;
}

-(void)updateWithNewTransientVolume:(LBRParsedVolume*)volumeToAdd {
        // Logic
    self.parsedVolumesToEitherSaveOrDiscard = [self.parsedVolumesToEitherSaveOrDiscard arrayByAddingObject:volumeToAdd];
}

-(NSArray *)parsedVolumesToEitherSaveOrDiscard
{
    if (_parsedVolumesToEitherSaveOrDiscard == nil)
        _parsedVolumesToEitherSaveOrDiscard = @[];
    
    return _parsedVolumesToEitherSaveOrDiscard;
}


-(void)insertVolumeToContextFromTransientVolume:(LBRParsedVolume*)volumeToInsert {
    Volume *persistentVolume = [NSEntityDescription insertNewObjectForEntityForName:@"Volume" inManagedObjectContext:self.managedObjectContext];
    persistentVolume.isbn10          = volumeToInsert.isbn10;
    persistentVolume.isbn13          = volumeToInsert.isbn13;
    persistentVolume.title           = volumeToInsert.title;
    persistentVolume.thickness       = volumeToInsert.thickness;
    persistentVolume.height          = volumeToInsert.height;
    persistentVolume.pageCount       = volumeToInsert.pageCount;
    persistentVolume.cover_art_large = volumeToInsert.cover_art_large;
    persistentVolume.cover_art       = volumeToInsert.cover_art;
    persistentVolume.author          = volumeToInsert.author;
    persistentVolume.authorSurname   = volumeToInsert.authorSurname;
    persistentVolume.mainCategory    = volumeToInsert.mainCategory;
    persistentVolume.published       = volumeToInsert.published;
    persistentVolume.rating          = volumeToInsert.rating;
    persistentVolume.google_id       = volumeToInsert.google_id;

    persistentVolume.publDescription = volumeToInsert.publDescription;
    persistentVolume.subtitle        = volumeToInsert.subtitle;
    persistentVolume.avgRating       = volumeToInsert.avgRating;
    persistentVolume.ratingsCount    = volumeToInsert.ratingsCount;

    persistentVolume.library         = self.currentLibrary;
    persistentVolume.dateCreated     = [NSDate date];
    persistentVolume.dateModified    = [NSDate date];
    
    CoverArt *associatedCoverArt = [NSEntityDescription insertNewObjectForEntityForName:@"CoverArt" inManagedObjectContext:self.managedObjectContext];
    [associatedCoverArt downloadImagesForCorrespondingVolume:persistentVolume];
}


    //debug-related
-(void)logCurrentLibrary {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Volume"];
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:nil];
//    NSLog(@"Fetched volumes from Core Data: %@", [results description]);
}

//#pragma mark - helper methods

    // ===================== CoreData additions here

#pragma mark - ***** CoreData *****
#pragma mark  Fetch Data

- (void)fetchData
{
    [self generateDefaultLibraryIfNeeded];
    NSFetchRequest *librariesFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Library"];
    NSSortDescriptor *orderSorter = [NSSortDescriptor sortDescriptorWithKey:@"orderWhenListed" ascending:YES];
    librariesFetchRequest.sortDescriptors = @[orderSorter];
    NSError *error = nil;
    self.libraries = [self.managedObjectContext executeFetchRequest:librariesFetchRequest error:&error];
    self.currentLibrary = self.libraries[0];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


#pragma mark - *Core Data stack*
#pragma mark NSManagedObjectContext

    // Returns the managed object context for the application.
    // If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;}
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;}
    
        //alt: initWithConcurrencyType:NSMainQueueConcurrencyType
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - NSManagedObjectModel

-(NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;}
    
    NSURL *modelURL     = [[NSBundle mainBundle] URLForResource:@"Librarius" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

#pragma mark - NSPersistentStoreCoordinator

-(NSPersistentStoreCoordinator *)persistentStoreCoordinator {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
        // Create the coordinator and store (if there was none before)
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL             = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Librarius.sqlite"];
    NSError *error              = nil;
    NSString *failureReason     = @"There was an error creating or loading the application's saved data.";
    
    NSDictionary *lightweightMigrationOptions = nil;
    if (kLightweightMigration) lightweightMigrationOptions = @{NSMigratePersistentStoresAutomaticallyOption : @(YES),
                                                               NSInferMappingModelAutomaticallyOption       : @(YES)
                                                               };
    
        //This error reporting is not strictly necessary.
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:lightweightMigrationOptions error:&error]) {
            // Report any error we got.
        NSMutableDictionary *dict              = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey]        = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey]             = error;
        error                                  = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
            //Replace this with code to handle the error appropriately.
            //abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

    // Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - NSFetchedResultsController configurator

- (NSFetchedResultsController *)preconfiguredLBRFetchedResultsController:(UIViewController<NSFetchedResultsControllerDelegate> *)sender
{
    /**
     *  1) The set of all books (TODO: Uniquify the collection, so you cannot add multiple entries accidentally - UPDATE: Trickier than it looks)...
     *  2) ...in the current library,
     *  3) ...arranged by mainCategory,
     *  4) ...then author,
     *  5) ...then year.
     */
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    NSFetchRequest *volumesRequest = [NSFetchRequest fetchRequestWithEntityName:@"Volume"]; //(1)
    
        // Set the batch size to a suitable number.
    [volumesRequest setFetchBatchSize:20];
    
        // Edit the sort key as appropriate.
    NSSortDescriptor *categorySorter = [NSSortDescriptor sortDescriptorWithKey:@"mainCategory" ascending:YES];
    NSSortDescriptor *authorSorter   = [NSSortDescriptor sortDescriptorWithKey:@"authorSurname" ascending:YES];
    
    [self generateDefaultLibraryIfNeeded];
        //TODO: Might need @"library.name = datamanager.currentLibrary.name"
    NSPredicate *libraryPredicate = [NSPredicate predicateWithFormat:@"library = %@", self.currentLibrary];
    
    volumesRequest.sortDescriptors = @[categorySorter, authorSorter];
    volumesRequest.predicate = libraryPredicate;
    
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:volumesRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"mainCategory" cacheName:@"LBRLayoutSchemeGenreAuthorDate"];
    
    frc.delegate = sender;
    
    NSError *error = nil;
    if (![frc performFetch:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. !!!:You should not use this function in a shipping application, although it may be useful during development.
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return frc;
}    


#pragma mark - Generate Data
- (void)generateTestDataIfNeeded
{
    LBRGoogleGTLClient *googleClient = [LBRGoogleGTLClient sharedGoogleGTLClient];
    [self generateDefaultLibraryIfNeeded];
//    Only if the library is non-empty, we're not "needed".
    if (self.currentLibrary.volumes.count) {return;}
    
    /**
     *  Given an array of ISBNs, populate the DB.
     */
    NSArray *listOfISBNs = @[@"978-1-60309-050-6",
                             @"978-1-60309-266-1",
                             @"978-1-60309-025-4",
                             @"978-1-60309-239-5",
                             @"978-1-60309-042-1"];
    
    
    for (NSString *ISBN in listOfISBNs) {
        [googleClient queryForVolumeWithString:ISBN withCallback:^(GTLBooksVolume *responseVolume) {
            LBRParsedVolume *newParsedVolume = [[LBRParsedVolume alloc] initWithGoogleVolume:responseVolume];
            self.parsedVolumesToEitherSaveOrDiscard = [self.parsedVolumesToEitherSaveOrDiscard arrayByAddingObject:newParsedVolume];
        }];
    }
    
    [self saveContext];
    [self fetchData];
}

/**
 *  Seeds the dataManager's currentLibrary property.
 */
-(void)generateDefaultLibraryIfNeeded {
    NSFetchRequest *libraryRequest = [NSFetchRequest fetchRequestWithEntityName:@"Library"];
    NSError *error = nil;
    
    BOOL datastoreHasAtLeastOneLibrary = [self.managedObjectContext countForFetchRequest:libraryRequest error:&error] >= 1;
    
    if (datastoreHasAtLeastOneLibrary) {
        self.currentLibrary = [[self.managedObjectContext executeFetchRequest:libraryRequest error:nil] firstObject];
    } else {
        Library *newDefaultLibrary = [NSEntityDescription insertNewObjectForEntityForName:@"Library" inManagedObjectContext:self.managedObjectContext];
        newDefaultLibrary.name = @"Default Library (set name in options)";
        newDefaultLibrary.orderWhenListed = @1;
        newDefaultLibrary.dateCreated = [NSDate date];
        newDefaultLibrary.dateModified = [NSDate date];
        self.currentLibrary = newDefaultLibrary;
        [self saveContext];
    }
}

#pragma mark - data migration related (limited use)

-(void)giveCurrentLibraryADateIfNeeded
{
    if (!self.currentLibrary.dateCreated) {
        self.currentLibrary.dateCreated = [NSDate date];
        self.currentLibrary.dateModified = [NSDate date];
    }
}


-(void)giveVolumeADateIfNeeded:(Volume*)volume
{
    if (!volume.dateCreated) {
        volume.dateCreated = [NSDate date];
        volume.dateModified = [NSDate date];
    }
}

@end
