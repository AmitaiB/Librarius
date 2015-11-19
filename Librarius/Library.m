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
-(void)shelveVolumesOnBookcases
{
    LBRDataManager *dataManager = [LBRDataManager sharedDataManager];
    NSFetchedResultsController *volumesInCurrentLibraryFRC = [dataManager currentLibraryVolumesFetchedResultsController];
    NSArray *allVolumesInCurrentLibrary = volumesInCurrentLibraryFRC.fetchedObjects;
    
        //Prepare for for-loop
    NSArray *bookcasesInListOrder = [self.bookcases sortedArrayUsingDescriptors:@[dataManager.sortDescriptors[kOrderSorter]]];
    
    NSArray <Volume*> *remainderVolumes = allVolumesInCurrentLibrary; //This is just the initial value.
    NSDictionary *shelvedAndRemainingBooks;
    /**
     1 -
     2 - Shelve the remaining books.
     3 - Add the shelved bookcase to our Library model's array.
     4 - Reset the remaining volumes for the next cycle of the loop.
     */
    for (Bookcase *bookcase in bookcasesInListOrder) {
        bookcase.library = self;
        shelvedAndRemainingBooks = [bookcase shelvedAndRemainingBooks:remainderVolumes];
        remainderVolumes = shelvedAndRemainingBooks[kUnshelvedRemainder];
    }
}

@end
