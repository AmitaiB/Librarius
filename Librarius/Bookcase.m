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

+(instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context withDefaultValues:(BOOL)defaultValueChoice
{
    Bookcase *bookcase = [Bookcase insertNewObjectIntoContext:context];
    
    if (defaultValueChoice) {
        bookcase.orderWhenListed = @0;
        bookcase.dateCreated     = [NSDate date];
        bookcase.dateModified    = [bookcase.dateCreated copy];
        bookcase.shelves         = @(kDefaultBookcaseShelvesCount);
        bookcase.width           = @(kDefaultBookcaseWidth_cm);
    }
    return bookcase;
}

-(CGFloat)percentFull
{
    CGFloat totalShelfSpace = self.width.floatValue * self.shelves.floatValue;
    __block CGFloat occupiedShelfSpace = 0;
    [self.volumes enumerateObjectsUsingBlock:^(Volume * _Nonnull volume, BOOL * _Nonnull stop) {
        occupiedShelfSpace += volume.thickness? volume.thickness.floatValue : 2.5f;
    }];
    
    return occupiedShelfSpace / totalShelfSpace * 100;
}

@end
