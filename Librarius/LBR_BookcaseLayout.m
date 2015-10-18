//
//  LBR_BookcaseLayout.m
//  Librarius
//
//  Created by Amitai Blickstein on 10/15/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//
#define kDefaulCellDimension 106.0
#define kDefaultCellSize CGSizeMake(kDefaulCellDimension, kDefaulCellDimension)


#import "LBR_BookcaseLayout.h"


@interface LBR_BookcaseLayout ()
@property (nonatomic, strong) NSMutableDictionary *centerPointsForCells;
@property (nonatomic, strong) NSMutableDictionary *framesForCells;


@property (nonatomic, assign) NSUInteger widestShelfWidth;
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, strong) NSArray <NSArray <Volume *> *> *filledBookcaseModel;

@end

@implementation LBR_BookcaseLayout

/**
 
 */

-(void)prepareLayout {
    NSAssert(self.filledBookcaseModel, @"BookcaseMode not initialized.");
    
    
    
    
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes new];
    attributes.size = kDefaultCellSize;
    attributes.center = CGPointMake(kDefaultCellSize.width * (0.5 + 0), kDefaultCellSize.height * (0.5 + 0));
    
}

-(CGSize)contentSize {

}

-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
        //Check for all elements that are in the rect, and add the corresponding attributes
        //to the array, which is then returned.
    NSMutableArray *attributeObjectsToReturn = [NSMutableArray new];
    for (<#type *object#> in <#collection#>) {
        <#statements#>
    }
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
