//
//  Bookcase.h
//  Librarius
//
//  Created by Amitai Blickstein on 10/29/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Library, Volume;

NS_ASSUME_NONNULL_BEGIN

@interface Bookcase : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+(NSString *)entityName;
+(instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context;

-(CGFloat)percentFull;

@end

NS_ASSUME_NONNULL_END

#import "Bookcase+CoreDataProperties.h"
