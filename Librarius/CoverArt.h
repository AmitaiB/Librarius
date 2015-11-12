//
//  CoverArt.h
//  Librarius
//
//  Created by Amitai Blickstein on 10/29/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Volume;

NS_ASSUME_NONNULL_BEGIN

@interface CoverArt : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+(NSString *)entityName;
+(instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context;


-(void)downloadImagesForCorrespondingVolume:(Volume *)volume;
-(void)downloadImagesIfNeeded;
-(UIImage *)preferredImageLarge;
-(UIImage *)preferredImageSmall;


-(BOOL)hasNoImages;

@end

NS_ASSUME_NONNULL_END

#import "CoverArt+CoreDataProperties.h"
