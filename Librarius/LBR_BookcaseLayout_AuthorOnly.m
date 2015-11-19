    ///FIRST FIX THE ORIGINAL LAYOUT, THEN COPY IT FOR THIS ONE.
//    
//  LBR_BookcaseLayout_AuthorOnly.m
//  Librarius
//
//  Created by Amitai Blickstein on 11/1/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#define kDefaulCellDimension 106.0
#define kDefaultCellSize CGSizeMake(kDefaulCellDimension, kDefaulCellDimension)

#define INSET_TOP    1.0
#define INSET_LEFT   1.0
#define INSET_BOTTOM 1.0
#define INSET_RIGHT  1.0

#define kMinimumLineSpacing 1.0
#define kMinimumItemSpacing 1.0

#define kDecorationYadjustment  13.0
#define kDecorationHeight       25.0

#import "LBR_BookcaseLayout_AuthorOnly.h"

#import "LBR_BookcaseCollectionViewController.h"
#import "LBR_BookcaseModel.h"
#import "LBRShelf_DecorationView.h"

@interface LBR_BookcaseLayout_AuthorOnly ()

@property (nonatomic, strong) NSMutableDictionary *attributesForCells;

@property (nonatomic, assign) NSUInteger widestShelfWidth;
@property (nonatomic, assign) NSUInteger cellCountForLongestRow;

@property (nonatomic, assign) CGSize contentSize;
    //@property (nonatomic, strong) NSArray <NSArray <Volume *> *> *filledBookcaseModel;

@property (nonatomic, strong) NSDictionary *layoutInformation;
@property (nonatomic, assign) UIEdgeInsets insets;


    //DecorationView
@property (nonatomic, strong) NSDictionary *rowDecorationRects;
    //@property (nonatomic) CGSize headerReferenceSize;
    //@property (nonatomic) CGSize footerReferenceSize;
    //@property (nonatomic) UIEdgeInsets sectionInset;


@property (nonatomic, assign) NSUInteger currentShelfIndex;
@property (nonatomic, assign) NSUInteger bookOnShelfCounter;
//@property (nonatomic, strong) LBR_BookcaseModel *bookcaseModel;
@end

@implementation LBR_BookcaseLayout_AuthorOnly

#pragma mark - == Lifecycle ==

-(instancetype)init
{
    if (!(self = [super init])) return nil;
    
    self.insets = UIEdgeInsetsMake(INSET_TOP, INSET_LEFT, INSET_BOTTOM, INSET_RIGHT);
    self.currentShelfIndex  = 0;
    self.bookOnShelfCounter = 0;
    
    self.interItemSpacing  = 1.0;
    self.interShelfSpacing = 1.0;
    
    [self registerClass:[LBRShelf_DecorationView class] forDecorationViewOfKind:[LBRShelf_DecorationView kind]];
    
    self.cellCountForLongestRow = 0;
    
    return self;
}


/**
 *** The Critical Business Logic ***
 +Iterate over every cell,
 -produce a layouts attribute object for each one
 --This is where we encapsulate and bury the confusing logic**
 -and then cache the info in the layoutInformation dictionary by indexPath.
 */
#pragma mark - === Overridden Methods ===

-(void)prepareLayout
{
    NSMutableDictionary *mutableLayoutInformation = [NSMutableDictionary dictionary];
    NSIndexPath *indexPath;
    
    self.currentShelfIndex  = 0;
    self.bookOnShelfCounter = 0;
//    self.bookcaseModel      = [self configuredBookcaseModel];
    
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
    
    [self prepareLayoutOfDecorationViews];
}

-(CGSize)collectionViewContentSize
{
    return self.contentSize;
}


