//
//  Bookcase+CoreDataProperties.m
//  Librarius
//
//  Created by Amitai Blickstein on 12/3/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Bookcase+CoreDataProperties.h"

@implementation Bookcase (CoreDataProperties)

@dynamic dateCreated;
@dynamic dateModified;
@dynamic isFull;
@dynamic name;
@dynamic orderWhenListed;
@dynamic shelf_height;
@dynamic shelves;
@dynamic shelvesArray;
@dynamic width;
@dynamic laidOutShelvesModel;
@dynamic library;
@dynamic volumes;

@end
