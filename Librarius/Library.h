//
//  Library.h
//  Librarius
//
//  Created by Amitai Blickstein on 10/29/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class Bookcase, Volume;

NS_ASSUME_NONNULL_BEGIN

@interface Library : NSManagedObject

@property (nonatomic, strong) NSArray *bookcaseModels;

// Insert code here to declare functionality of your managed object subclass
+(NSString *)entityName;
+(instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context;

-(NSDictionary*)shelveVolumesOnBookcasesAccordingToLayoutScheme:(LBRLayoutScheme)layoutScheme;

@end

NS_ASSUME_NONNULL_END

#import "Library+CoreDataProperties.h"