-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
        //Check for all elements that are in the rect, and add the corresponding attributes
        //to the array, which is then returned.
    
        //First, Cell elements...
    NSMutableArray *attributeObjectsToReturn = [NSMutableArray array];
    
    for (UICollectionViewLayoutAttributes *attributes in [self.layoutInformation allValues]) {
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            [attributeObjectsToReturn addObject:attributes];
        }
    }
    
    NSMutableArray *decorationLayoutElements = [NSMutableArray array];
        //Next, decoration view elements...
    [self.rowDecorationRects enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, NSValue *rowRectValue, BOOL * stop) {
        
        if (CGRectIntersectsRect([rowRectValue CGRectValue], rect)) {
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:[LBRShelf_DecorationView kind] withIndexPath:indexPath];
            
            attributes.frame = [rowRectValue CGRectValue];
            attributes.zIndex = 0;
            [decorationLayoutElements addObject:attributes];
        }
    }];
    
    
    return [attributeObjectsToReturn arrayByAddingObjectsFromArray:decorationLayoutElements];
        //    return [attributeObjectsToReturn copy];
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.layoutInformation[indexPath];
}


#pragma mark - Helper methods
    /// Essentially, this depends on how many cells are being shown, plus the spaces at the ends
    ///  and the spaces in between.
-(CGSize)extrapolatedContentSize
{
    NSUInteger cellCountForLongestRow = [self extrapolatedCellCountForLongestRow];
        /// There is always one fewer interspace than # of cells, e.g.:
        /// InsetL-[cell#1]-#1-[cell#2]-#2-[cell#3]-InsetR
        /// , so we subtract one inter_spacing.
    CGFloat xMax = INSET_LEFT + (kDefaulCellDimension + self.interItemSpacing) *cellCountForLongestRow - self.interItemSpacing + INSET_RIGHT;
//    CGFloat yMax = INSET_TOP + (kDefaulCellDimension + self.interShelfSpacing) * self.bookcaseModel.shelves.count - self.interShelfSpacing + INSET_BOTTOM;
    CGFloat yMax = INSET_TOP + (kDefaulCellDimension + self.interShelfSpacing) * self.bookcaseModel.shelves.count - self.interShelfSpacing + INSET_BOTTOM;

    
    return CGSizeMake(xMax, yMax);
}

-(NSUInteger)extrapolatedCellCountForLongestRow
{
    if (self.cellCountForLongestRow == 0) {
        for (NSArray *shelf in self.bookcaseModel.shelves) {
            self.cellCountForLongestRow = MAX(self.cellCountForLongestRow, shelf.count);
        }
    }
    
    return self.cellCountForLongestRow;
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

-(void)prepareLayoutOfDecorationViews
{
    NSInteger numSections = [self.collectionView numberOfSections];
        //
        //    CGFloat availableWidth = self.collectionViewContentSize.width -
        //    (self.sectionInset.left + self.sectionInset.right);
        //
        //    NSInteger cellsPerRow = floorf((availableWidth + self.minimumInteritemSpacing) /
        //                                   (self.itemSize.width + self.minimumInteritemSpacing));
    
    NSUInteger cellCountForLongestRow = [self extrapolatedCellCountForLongestRow];
    
    NSMutableDictionary *rowDecorationWork = [NSMutableDictionary dictionary];
    
    CGFloat yPosition = 0;
    
    for (NSUInteger sectionIndex = 0; sectionIndex < numSections; sectionIndex++)
    {
        yPosition += INSET_TOP;
            //        yPosition += self.sectionInset.top;
        
            //        NSUInteger cellCount = [self.collectionView numberOfItemsInSection:sectionIndex];
        
            //        NSUInteger rows = ceilf(cellCount/(CGFloat)cellsPerRow);
        NSUInteger rows = self.bookcaseModel.shelvesCount;
        
        for (NSInteger row = 0; row < rows; row++) {
            yPosition += kDefaulCellDimension;
            
            CGRect decorationFrame = CGRectMake(0, yPosition - kDecorationYadjustment, self.collectionViewContentSize.width, kDecorationHeight);
            
            NSIndexPath *decorationIndexPath = [NSIndexPath indexPathForRow:row inSection:sectionIndex];
            
            rowDecorationWork[decorationIndexPath] = [NSValue valueWithCGRect:decorationFrame];
            
            if (row < rows - 1) {
                yPosition += kMinimumLineSpacing;
            }
            
                //            yPosition += self.sectionInset.bottom;
            yPosition += INSET_BOTTOM;
        }
        
        self.rowDecorationRects = [rowDecorationWork copy];
    }
}

@end
