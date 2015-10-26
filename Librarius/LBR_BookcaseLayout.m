//
//  LBR_BookcaseLayout.m
//  Librarius
//
//  Created by Amitai Blickstein on 10/15/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//
#define kDefaulCellDimension 106.0
#define kDefaultCellSize CGSizeMake(kDefaulCellDimension, kDefaulCellDimension)

#define INSET_TOP      1.0
#define INSET_LEFT     1.0
#define INSET_BOTTOM   1.0
#define INSET_RIGHT    1.0


#import "LBR_BookcaseLayout.h"
#import "LBR_BookcaseCollectionViewController.h"
#import "LBR_BookcaseModel.h"


@interface LBR_BookcaseLayout ()

@property (nonatomic, strong) NSMutableDictionary *attributesForCells;


@property (nonatomic, assign) NSUInteger widestShelfWidth;
@property (nonatomic, assign) CGSize contentSize;
//@property (nonatomic, strong) NSArray <NSArray <Volume *> *> *filledBookcaseModel;

@property (nonatomic, strong) NSDictionary *layoutInformation;
@property (nonatomic, assign) UIEdgeInsets insets;

@property (nonatomic, assign) NSUInteger currentShelfIndex;
@property (nonatomic, assign) NSUInteger bookOnShelfCounter;
@property (nonatomic, strong) LBR_BookcaseModel *bookcaseModel;



@end

@implementation LBR_BookcaseLayout

/**
 
 */

-(instancetype)init
{
    if (!(self = [super init])) return nil;
    
    self.insets = UIEdgeInsetsMake(INSET_TOP, INSET_LEFT, INSET_BOTTOM, INSET_RIGHT);
    self.currentShelfIndex  = 0;
    self.bookOnShelfCounter = 0;
    
    self.interItemSpacing  = 1.0;
    self.interShelfSpacing = 1.0;
    
    return self;
}

/**
 +Iterate over every cell,
 -produce a layouts attribute object for each one
 --This is where we encapsulate and bury the confusing logic**
 -and then cache the info in the layoutInformation dictionary by indexPath.

 **"Confusing Logic"
 === Iterate through each cell, increment through the bookcaseModel each time.
 
 */

#pragma mark - === Overridden Methods ===

-(void)prepareLayout {
    
    NSMutableDictionary *mutableLayoutInformation = [NSMutableDictionary dictionary];
    NSIndexPath *indexPath;
    
    self.currentShelfIndex  = 0;
    self.bookOnShelfCounter = 0;
    self.bookcaseModel      = [self configuredBookcaseModel];
    
    NSInteger numSections = [self.collectionView numberOfSections];
    
    for (NSUInteger section = 0; section < numSections; section++) {
        NSUInteger numItems = [self.collectionView numberOfItemsInSection:section];
        
        for (NSUInteger item = 0; item < numItems; item++) {
                //Many things need to happen here:
                ///First, create an attributes object for each cell (keyed to indexPath, provided by the collectionView's dataSource.
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            
                ///Next, set the origin and size for each cell.
            CGPoint origin = [self originPointForBook:self.bookOnShelfCounter onShelf:self.currentShelfIndex];
            attributes.frame = CGRectMake(origin.x, origin.y, kDefaulCellDimension, kDefaulCellDimension);
            [self incrementBookcaseModelByOneBook];
            
            [mutableLayoutInformation setObject:attributes forKey:indexPath];
        }
    }
    self.layoutInformation = [mutableLayoutInformation copy];
    self.contentSize = [self extrapolatedContentSize];
}

-(CGSize)collectionViewContentSize
{
    return CGSizeMake(10000, 10000);
//    return self.contentSize;
}


-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
        //Check for all elements that are in the rect, and add the corresponding attributes
        //to the array, which is then returned.
    NSMutableArray *attributeObjectsToReturn = [NSMutableArray array];
    
    for (UICollectionViewLayoutAttributes *attributes in [self.layoutInformation allValues]) {
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            [attributeObjectsToReturn addObject:attributes];
        }
    }
    
    return [attributeObjectsToReturn copy];
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.layoutInformation[indexPath];
}

#pragma mark - Helper methods


    /// Essentially, this depends on how many cells are being shown, plus the spaces at the ends
    ///  and the spaces in between.
-(CGSize)extrapolatedContentSize
{
    CGFloat cellCountForLongestShelf = 0;
    for (NSArray *shelf in self.bookcaseModel.shelves) {
        cellCountForLongestShelf = MAX(cellCountForLongestShelf, shelf.count);
    }
        /// There is always one fewer interspace than # of cells, e.g.:
        /// InsetL-[cell#1]-#1-[cell#2]-#2-[cell#3]-InsetR
        /// , so we subtract one inter_spacing.
    CGFloat xMax = INSET_LEFT + (kDefaulCellDimension + self.interItemSpacing) * cellCountForLongestShelf - self.interItemSpacing + INSET_RIGHT;
    CGFloat yMax = INSET_TOP + (kDefaulCellDimension + self.interShelfSpacing) * self.bookcaseModel.shelves.count - self.interShelfSpacing + INSET_BOTTOM;
    
    return CGSizeMake(xMax, yMax);
}

-(LBR_BookcaseModel *)configuredBookcaseModel {
    LBR_BookcaseModel *bookcaseModel = [[LBR_BookcaseModel alloc] initWithWidth:kDefaultBookcaseWidth_cm shelvesCount:kDefaultBookcaseShelvesCount];
    LBR_BookcaseCollectionViewController *collectionViewController = (LBR_BookcaseCollectionViewController *)self.collectionView.dataSource;
        
    [bookcaseModel shelveBooks:collectionViewController.fetchedResultsController.fetchedObjects];
    return bookcaseModel;
}



-(void)incrementBookcaseModelByOneBook {
    NSArray *currentShelf = self.bookcaseModel.shelves[self.currentShelfIndex];

    NSUInteger maxShelvesCount = self.bookcaseModel.shelves.count;
    
        //If more books fit on this shelf, according to the model.
    if (self.bookOnShelfCounter < currentShelf.count)
    {
        self.bookOnShelfCounter++;
        return;
    }

        //If this book was the last book (or over?) on the current shelf,
        //AND there are more empty shelves, then we know to make our book
        //the first book on the next shelf (instead of the 'over-last' one on this shelf).
    if (self.bookOnShelfCounter >= currentShelf.count &&
        self.currentShelfIndex + offBy1 < maxShelvesCount)
    {
        self.currentShelfIndex++;
        self.bookOnShelfCounter = 0;
        return;
    }
        //If all shelves are full - no more shelves.
    if (self.currentShelfIndex + offBy1 >= maxShelvesCount)
        return;
    
    
}

-(CGPoint)originPointForBook:(NSUInteger)bookCounter onShelf:(NSUInteger)shelfIndex {
    CGFloat xPosition = INSET_LEFT + bookCounter * (kDefaulCellDimension + self.interItemSpacing);
    CGFloat yPosition = INSET_TOP  + shelfIndex  * (kDefaulCellDimension + self.interShelfSpacing);
    return CGPointMake(xPosition, yPosition);
}

@end
