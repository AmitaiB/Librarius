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
#import <GTLBooksVolume.h>
#import "RootCollection.h"

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
    _volumesRecentlyAddedToContext = [NSMutableArray new];
//    _parsedVolumesToEitherSaveOrDiscard = [NSMutableArray new];
//    _parsedVolumeFromLastBarcode = [LBRParsedVolume new];
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
       DDLogVerbose(@"Context's (new) volumes saved to current library.");
}

    //FIXME: Doesn't work!
-(BOOL)checkStoreForDuplicates:(LBRParsedVolume *)volume {
//    http://www.theappcodeblog.com/?p=176#more-176
        //search to see if the entity already exists
    
        //We use an NSPredicate combined with the fetchedResultsCntroller to perform
        //the search.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isbn13 CONTAINS[cd] %@", volume.isbn];
    NSFetchRequest *duplicatesRequest = [NSFetchRequest fetchRequestWithEntityName:[Volume entityName]];
    duplicatesRequest.predicate = predicate;
    NSError *error = nil;
    BOOL isDuplicate = @([self.managedObjectContext countForFetchRequest:duplicatesRequest error:&error]).boolValue;
    if (error) {
            //Handle error
        DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
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
    Volume *persistentVolume = [Volume insertNewObjectIntoContext:self.managedObjectContext];
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
    
    CoverArt *associatedCoverArt = [CoverArt insertNewObjectIntoContext:self.managedObjectContext];
    [associatedCoverArt downloadImagesForCorrespondingVolume:persistentVolume];
}


    //debug-related
-(void)logCurrentLibrary {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[Volume entityName]];
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:nil];
    DDLogVerbose(@"Fetched volumes from Core Data: %@", [results description]);
}

/**
 
 */
-(Library *)insertNewLibrary
{
    Library *newLibrary = [Library insertNewObjectIntoContext:self.managedObjectContext];
    newLibrary.dateCreated = [NSDate date];
    newLibrary.dateModified = [newLibrary.dateCreated copy];
    [self generateBookcasesForLibrary:newLibrary withDimensions:@{@1:@1}];
    newLibrary.name = @"New Library";

    return newLibrary;
}

//#pragma mark - helper methods

    // ===================== CoreData additions here

#pragma mark - ***** CoreData *****
#pragma mark  Fetch Data


    ///Get the root item, "RootCollections".
- (void)fetchData
{
    [self generateDefaultLibraryIfNeeded];
    NSFetchRequest *librariesFetchRequest = [NSFetchRequest fetchRequestWithEntityName:[Library entityName]];
    NSSortDescriptor *orderSorter = [NSSortDescriptor sortDescriptorWithKey:@"orderWhenListed" ascending:YES];
    librariesFetchRequest.sortDescriptors = @[orderSorter];
    NSError *error = nil;
    self.libraries = [self.managedObjectContext executeFetchRequest:librariesFetchRequest error:&error];
    self.currentLibrary = self.libraries[0];
}

- (void)saveContext
{
    NSError *error = nil;
    if (self.managedObjectContext != nil) {
        if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
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
        DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
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

/**
 *  1) The set of all books...      (fetch request entity)
 *  2) ...in the current library,   (predicate)
 *  3) ...arranged by mainCategory, (sectionKeyPath & sort descriptor)
 *  4) ...then author,              (sortDescriptor)
 *  5) ...then year.                (sortDescriptor)
 */
-(NSFetchedResultsController *)currentLibraryVolumesFetchedResultsController
{
        ///!!!: Ugly! Get rid of it!
    [self generateDefaultLibraryIfNeeded];
    
        //Section Key Path (nil == "no sections")
    NSString *sectionNameKeyPath = @"mainCategory";

        //Managed Object Context
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    
        //Fetch Request
    NSFetchRequest *volumesRequest    = [NSFetchRequest fetchRequestWithEntityName:[Volume entityName]];//(1)
    NSSortDescriptor *categorySorter  = [NSSortDescriptor sortDescriptorWithKey:sectionNameKeyPath ascending:YES];
    NSSortDescriptor *authorSorter    = [NSSortDescriptor sortDescriptorWithKey:@"authorSurname" ascending:YES];
    NSPredicate *libraryPredicate     = [NSPredicate predicateWithFormat:@"%K = %@", @"library.name", self.currentLibrary.name];
    volumesRequest.sortDescriptors    = @[categorySorter, authorSorter];
    volumesRequest.predicate          = libraryPredicate;
    volumesRequest.fetchBatchSize     = 200;
    
        //Unique cache name
    NSString *currentLibraryCacheName = [NSString stringWithFormat:@"%@-volumes", self.currentLibrary.name];
    
    
    NSFetchedResultsController *frc  = [[NSFetchedResultsController alloc]
                                        initWithFetchRequest:volumesRequest
                                        managedObjectContext:managedObjectContext
                                        sectionNameKeyPath:sectionNameKeyPath
                                        cacheName:currentLibraryCacheName];

        //Magic happens here.
    NSError *error = nil;
    if (![frc performFetch:&error]) {
        DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
    }
    return frc;
}    

//-(NSFetchedResultsController *)currentLibraryVolumesFetchedResultsController:(UIViewController<NSFetchedResultsControllerDelegate> *)sender
//{
//    NSFetchedResultsController *frc = [self currentLibraryVolumesFetchedResultsController];
//    frc.delegate = sender;
//    
//    return frc;
//}

#pragma mark - Generate Data
- (void)generateTestDataIfNeeded
{
    LBRGoogleGTLClient *googleClient = [LBRGoogleGTLClient sharedGoogleGTLClient];
    [self generateDefaultLibraryIfNeeded];

    BOOL libraryIsNotEmpty = @(self.currentLibrary.volumes.count).boolValue;
    if (libraryIsNotEmpty)
        return;
    
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
            Volume *volume = [Volume insertNewObjectIntoContext:self.managedObjectContext initializedFromGoogleBooksObject:responseVolume withCovertArt:YES];
            [volume.correspondingImageData downloadImagesIfNeeded];
        }];
    }
    
    [self saveContext];
    [self fetchData];
}

