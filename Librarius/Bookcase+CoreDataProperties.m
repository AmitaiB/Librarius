//
//  Bookcase+CoreDataProperties.m
//  Librarius
//
//  Created by Amitai Blickstein on 11/10/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Bookcase+CoreDataProperties.h"

@implementation Bookcase (CoreDataProperties)

@dynamic dateCreated;
@dynamic dateModified;
@dynamic shelf_height;
@dynamic shelves;
@dynamic width;
@dynamic orderWhenListed;
@dynamic library;
@dynamic volumes;

@end
