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
+(instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context withDefaultValues:(BOOL)defaultValueChoice;
+(instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context withNumberOfShelves:(NSNumber*)numShelves width:(NSNumber*)width_cm;

-(CGFloat)percentFull;

/**
    This returns a dictionary to replace these two properties.
    (I also made a Value Transformer, but haven't tested nor relied on it).
     @property (nonatomic, strong) NSArray<NSArray *> *shelves;
     @property (nonatomic, strong) NSArray<Volume  *> *unshelvedRemainder;
*/
-(NSDictionary*)shelvedAndRemainingBooks:(NSArray <Volume *> *)booksArray;

@end

NS_ASSUME_NONNULL_END

#import "Bookcase+CoreDataProperties.h"


