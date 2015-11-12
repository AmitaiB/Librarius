//
//  Bookcase.m
//  Librarius
//
//  Created by Amitai Blickstein on 10/29/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "Bookcase.h"
#import "Library.h"
#import "Volume.h"

@implementation Bookcase

// Insert code here to add functionality to your managed object subclass
+(NSString *)entityName
{
    return @"Bookcase";
}

+(instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
}

@end
