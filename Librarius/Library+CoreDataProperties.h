//
//  Library+CoreDataProperties.h
//  Librarius
//
//  Created by Amitai Blickstein on 11/10/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Library.h"

NS_ASSUME_NONNULL_BEGIN

@interface Library (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *dateCreated;
@property (nullable, nonatomic, retain) NSDate *dateModified;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *orderWhenListed;
@property (nullable, nonatomic, retain) Bookcase *bookcases;
@property (nullable, nonatomic, retain) NSSet<Volume *> *volumes;

@end

@interface Library (CoreDataGeneratedAccessors)

- (void)addVolumesObject:(Volume *)value;
- (void)removeVolumesObject:(Volume *)value;
- (void)addVolumes:(NSSet<Volume *> *)values;
- (void)removeVolumes:(NSSet<Volume *> *)values;

@end

NS_ASSUME_NONNULL_END
