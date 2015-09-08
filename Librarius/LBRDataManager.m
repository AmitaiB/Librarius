//  LBRDataManager.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/26/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
////

#import "LBRDataManager.h"
#import "Library.h"
#import "Bookcase.h"
#import "Volume.h"
#import "LBRParsedVolume.h"
#import <GTLBooksVolume.h>
#import "LBRGoogleGTLClient.h"

#define DBLG NSLog(@"<%@:%@:line %d, reporting!>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);

@implementation LBRDataManager
@synthesize responseCollectionOfPotentialVolumeMatches = _responseCollectionOfPotentialVolumeMatches;


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
    self = [super init];
    if (!self) {
        return nil;
    }
    _uniqueCodes = [NSMutableArray new];
//FIXME:    _googleClient = [LBRGoogleGTLClient sharedGoogleGTLClient];
    _parsedVolumesToEitherSaveOrDiscard = [NSMutableArray new];
    _parsedVolumeFromLastBarcode = [LBRParsedVolume new];
    _responseCollectionOfPotentialVolumeMatches = [GTLBooksVolumes new];
    _libraries = @[];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNewParsedVolumeNotification:) name:@"newParsedVolumeNotification" object:nil]; DBLG
    
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  Upon receiving a new parsedVolume, the dataManager is notified, 
 *
 *  @param volumeToAdd <#volumeToAdd description#>
 *  @param saveContext <#saveContext description#>
 */

-(void)receivedNewParsedVolumeNotification:(NSNotification*)notification {
    
}

//-(void)addParsedVolumeToCurrentLibrary:(LBRParsedVolume*)volumeToAdd andSaveContext:(BOOL)saveContext {
//    DBLG
//    
//    [self generateDefaultLibraryIfNeeded];
//    
//    Volume *managedVolumeToAdd;
//    
//    [self.currentLibrary addVolumesObject:];
//    
//    self.parsedVolumeFromLastBarcode = [[LBRParsedVolume alloc] initWithGoogleVolume:volumeToAdd];
//    
//    newLBRVolume.isbn13    = self.parsedVolumeFromLastBarcode.isbn13;
//    newLBRVolume.isbn10    = self.parsedVolumeFromLastBarcode.isbn10;
//    newLBRVolume.title     = self.parsedVolumeFromLastBarcode.title;
//    newLBRVolume.pageCount = self.parsedVolumeFromLastBarcode.pageCount;
//    newLBRVolume.thickness = self.parsedVolumeFromLastBarcode.thickness;
//    newLBRVolume.height    = self.parsedVolumeFromLastBarcode.height;
//    newLBRVolume.cover_art = self.parsedVolumeFromLastBarcode.cover_art;
//    newLBRVolume.author    = self.parsedVolumeFromLastBarcode.author;
//    newLBRVolume.category  = self.parsedVolumeFromLastBarcode.category;
//    newLBRVolume.published = self.parsedVolumeFromLastBarcode.published;
//    newLBRVolume.rating    = self.parsedVolumeFromLastBarcode.rating;
//    newLBRVolume.google_id = self.parsedVolumeFromLastBarcode.google_id;
//    
//    
//    if (saveContext) {
//        [self saveContext];
//    }
//}


/**
 *  CLEAN: was made obselete by addParsedVolumeToCurrentLibrary
 *
 *  @param volumeToAdd <#volumeToAdd description#>
 *  @param saveContext <#saveContext description#>
 */
-(void)addGTLVolumeToCurrentLibrary:(GTLBooksVolume*)volumeToAdd andSaveContext:(BOOL)saveContext {
    DBLG
    if (!self.currentLibrary) {
        self.currentLibrary = [NSEntityDescription insertNewObjectForEntityForName:@"Library" inManagedObjectContext:self.managedObjectContext];
    }
    Volume *newLBRVolume = [NSEntityDescription insertNewObjectForEntityForName:@"Volume" inManagedObjectContext:self.managedObjectContext];
    [self generateDefaultLibraryIfNeeded];
    
    [self.currentLibrary addVolumesObject:newLBRVolume];
    
    self.parsedVolumeFromLastBarcode = [[LBRParsedVolume alloc] initWithGoogleVolume:volumeToAdd];
    
    newLBRVolume.isbn13    = self.parsedVolumeFromLastBarcode.isbn13;
    newLBRVolume.isbn10    = self.parsedVolumeFromLastBarcode.isbn10;
    newLBRVolume.title     = self.parsedVolumeFromLastBarcode.title;
    newLBRVolume.pageCount = self.parsedVolumeFromLastBarcode.pageCount;
    newLBRVolume.thickness = self.parsedVolumeFromLastBarcode.thickness;
    newLBRVolume.height    = self.parsedVolumeFromLastBarcode.height;
    newLBRVolume.cover_art = self.parsedVolumeFromLastBarcode.cover_art;
    newLBRVolume.author    = self.parsedVolumeFromLastBarcode.author;
    newLBRVolume.category  = self.parsedVolumeFromLastBarcode.category;
    newLBRVolume.published = self.parsedVolumeFromLastBarcode.published;
    newLBRVolume.rating    = self.parsedVolumeFromLastBarcode.rating;
    newLBRVolume.google_id = self.parsedVolumeFromLastBarcode.google_id;
    
   
    if (saveContext) {
        [self saveContext];
    }
}

