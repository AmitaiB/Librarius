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

@end
