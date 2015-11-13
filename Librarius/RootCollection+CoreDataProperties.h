//
//  RootCollection+CoreDataProperties.h
//  Librarius
//
//  Created by Amitai Blickstein on 11/12/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "RootCollection.h"

NS_ASSUME_NONNULL_BEGIN

@interface RootCollection (CoreDataProperties)

@property (nullable, nonatomic, retain) NSSet<Library *> *libraries;

@end

@interface RootCollection (CoreDataGeneratedAccessors)

- (void)addLibrariesObject:(Library *)value;
- (void)removeLibrariesObject:(Library *)value;
- (void)addLibraries:(NSSet<Library *> *)values;
- (void)removeLibraries:(NSSet<Library *> *)values;

@end

NS_ASSUME_NONNULL_END