-(void)saveParsedVolumesToEitherSaveOrDiscardToPersistentStore {
        // 1. LBRParsedVolume → NSManagedObject
        // 2. Repeat for all volumes.
        // 3. Save context.
        // 4. Test.
    for (LBRParsedVolume *transientVolumeToSave in self.parsedVolumesToEitherSaveOrDiscard) {
        Volume *persistentVolume = [NSEntityDescription insertNewObjectForEntityForName:@"Volume" inManagedObjectContext:self.managedObjectContext];
        persistentVolume.isbn10 = transientVolumeToSave.isbn10;
        persistentVolume.isbn13 = transientVolumeToSave.isbn13;
        persistentVolume.title = transientVolumeToSave.title;
        persistentVolume.thickness = transientVolumeToSave.thickness;
        persistentVolume.height = transientVolumeToSave.height;
        persistentVolume.pageCount = transientVolumeToSave.pageCount;
        persistentVolume.cover_art_large = transientVolumeToSave.cover_art_large;
        persistentVolume.cover_art = transientVolumeToSave.cover_art;
        persistentVolume.author = transientVolumeToSave.author;
        persistentVolume.category = transientVolumeToSave.category;
        persistentVolume.published = transientVolumeToSave.published;
        persistentVolume.rating = transientVolumeToSave.rating;
        persistentVolume.google_id = transientVolumeToSave.google_id;
        persistentVolume.library = self.currentLibrary;
    }

    [self saveContext];
        NSLog(@"Context saved with new volumes to current library.");
}

-(void)logCurrentLibrary {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Volume"];
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:nil];
    NSLog(@"Fetched volumes from Core Data: %@", [results description]);
}

#pragma mark - helper methods

-(NSString*)stringWithOnlyNumbersFrom:(NSString*)string {
    return [[string componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet]invertedSet]]componentsJoinedByString:@""];
}

-(NSString*)lastNameFrom:(NSString*)fullName {
    return [fullName componentsSeparatedByString:@" "][1];
}


// ===================== CoreData additions here

#pragma mark - CoreData
#pragma mark Fetch Data

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
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


#pragma mark - Core Data stack
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
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
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
    
        //This error reporting is not strictly necessary.
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            // Report any error we got.
        NSMutableDictionary *dict              = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey]        = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey]             = error;
        error                                  = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
            //Replace this with code to handle the error appropriately.
            //abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
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

#pragma mark - Generate Data
//The completion block needs //to be tailored for each request.
//    Either /*that, or have*/ lots of repeating code.
- (void)generateTestDataIfNeeded
{
    LBRGoogleGTLClient *googleClient = [LBRGoogleGTLClient sharedGoogleGTLClient];
    
        //Books need a library for a home!
    [self generateDefaultLibraryIfNeeded];
    if (self.currentLibrary.volumes.count) {
        return;}
//    Only if the library is empty, generate testData.
    
    /**
     *  Given an array of ISBNs, populate the DB
     */

    NSArray *listOfISBNs = @[@"978-1-60309-050-6",
                             @"978-1-60309-266-1",
                             @"978-1-60309-025-4",
                             @"978-1-60309-239-5",
                             @"978-1-60309-042-1"];
    
    for (NSString *ISBN in listOfISBNs) {
        [googleClient queryForVolumeWithString:ISBN withCallback:^(GTLBooksVolume *responseVolume) {
            [self addGTLVolumeToCurrentLibrary:responseVolume andSaveContext:NO];
        }];
    }
    
    [self saveContext];
    [self fetchData];
}

/**
 *  If there's a library, do nothing. If there's no library, make one. And log any errors, of course.
 */
-(void)generateDefaultLibraryIfNeeded {
    NSFetchRequest *libraryRequest = [NSFetchRequest fetchRequestWithEntityName:@"Library"];
    NSError *error = nil;
    
    BOOL datastoreHasAtLeastOneLibrary = [self.managedObjectContext countForFetchRequest:libraryRequest error:&error] >= 1;
    
    if (datastoreHasAtLeastOneLibrary) {
        self.currentLibrary = [[self.managedObjectContext executeFetchRequest:libraryRequest error:nil] firstObject];
    } else {
        Library *newDefaultLibrary = [NSEntityDescription insertNewObjectForEntityForName:@"Library" inManagedObjectContext:self.managedObjectContext];
        newDefaultLibrary.name = @"Home Library";
        newDefaultLibrary.orderWhenListed = @1;
        self.currentLibrary = newDefaultLibrary;
        [self saveContext];
    }
}


@end
