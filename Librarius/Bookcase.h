//
//  Bookcase.h
//  Librarius
//
//  Created by Amitai Blickstein on 8/28/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Library, Volume;

@interface Bookcase : NSManagedObject

@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * shelves;
@property (nonatomic, retain) NSNumber * shelf_height;
@property (nonatomic, retain) Library *library;
@property (nonatomic, retain) Volume *volumes;

@end
