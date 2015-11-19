//
//  Library.m
//  Librarius
//
//  Created by Amitai Blickstein on 10/29/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "Library.h"
#import "Bookcase.h"
#import "Volume.h"
#import "LBRDataManager.h"

@implementation Library

// Insert code here to add functionality to your managed object subclass
+(NSString *)entityName
{
    return @"Library";
}

+(instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
}


    //TODO: This logic is flawed in SO many edge cases. Needs major overhauling.
-(void)shelveVolumesOnBookcasesAccordingToLayoutScheme:(LBRLayoutScheme)layoutScheme
{
    LBRDataManager *dataManager = [LBRDataManager sharedDataManager];
//    NSFetchedResultsController *volumesInCurrentLibraryFRC = [dataManager currentLibraryVolumesFetchedResultsController];
//    NSArray *allVolumesInCurrentLibrary = volumesInCurrentLibraryFRC.fetchedObjects;
    NSArray *allVolumesInCurrentLibrary = [self.volumes
                                           sortedArrayUsingDescriptors:@[dataManager.sortDescriptors[kCategorySorter],
                                                                         dataManager.sortDescriptors[kAuthorSorter],
                                                                         dataManager.sortDescriptors[kDateCreatedSorter]]];

        //Prepare for for-loop
    NSArray *bookcasesInListOrder = [self.bookcases sortedArrayUsingDescriptors:@[dataManager.sortDescriptors[kOrderSorter]]];
    
    DDLogInfo(@"bookcasesInListOrder = %@", bookcasesInListOrder);
    
    /**
     1 -
     2 - Shelve the remaining books.
     3 - Add the shelved bookcase to our Library model's array.
     4 - Reset the remaining volumes for the next cycle of the loop.
     */
    NSArray <Volume*> *remainderVolumes = allVolumesInCurrentLibrary; //This is just the initial value.
    NSDictionary *shelvedAndRemainingBooks;
    
    for (Bookcase *bookcase in bookcasesInListOrder) {
        shelvedAndRemainingBooks = [bookcase shelvedAndRemainingBooks:remainderVolumes];
        remainderVolumes = shelvedAndRemainingBooks[kUnshelvedRemainder];

            ///???: How do I store and persist this?
        shelvedAndRemainingBooks[kShelvesArray];
    }
}


@end
