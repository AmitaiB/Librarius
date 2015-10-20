//
//  LBRFlowLayout.m
//  Librarius
//
//  Created by Amitai Blickstein on 10/20/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBRFlowLayout.h"

@implementation LBRFlowLayout

-(instancetype)init
{
    if (!(self = [super init])) return nil;
    
        //Basic properties.
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.estimatedItemSize = CGSizeMake(106.0, 106.0);
    
    self.minimumLineSpacing = 1.0f;
    self.minimumInteritemSpacing = 1.0f;
    
    return self;
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

@end
