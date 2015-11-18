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
        Library *aLibrary = [self.libraries allObjects][0];
        aLibrary.orderWhenListed = @0;
    }
    
    NSSet *libraryOfOne = [self.libraries objectsPassingTest:^BOOL(Library * _Nonnull obj, BOOL * _Nonnull stop) {
        return obj.orderWhenListed.integerValue == 0;
//        return obj.orderWhenListed.integerValue == 1;
    }];
    return [libraryOfOne allObjects][0];
}

@end
