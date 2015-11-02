    //
    //  NSString+ArrayWriter.m
    //  Attributed String Creator
    //
    //  Created by Mark Bridges on 15/10/2013.
    //  Copyright (c) 2013 Mark Bridges. All rights reserved.
    //

#import "NSString+ArrayWriter.h"

@implementation NSString (ArrayWriter)

+ (NSString *)stringWithArray:(NSArray *)array
{
    if (array.count == 0)
    {
        return @"";
    }
    else
    {
        NSMutableString *outputString = [[NSMutableString alloc]init];
        NSMutableArray *mutableArray = [[NSMutableArray alloc]initWithArray:array];
        if (mutableArray.count == 1)
        {
            [outputString appendString:mutableArray.firstObject];
        }
        else
        {
            [outputString appendString:mutableArray.firstObject];
            [mutableArray removeObjectAtIndex:0];
            for (NSString *currentString in mutableArray)
            {
                if (currentString != mutableArray.lastObject)
                {
                    [outputString appendString:[NSString stringWithFormat:@", %@", currentString]];
                }
                else
                {
                    [outputString appendString:[NSString stringWithFormat:@" and %@.", currentString]];
                }
            }
        }
        return outputString;
    }
}

@end
