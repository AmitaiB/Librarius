//
//  Volume.h
//  Librarius
//
//  Created by Amitai Blickstein on 10/29/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bookcase, CoverArt, Library;

NS_ASSUME_NONNULL_BEGIN

@interface Volume : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+ (NSString *)entityName;
+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context;


-(NSString*)isbn;

-(void)updateCoverArtModelIfNeeded;

@end

NS_ASSUME_NONNULL_END

#import "Volume+CoreDataProperties.h"
