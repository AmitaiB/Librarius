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
    _sortDescriptors = @{kOrderSorter      : [NSSortDescriptor sortDescriptorWithKey:@"orderWhenListed" ascending:YES],
                         kCategorySorter   : [NSSortDescriptor sortDescriptorWithKey:@"mainCategory" ascending:YES],
                         kAuthorSorter     : [NSSortDescriptor sortDescriptorWithKey:@"authorSurname" ascending:YES],
                         kDateCreatedSorter: [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]
                        };
    return self;
}

    //debug-related
-(void)logCurrentLibrary {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[Volume entityName]];
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:nil];
    DDLogVerbose(@"(logCurrentLibrary, ln. 54) Fetched volumes from Core Data: %@", [results description]);
}

/**
 FIXME: Where does this filter by "current library"?!? 
 */
-(void)logCurrentLibraryTitles:(NSString*)debugString
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[Volume entityName]];
    NSArray <Volume*> *results = [self.managedObjectContext executeFetchRequest:request error:nil];
    __block NSMutableArray <NSString*> *prettyResults = [NSMutableArray array];
    [results enumerateObjectsUsingBlock:^(Volume * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [prettyResults addObject:[obj fullTitle]? [obj fullTitle] : @"Nully"];
    }];
    DDLogInfo(@"(logCurrentLibraryTitles, ln. 68) === Called by %@ === \nTitles of fetched volumes from Core Data:", debugString);
    for (NSString *title in prettyResults) {
        DDLogVerbose(@"\t%@", title);
    }
    DDLogVerbose(@"=== END ===\n");
}

-(void)deleteAllObjectsOfEntityName:(NSString*)entityName
{
    NSFetchRequest *deleteRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];
    NSBatchDeleteRequest *batchDeleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:deleteRequest];
    NSError *deleteError = nil;
    [self.persistentStoreCoordinator executeRequest:batchDeleteRequest withContext:self.managedObjectContext error:&deleteError];
}


-(Library *)insertNewLibrary
{
    Library *newLibrary = [Library insertNewObjectIntoContext:self.managedObjectContext];
    newLibrary.dateCreated = [NSDate date];
    newLibrary.dateModified = [newLibrary.dateCreated copy];
    [self generateBookcasesForLibrary:newLibrary withDimensions:@{@1:@1}];
    newLibrary.name = @"New Library";

    return newLibrary;
}

    ///???:What is this "data closet" pattern??
#pragma mark - === "data closet" methods ===

/**
 *  1) The set of all books...      (fetch request entity)
 *  2) ...in the current library,   (predicate)
 *  3) ...arranged by mainCategory, (sectionKeyPath & sort descriptor)
 *  4) ...then author,              (sortDescriptor)
 *  5) ...then year.                (sortDescriptor)
 */

-(NSFetchRequest *)volumesRequest
{
    if (_volumesRequest != nil)
        return _volumesRequest;
    
    NSFetchRequest *volumesRequest    = [NSFetchRequest fetchRequestWithEntityName:[Volume entityName]];//(1)
    
        ///FIXME: THIS IS A CORE FEATURE. #1 FIX PRIORITY
//    volumesRequest.predicate          = [NSPredicate predicateWithFormat:@"%K LIKE %@", @"library.name", self.currentLibrary.name];
    volumesRequest.sortDescriptors    = @[self.sortDescriptors[kCategorySorter], self.sortDescriptors[kAuthorSorter]];
    volumesRequest.fetchBatchSize     = 200;
    
    return volumesRequest;
}


