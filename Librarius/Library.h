//
//  Library.h
//  
//
//  Created by Amitai Blickstein on 9/3/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bookcase, Volume;

@interface Library : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * orderWhenListed;
@property (nonatomic, retain) Bookcase *bookcases;
@property (nonatomic, retain) NSSet *volumes;
@end

@interface Library (CoreDataGeneratedAccessors)

- (void)addVolumesObject:(Volume *)value;
- (void)removeVolumesObject:(Volume *)value;
- (void)addVolumes:(NSSet *)values;
- (void)removeVolumes:(NSSet *)values;

@end
