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


/**
The Library shelves itself here, by progressively asking each related bookcase to shelve itself,
 and then pass on the remaining unshelved books to be shelved by the subsequent bookcase.
 
 Once
 1 - Get all books, and all bookcases, of the current library (via object graph).
 [NOTE: The books are ordered according to the sort descriptors in the dataManger, which *should* be
 updated to the user's preference.]
 
 2 - Enumerate/Loop through the bookcases until either (a) all shelves are full, or (b) no books remain:
  a- Bookcase shelves itself with remaining unshelved books.
  b- Bookcase updates the "unshelved books" array.
 */

-(NSArray*)shelveVolumesOnBookcasesAccordingToLayoutScheme:(LBRLayoutScheme)layoutScheme
{
    LBRDataManager *dataManager = [LBRDataManager sharedDataManager];
    
        /// 1 - Prepare for for-loop
    NSArray *allVolumesInThisLibrary = [self.volumes   sortedArrayUsingDescriptors:dataManager.volumesRequest.sortDescriptors];
    NSArray *bookcasesInOrder        = [self.bookcases sortedArrayUsingDescriptors:dataManager.bookcasesRequest.sortDescriptors];
    [bookcasesInOrder enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Bookcase *unshelvedBookcase = (Bookcase*)obj;
        unshelvedBookcase.isFull = @NO; //by-definition!
    }];
    NSArray <Volume*> *remainingUnshelvedVolumes = allVolumesInThisLibrary;//Initially, all volumes are unshelved.
    
        /// 2 - The magic happens here.
    for (Bookcase *bookcase in bookcasesInOrder)
    {
        remainingUnshelvedVolumes = [bookcase fillShelvesWithBooks:remainingUnshelvedVolumes];
    }
    
    return remainingUnshelvedVolumes;
}


@end
