//
//  LBR_TemporaryFlowLayout.m
//  Librarius
//
//  Created by Amitai Blickstein on 10/26/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBR_TemporaryFlowLayout.h"

@implementation LBR_TemporaryFlowLayout

-(instancetype)init
{
    if (!(self = [super init])) return nil;
    
    self.itemSize                = kMaxItemSize;
    self.sectionInset            = UIEdgeInsetsMake(1, 1, 1, 1);
    self.minimumInteritemSpacing = 1.0;
    self.minimumLineSpacing      = 1.0;
    
    return self;
}

+(Class)layoutAttributesClass
{
    return [LBR_BookcaseLayoutAttributes class];
}

#pragma mark - Helper methods

-(void)applyLayoutAttributes:(LBR_BookcaseLayoutAttributes *)attributes
{
        //nil == cell.
    if (attributes.representedElementKind == nil) {
        attributes.layoutMode = self.layoutMode;
        
        if (<#condition#>) {
            <#statements#>
        }
    }
}

@end
