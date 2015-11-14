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

-(CGFloat)percentFull
{
    CGFloat totalShelfSpace = self.width.integerValue * self.shelves.integerValue;
    __block CGFloat occupiedShelfSpace = 0;
    [self.volumes enumerateObjectsUsingBlock:^(Volume * _Nonnull volume, BOOL * _Nonnull stop) {
        occupiedShelfSpace += volume.thickness? volume.thickness.floatValue : 2.5f;
    }];
    
    return occupiedShelfSpace / totalShelfSpace * 100;
}

@end
