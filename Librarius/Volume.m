//
//  Volume.m
//  Librarius
//
//  Created by Amitai Blickstein on 10/29/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "Volume.h"
#import "Bookcase.h"
#import "CoverArt.h"
#import "Library.h"

@implementation Volume

// Insert code here to add functionality to your managed object subclass
///Credit for these two methods: https://www.objc.io/issues/4-core-data/core-data-models-and-model-objects/#creating-objects
+(NSString *)entityName
{
    return @"Volume";
}

+(instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
}

-(NSString *)isbn {
    return self.isbn13? self.isbn13 : self.isbn10? self.isbn10 : nil;
}

    ///Not sure if this is neccesary to trigger the loading of images in the CoverArt setter.
-(void)updateCoverArtModelIfNeeded
{
    if (self.correspondingImageData)
        [self.correspondingImageData downloadImagesIfNeeded];
}


@end
