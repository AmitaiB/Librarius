//
//  LBRDataManager.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/26/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBRDataManager.h"
#import "Library.h"
#import "Bookcase.h"
#import "Volume.h"
#import "NSString+dateValue.h"

#define DBLG NSLog(@"%@ reporting!", NSStringFromSelector(_cmd));

#define CALIPER [@"436" floatValue] //In pages per inch, ppi.
/**
Typical uncoated digital book paper calipers:

50-lb. natural high bulk, 456 PPI.
60-lb. natural trade book, 436 PPI.
80-lb. white opaque smooth, 382 PPI.
 */

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

/**
 *  This will translate a GoogleBooks volume object into our NSManagedObject.
 */
-(void)addGTLVolumeToCurrentLibrary:(GTLBooksVolume*)volumeToAdd {
    DBLG
    
    Volume *newLBRVolume = [NSEntityDescription insertNewObjectForEntityForName:@"Volume" inManagedObjectContext:self.managedObjectContext];
    [self generateDefaultLibraryIfNeeded];
    
    [self.currentLibrary addVolumesObject:newLBRVolume];
    
    /**
     *  Default Values
     */
    newLBRVolume.isbn13    = [NSString new];
    newLBRVolume.isbn10    = [NSString new];
    newLBRVolume.title     = [NSString new];
    newLBRVolume.pageCount = nil;
    newLBRVolume.thickness = nil;
    newLBRVolume.height    = nil;
    newLBRVolume.cover_art = @"https://www.google.com";
    newLBRVolume.author    = @"John Doe";
    newLBRVolume.category  = @"General Literature";
    newLBRVolume.published = [NSDate distantPast];
    newLBRVolume.rating    = nil;
    newLBRVolume.google_id = [NSString new];
    
    /**
     *  ISBN
     */
    for (NSDictionary *industryIDer in volumeToAdd.volumeInfo.industryIdentifiers) {
        if ([industryIDer[@"type"] isEqualToString:@"ISBN_13"]) {
            newLBRVolume.isbn13 = industryIDer[@"identifier"];
        }
        if ([industryIDer[@"type"] isEqualToString:@"ISBN_10"]) {
            newLBRVolume.isbn10 = industryIDer[@"identifier"];
        }
    }
    
    /**
     *  Title
     */
    if (volumeToAdd.volumeInfo.title.length > 0) {
        newLBRVolume.title = volumeToAdd.volumeInfo.title;
    }
    
    /**
     *  PageCount
     */
    if ([volumeToAdd.volumeInfo.pageCount integerValue] > 0) {
        newLBRVolume.pageCount = volumeToAdd.volumeInfo.pageCount;
    } else if ([volumeToAdd.volumeInfo.printedPageCount integerValue] > 0) {
        newLBRVolume.pageCount = volumeToAdd.volumeInfo.printedPageCount;
    }
    
    
    /**
     *  Height, in inches (from cm), if the information is present.
     */
    NSNumber *height = @([volumeToAdd.volumeInfo.dimensions.height floatValue] / 2.54);
    if ([height floatValue] > 0.0) {
        newLBRVolume.height = height;
    }
    /**
     *  Thickness of the book's spine, in inches (from cm). If not given, it will be estimated from the pagecount, if it is defined.
     */
    NSNumber *thickness = @([volumeToAdd.volumeInfo.dimensions.thickness floatValue] / 2.54);
    
    if ([thickness floatValue] > 0.0) {
        newLBRVolume.thickness = thickness;
    }
    else if (newLBRVolume.pageCount) {
        newLBRVolume.thickness = @([newLBRVolume.pageCount floatValue] / CALIPER);
    }
    
    /**
     *  Cover Art URL
     */
    if (volumeToAdd.volumeInfo.imageLinks.thumbnail) {
        newLBRVolume.cover_art = volumeToAdd.volumeInfo.imageLinks.thumbnail;
    }
    else if (volumeToAdd.volumeInfo.imageLinks.smallThumbnail) {
        newLBRVolume.cover_art = volumeToAdd.volumeInfo.imageLinks.smallThumbnail;
    }
    
    /**
     *  Author(s).
     */
    NSUInteger numberOfAuthors = volumeToAdd.volumeInfo.authors.count;
    if (!numberOfAuthors) {
            //Do nothing
    } else if (numberOfAuthors == 1) {
            newLBRVolume.author = volumeToAdd.volumeInfo.authors[0];
    } else if (numberOfAuthors >=2) {
        newLBRVolume.author = [volumeToAdd.volumeInfo.authors componentsJoinedByString:@" & "];
    }
    
    /**
     *  Date of publication.
     */
    if (volumeToAdd.volumeInfo.publishedDate) {
        newLBRVolume.published = [volumeToAdd.volumeInfo.publishedDate dateValue];
    }
    
    /**
     *  Average rating. TODO: ../ratingsCount?
     */
    if (volumeToAdd.volumeInfo.averageRating) {
        newLBRVolume.rating = volumeToAdd.volumeInfo.averageRating;
    }
    
    /**
     *  Google ID for the volume. Vital!
     */
    
    newLBRVolume.google_id = volumeToAdd.identifier;
    
    
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

- (void)generateTestData
{
    LBRGoogleGTLClient *googleClient = [LBRGoogleGTLClient sharedGoogleGTLClient];
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
        GTLBooksVolume *tempVolume = [googleClient queryForVolumeWithISBN:ISBN returnTicket:NO];
        [self addGTLVolumeToCurrentLibrary:tempVolume];
    }
//
//    GTLBooksVolume *the120DaysGTL = [googleClient queryForVolumeWithISBN:@"978-1-60309-050-6" returnTicket:NO];
//    
//    [self addGTLVolumeToCurrentLibrary:the120DaysGTL];
//
//    Volume *the120Days = [NSEntityDescription insertNewObjectForEntityForName:@"Volume" inManagedObjectContext:self.managedObjectContext];
    
    [self saveContext];
    [self fetchData];
}

-(void)generateDefaultLibraryIfNeeded {
    NSFetchRequest *libraryRequest = [NSFetchRequest fetchRequestWithEntityName:@"Library"];
    NSError *error = nil;
    if ([self.managedObjectContext countForFetchRequest:libraryRequest error:&error]) {
            //It goes without saying:
        if (error) {DBLG NSLog(@"Error: %@", error.localizedDescription);}
            // Back to the condition: If there's a library, Do nothing.
    } else {
        Library *newDefaultLibrary = [NSEntityDescription insertNewObjectForEntityForName:@"Library" inManagedObjectContext:self.managedObjectContext];
        [self saveContext];
        self.currentLibrary = newDefaultLibrary;
    }
}


@end
