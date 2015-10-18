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
#import "LBR_BookcaseModel.h"


@interface LBR_BookcaseLayout ()
@property (nonatomic, strong) NSMutableDictionary *centerPointsForCells;
@property (nonatomic, assign) NSUInteger widestShelfWidth;
@property (nonatomic, assign) CGSize contentSize;

@end

@implementation LBR_BookcaseLayout {
    LBR_BookcaseModel *bookcaseModel;
}

/**
 LATEST: As I understand it now, in prepare for layout, I will get the bookcase
 model to know which
 
 */

-(void)prepareLayout {
    bookcaseModel = self.dataSource.bookcaseModel;
    NSAssert(bookcaseModel, @"BookcaseMode not initialized.");
    
    for (NSUInteger i = 0; i < bookcaseModel.shelves.count; i++) {
        <#statements#>
    }
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
}


@end
