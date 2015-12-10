//
//  RootCollection.m
//  Librarius
//
//  Created by Amitai Blickstein on 11/12/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "RootCollection.h"
#import "Library.h"

@implementation RootCollection

// Insert code here to add functionality to your managed object subclass
+(NSString *)entityName
{
    return @"RootCollection";
}

+(instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
}

-(Library *)firstLibrary
{
    if (self.libraries.count == 1) {
        Library *theOnlyLibrary = [self.libraries allObjects][0];
        theOnlyLibrary.orderWhenListed = @0;
        theOnlyLibrary.rootCollection = self;
        return theOnlyLibrary;
    }
    
    if (self.libraries.count > 1) {
        NSSet *moreThanOneLibrary = [self.libraries objectsPassingTest:^BOOL(Library * _Nonnull obj, BOOL * _Nonnull stop) {
            return obj.orderWhenListed.integerValue == 0;
        }];
        
        /** Should not be necessary, since we got the libraries FROM the rootCollection in the first place.
        if (!([moreThanOneLibrary allObjects].count > 0)) {
            //DDLogWarn(@"RootCollection cannot retrieve firstLibrary - no Libraries attached.");
        }
         */
        
        Library *theZerothOrderLibrary = [moreThanOneLibrary allObjects][0];
        theZerothOrderLibrary.rootCollection = self;
        return theZerothOrderLibrary;
    }
    
    if (!self.libraries.count) {
        //DDLogWarn(@"User root collection is nil!");
        DBLG
    }
    return nil;
}

@end
