//
//  NSObject+ABBNumberUtils.m
//  Librarius
//
//  Created by Amitai Blickstein on 11/19/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "NSObject+ABBNumberUtils.h"

@implementation NSObject (ABBNumberUtils)

+(CGFloat)randomFloatBetweenNumber:(CGFloat)minRange andNumber:(CGFloat)maxRange
{
    return ((float)arc4random() / ARC4RANDOM_MAX) * (maxRange - minRange); //+ minRange;
}


@end
