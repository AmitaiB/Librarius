//
//  LBR_ShelvesModelTransformer.m
//  Librarius
//
//  Created by Amitai Blickstein on 11/18/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBR_ShelvesModelTransformer.h"

@implementation LBR_ShelvesModelTransformer

+(BOOL)allowsReverseTransformation
{
    return YES;
}

+(Class)transformedValueClass
{
    return [NSData class];
}

    //Takes an NSArray <NSArray <Volume*>*>*> bookshelvesModelArray
    //and turns it into NSData.
-(id)transformedValue:(id)value
{
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

-(id)reverseTransformedValue:(id)value
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end
