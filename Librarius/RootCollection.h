//
//  RootCollection.h
//  Librarius
//
//  Created by Amitai Blickstein on 11/12/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Library;

NS_ASSUME_NONNULL_BEGIN

@interface RootCollection : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+(NSString *)entityName;
+(instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context;

-(Library*)firstLibrary;

@end

NS_ASSUME_NONNULL_END

#import "RootCollection+CoreDataProperties.h"
