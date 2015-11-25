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
 1 -
 2 - Shelve the remaining books.
 3 - Add the shelved bookcase to our Library model's array.
 4 - Reset the remaining volumes for the next cycle of the loop.
 */
    //TODO: This logic is flawed in SO many edge cases. Needs major overhauling.
-(NSDictionary*)shelveVolumesOnBookcasesAccordingToLayoutScheme:(LBRLayoutScheme)layoutScheme
{
    LBRDataManager *dataManager = [LBRDataManager sharedDataManager];
    
        //Prepare for for-loop
    NSArray *allVolumesInThisLibrary    = [self.volumes sortedArrayUsingDescriptors:dataManager.volumesRequest.sortDescriptors];
    NSArray *bookcasesInListOrder       = [self.bookcases sortedArrayUsingDescriptors:dataManager.bookcasesRequest.sortDescriptors];
    NSArray <Volume*> *asYetUnshelvedVolumes = allVolumesInThisLibrary;//Initially, all volumes are unshelved.
   
    DDLogInfo(@"bookcasesInListOrder.count = %lu", bookcasesInListOrder.count);
    NSDictionary *processedBooks;
    
    NSMutableDictionary *libraryLayoutDict = [NSMutableDictionary new];
    
    for (Bookcase *bookcase in bookcasesInListOrder)
    {
        if (!bookcase.name) bookcase.name = [NSString stringWithFormat:@"#%@", bookcase.orderWhenListed.stringValue];
        
        
        processedBooks        = [bookcase shelvedAndRemainingBooks:asYetUnshelvedVolumes]; //The magic happens here.
        asYetUnshelvedVolumes = processedBooks[kUnshelvedRemainder]; //sets up for the next loop iteration.
        [libraryLayoutDict setObject:processedBooks[kShelvesArray] forKey:[NSString stringWithFormat:@"%@-%@", [Bookcase entityName], bookcase.name]];
    }
        ///Add this library's layout plan to the public transient data.
        ///CLEAN: Destroy me!
//    [dataManager.transientLibraryLayoutInformation setObject:libraryLayoutDict forKey:[NSString stringWithFormat:@"%@-%@", [Library entityName], self.name]];
    
    return libraryLayoutDict;
}


@end
