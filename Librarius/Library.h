//
//  Library.h
//  Librarius
//
//  Created by Amitai Blickstein on 8/28/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bookcase, Volume;

@interface Library : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Bookcase *bookcases;
@property (nonatomic, retain) Volume *volumes;

@end
