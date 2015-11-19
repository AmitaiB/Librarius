//
//  NSObject+ABBNumberUtils.h
//  Librarius
//
//  Created by Amitai Blickstein on 11/19/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#define ARC4RANDOM_MAX 0x100000000


#import <Foundation/Foundation.h>

@interface NSObject (ABBNumberUtils)

+(CGFloat)randomFloatBetweenNumber:(CGFloat)minRange andNumber:(CGFloat)maxRange;

@end
