//
//  LBR_BookcaseLayoutAttributes.m
//  
//
//  Created by Amitai Blickstein on 10/15/15.
//
//

#import "LBR_BookcaseLayoutAttributes.h"

@implementation LBR_BookcaseLayoutAttributes

-(id)copyWithZone:(NSZone *)zone
{
    LBR_BookcaseLayoutAttributes *attributes = [super copyWithZone:zone];
    
    attributes.layoutMode = self.layoutMode;

    return attributes;
}

-(BOOL)isEqual:(id)object
{
    return [super isEqual:object] && (self.layoutMode == [object layoutMode]);
}

@end