-(NSFetchedResultsController *)currentLibraryVolumesFetchedResultsController
{
        ///!!!: Ugly! Get rid of it!
        //    [self generateDefaultLibraryIfNeeded];
    
        //Section Key Path (nil == "no sections")
    NSString *sectionNameKeyPath = @"mainCategory";
    
        //Unique cache name
    NSString *currentLibraryCacheName = [NSString stringWithFormat:@"%@Cache-volumes", self.currentLibrary.name];
    
    NSFetchedResultsController *frc  = [[NSFetchedResultsController alloc]
                                        initWithFetchRequest:[self volumesRequest]
                                        managedObjectContext:[self managedObjectContext]
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

-(NSFetchedResultsController *)currentLibraryVolumesFetchedResultsController:(UIViewController<NSFetchedResultsControllerDelegate> *)sender
{
    NSFetchedResultsController *frc = [self currentLibraryVolumesFetchedResultsController];
    frc.delegate = sender;
    
    return frc;
}

-(NSFetchRequest *)bookcasesRequest
{
    if (_bookcasesRequest != nil)
        return _bookcasesRequest;
    
    NSFetchRequest *bookcasesRequest = [NSFetchRequest fetchRequestWithEntityName:[Bookcase entityName]];
    
    bookcasesRequest.fetchBatchSize = 200;
    bookcasesRequest.sortDescriptors = @[self.sortDescriptors[kOrderSorter], self.sortDescriptors[kDateCreatedSorter]];
    bookcasesRequest.returnsObjectsAsFaults = NO;

    return bookcasesRequest;
}

-(NSFetchedResultsController *)currentLibraryBookcasesFetchedResultsController
{
    NSFetchedResultsController *frc;
    /**
     *  1) The set of all [Entity Name]
     *  2) ...arranged by userOrder,
     *  3) ...then date created.
     */
        //Ugly! get rid of it.
//        [self generateDefaultLibraryIfNeeded];
    
    
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
    frc = [[NSFetchedResultsController alloc] initWithFetchRequest:self.bookcasesRequest
                                              managedObjectContext:self.managedObjectContext
                                                sectionNameKeyPath:@"library.name"
                                                         cacheName:@"LBR_Bookcase_CacheName"];
    
    NSError *error = nil;
    if (![frc performFetch:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. !!!:You should not use this function in a shipping application, although it may be useful during development.
        DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
        // CLEAN: Default bookcases should not be needed.
     
     NSArray *bookcases = [frc.managedObjectContext executeFetchRequest:self.bookcasesRequest error:nil];
    
    if (bookcases.count == 0) {
        [self generateBookcasesForLibrary:self.currentLibrary withDimensions:@{@3 : @7}];
        [frc performFetch:nil];
    }
    
    
    return frc;
}

-(NSFetchedResultsController *)currentLibraryBookcasesFetchedResultsController:(UIViewController<NSFetchedResultsControllerDelegate> *)sender
{
    NSFetchedResultsController *frc = [self currentLibraryBookcasesFetchedResultsController];
    frc.delegate = sender;
    return frc;
}

//#pragma mark - Generate Data
///Not called. If you can demonstrate that this method will not BE needed, CLEAN:
/**
- (void)generateTestDataIfNeeded
{
    LBRGoogleGTLClient *googleClient = [LBRGoogleGTLClient sharedGoogleGTLClient];
    [self generateDefaultLibraryIfNeeded];

    BOOL libraryIsNotEmpty = @(self.currentLibrary.volumes.count).boolValue;
    if (libraryIsNotEmpty)
        return;
    
    /**
     *  Given an array of ISBNs, populate the DB.
     * /
    NSArray *listOfISBNs = @[@"978-1-60309-050-6",
                             @"978-1-60309-266-1",
                             @"978-1-60309-025-4",
                             @"978-1-60309-239-5",
                             @"978-1-60309-042-1"];
    
    
    for (NSString *ISBN in listOfISBNs) {
        [googleClient queryForVolumeWithString:ISBN withCallback:^(GTLBooksVolume *responseVolume) {
            Volume *volume = [Volume insertNewObjectIntoContext:self.managedObjectContext initializedFromGoogleBooksObject:responseVolume withCovertArt:YES];
            [volume.correspondingImageData downloadImagesIfNeeded];
            volume.library = self.currentLibrary;
        }];
    }
    
    [self saveContext];
    [self fetchData];
}
*/


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
    if (_userRootCollection != nil)
        return _userRootCollection;

//        (2)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *uri = [defaults URLForKey:[RootCollection entityName]];
    if (uri != nil) {
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

-(Library *)currentLibrary
{
        //Normal case, but we check that rootCollection is set.
        //If rootCollection = nil, things will fail silently.
    if (_currentLibrary != nil) {
        if (_currentLibrary.rootCollection == nil) {
            _currentLibrary.rootCollection = self.userRootCollection;
        }
        return _currentLibrary;
    }
    else //If currentLibrary = nil, create a new one.
    {
            //First attempt to retrieve an existing library from the object graph...
        if (self.userRootCollection.libraries.count >= 1)
        {
             return _currentLibrary = [self.userRootCollection firstLibrary];
        }
        else
        {
            Library *newDefaultLibrary = [Library insertNewObjectIntoContext:self.managedObjectContext];
            newDefaultLibrary.name            = @"Default Library";
            newDefaultLibrary.orderWhenListed = @0;
            newDefaultLibrary.dateCreated     = [NSDate date];
            newDefaultLibrary.dateModified    = [newDefaultLibrary.dateCreated copy];
            newDefaultLibrary.rootCollection  = self.userRootCollection;
//            [self generateDefaultBookcaseIfNeeded];
            
                //Saving changes the objectID from temp to permanent.
            [self saveContext];
            
            return _currentLibrary = newDefaultLibrary;
        }
    }
}


/**
 *  Seeds the dataManager's currentLibrary property. 
 *  Should only necessary for generating test data.
 */

    ///Should be able to remove.
-(void)generateDefaultLibraryIfNeeded {
    
    if (self.userRootCollection.libraries.count >= 1)
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
        newDefaultLibrary.rootCollection  = self.userRootCollection;
        self.currentLibrary               = newDefaultLibrary;
        
//        [self generateDefaultBookcaseIfNeeded];
        
            //Saving changes the objectID from temp to permanent.
        [self saveContext];
        
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setURL:newDefaultLibrary.objectID.URIRepresentation forKey:[NSString stringWithFormat:@"Library-%@", newDefaultLibrary.orderWhenListed]];
        [defaults synchronize];
    }
}

/**
 *  Inserts new Bookcase objects into the current library's managed object context,
 *  with a relationship to the entered library.
 *  @param library    The library that will be related to the Bookcases
 *  @param dimensions The keys are # of shelves, the objects are the widths.
 */
- (void)generateBookcasesForLibrary:(Library *)library withDimensions:(NSDictionary <NSNumber*, NSNumber*> *)dimensions
{
//   __block NSNumber *idx = @(library.bookcases.count);
    [dimensions enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull numShelves, NSNumber * _Nonnull shelfWidth, BOOL * _Nonnull stop) {
        
        Bookcase *bookcase = [Bookcase insertNewObjectIntoContext:self.managedObjectContext];

//        idx                      = @(idx.integerValue +1);
//        bookcase.orderWhenListed = idx;
        bookcase.orderWhenListed = @(library.bookcases.count);
        bookcase.library         = library;

        bookcase.dateCreated     = [NSDate date];
        bookcase.dateModified    = [bookcase.dateCreated copy];
        bookcase.shelves         = numShelves;
        bookcase.width           = shelfWidth;
        bookcase.isFull          = @NO;
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


#pragma mark - == debug related ==

    //Make a new Library object, copy all properties.
    //Make new Volume objects from the old ones, copying all properties.
    //Relate the new Volume objects to the new Library.
    //Relate the new Library to the userRootCollection.
    //Delete the old objects.
    //New Library -> shelve the books.

    ///CLEAN: Never called! This was DEBUG ONLY anyway, right? UPDATE: May come in handy
    ///when I debug the library methods.
/**
-(void)refreshLibrary:(Library *)oldLibrary
{
        //Managed Object Context
    LBRDataManager *dataManager = [LBRDataManager sharedDataManager];
    NSManagedObjectContext *moc = dataManager.managedObjectContext;
    [moc deleteObject:oldLibrary];
    
        //New Library
    Library *newLibrary = [Library insertNewObjectIntoContext:moc];
    newLibrary.dateCreated = [oldLibrary.dateCreated copy];
    newLibrary.dateModified = [NSDate date];
    newLibrary.libraryPhoto = [oldLibrary.libraryPhoto copy];
    newLibrary.name = [oldLibrary.name copy];
    newLibrary.orderWhenListed = [oldLibrary.orderWhenListed copy];
    newLibrary.rootCollection = oldLibrary.rootCollection;
    
        //New Bookcases
    [oldLibrary.bookcases enumerateObjectsUsingBlock:^(Bookcase * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [moc deleteObject:obj];
        Bookcase *bookcase = [Bookcase insertNewObjectIntoContext:moc];
        bookcase.library   = newLibrary;
        
        bookcase.dateCreated     = [obj.dateCreated copy];
        bookcase.dateModified    = [NSDate date];
        bookcase.name            = obj.name;
        bookcase.orderWhenListed = obj.orderWhenListed;
        bookcase.shelf_height    = [obj.shelf_height copy];
        bookcase.shelves         = [obj.shelves copy];
        bookcase.width           = [obj.width copy];

//        bookcase.shelvesArray    = [obj.shelvesArray copy]; ///  <~ Not used anymore.
    }];
    
        //New Volumes/Books
    [oldLibrary.volumes enumerateObjectsUsingBlock:^(Volume * _Nonnull obj, BOOL * _Nonnull stop)
    {
        [moc deleteObject:obj];
        Volume *volume           = [Volume insertNewObjectIntoContext:moc];
        volume.library           = newLibrary;
        
        volume.author            = [obj.author copy];
        volume.authorSurname     = [obj.authorSurname copy];
        volume.avgRating         = [obj.avgRating copy];
        volume.cover_art         = [obj.cover_art copy];
        volume.cover_art_large   = [obj.cover_art_large copy];
        volume.dateCreated       = [obj.dateCreated copy];
        volume.dateModified      = [NSDate date];
        volume.google_id         = [obj.google_id copy];
        volume.height            = [obj.height copy];
        volume.isbn10            = [obj.isbn10 copy];
        volume.isbn13            = [obj.isbn13 copy];
        volume.mainCategory      = [obj.mainCategory copy];
        volume.pageCount         = [obj.pageCount copy];
        volume.publDescription   = [obj.publDescription copy];
        volume.published         = [obj.published copy];
        volume.publisher         = [obj.publisher copy];
        volume.rating            = [obj.rating copy];
        volume.ratingsCount      = [obj.ratingsCount copy];
        volume.subtitle          = [obj.subtitle copy];
        volume.thickness         = [obj.thickness copy];
        volume.title             = [obj.title copy];
        volume.secondaryCategory = [obj.secondaryCategory copy];
        volume.tertiaryCategory  = [obj.tertiaryCategory copy];
        
        [volume updateCoverArtModelIfNeeded];
    }];
    [dataManager saveContext];
    dataManager.currentLibrary = newLibrary;
}
*/



@end

