//
//  Bookcase+CoreDataProperties.h
//  Librarius
//
//  Created by Amitai Blickstein on 11/10/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Bookcase.h"

NS_ASSUME_NONNULL_BEGIN

@interface Bookcase (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *shelf_height;
@property (nullable, nonatomic, retain) NSNumber *shelves;
@property (nullable, nonatomic, retain) NSNumber *width;
@property (nullable, nonatomic, retain) NSDate *dateCreated;
@property (nullable, nonatomic, retain) NSDate *dateModified;
@property (nullable, nonatomic, retain) Library *library;
@property (nullable, nonatomic, retain) Volume *volumes;

@end

NS_ASSUME_NONNULL_END