/**
 One of three possibilities:
 1) rootCollection already is Ready (exists and points to the right object).
 2) NSUserDefaults has the object, we just need rootCollection to point to it.
 3) We have not yet saved the ID to user defaults in the first place!
 
 RootCollection is the 'master object' that holds a reference to the entire object graph.
 */
-(RootCollection *)userRootCollection
{
//        (1)
    if (_rootCollection != nil)
        return _rootCollection;

//        (2)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *uri = [defaults URLForKey:[RootCollection entityName]];
    if (uri) {
        NSManagedObjectID *moID = [self.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
        NSError *error = nil;
        return [self.managedObjectContext existingObjectWithID:moID error:&error];
    }
    
//        (3)
    else
    {
        RootCollection *newRootCollection = [RootCollection insertNewObjectIntoContext:self.managedObjectContext];
        newRootCollection.libraries = [NSSet setWithArray:self.libraries];
        [self saveContext];
        [defaults setURL:newRootCollection.objectID.URIRepresentation forKey:[RootCollection entityName]];
        
        return newRootCollection;
    }
}


/**
 *  Seeds the dataManager's currentLibrary property. 
 *  Should only necessary for generating test data.
 */
-(void)generateDefaultLibraryIfNeeded {
    
    if (self.userRootCollection.libraries.count)
    {
        self.currentLibrary = [self.userRootCollection firstLibrary];
    }
    else
    {
        Library *newDefaultLibrary = [Library insertNewObjectIntoContext:self.managedObjectContext];
        newDefaultLibrary.name            = @"Default Library";
        newDefaultLibrary.orderWhenListed = @0;
        newDefaultLibrary.dateCreated     = [NSDate date];
        newDefaultLibrary.dateModified    = [NSDate date];
        self.currentLibrary               = newDefaultLibrary;
        
        [self generateDefaultBookcaseIfNeeded];
        
            //Saving changes the objectID from temp to permanent.
        [self saveContext];
        
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setURL:newDefaultLibrary.objectID.URIRepresentation forKey:[NSString stringWithFormat:@"Library-%@", newDefaultLibrary.orderWhenListed]];
    }
}

-(void)generateDefaultBookcaseIfNeeded
{
    (self.currentLibrary)? :[self generateDefaultLibraryIfNeeded];
    
    if (self.currentLibrary.bookcases.count) {
        self.currentBookcase = [self.currentLibrary.bookcases firstObject];
        return;
    }
    else
    {
        Bookcase *newDefaultBookcase       = [Bookcase insertNewObjectIntoContext:self.managedObjectContext withDefaultValues:YES];
        newDefaultBookcase.orderWhenListed = @(self.currentLibrary.bookcases.count);//This works. Think about it.
        newDefaultBookcase.library         = self.currentLibrary;
        self.currentBookcase               = newDefaultBookcase;
    }
}


    /**
     The keys are # of shelves, the objects are the widths.
     */
- (void)generateBookcasesForLibrary:(Library *)library withDimensions:(NSDictionary <NSNumber*, NSNumber*> *)dimensions
{
   __block NSNumber *idx = @(library.bookcases.count);
    [dimensions enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull numShelves, NSNumber * _Nonnull shelfWidth, BOOL * _Nonnull stop) {
        
        Bookcase *bookcase = [Bookcase insertNewObjectIntoContext:self.managedObjectContext];

        idx                      = @(idx.integerValue +1);
        bookcase.orderWhenListed = idx;
        bookcase.shelves         = numShelves;
        bookcase.width           = shelfWidth;
        bookcase.library         = library;
        bookcase.dateCreated     = [NSDate date];
        bookcase.dateModified    = [bookcase.dateCreated copy];
    }];
}

#pragma mark - data migration related (limited use)

-(void)giveCurrentLibraryADateIfNeeded
{
    if (!self.currentLibrary.dateCreated) {
        self.currentLibrary.dateCreated  = [NSDate date];
        self.currentLibrary.dateModified = [self.currentLibrary.dateCreated copy];
    }
}


-(void)giveVolumeADateIfNeeded:(Volume*)volume
{
    if (!volume.dateCreated) {
        volume.dateCreated  = [NSDate date];
        volume.dateModified = [volume.dateCreated copy];
    }
}

@end
