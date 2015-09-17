//
//  PHGCustomLayout.m
//  PhotoGallery
//
//  Created by Joe Keeley on 7/21/13.
//  Copyright (c) 2013 ICF. All rights reserved.
//

#import "LBRCustomLayout.h"
#import "LBRShelvedBookCollectionViewCell.h"
#import "UIImage+imageScaledToHeight.h"
#import "LBRDataManager.h"
#import "BookCollectionViewController.h"

#define kCellDefaultDimension 106.0f//assumes square cell
#define kHorizontalInset      10.0f //on the left and right
#define kHorizontalSpace      1.0f  //horizontal space between cells
#define kSectionHeight        20.0f

#define kCenterXPosition      160.0f

@interface LBRCustomLayout ()
@property (nonatomic, strong) NSMutableDictionary *centerPointsForCells;
@property (nonatomic, strong) NSMutableArray *rectsForSectionHeaders;
@property (nonatomic, assign) CGSize defaultItemSize;
@property (nonatomic, assign) CGFloat interItemSpacingX;
@property (nonatomic) UIEdgeInsets insets;
@property (nonatomic) NSUInteger shelvesPerBookcase;
@property (nonatomic) CGFloat bookcaseWidth_cm;

@property (nonatomic, strong) NSDictionary *layoutInfo;
@property (nonatomic, strong) NSMutableDictionary *rectsForCells;
@property (nonatomic) CGFloat max_X;


@end

@implementation LBRCustomLayout

static NSString * const LBRShelvedBookCollectionViewCellKind = @"coverArtCell";

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setup];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.insets = UIEdgeInsetsMake(22.0f, kHorizontalInset,
                                   13.0f, kHorizontalInset);
    self.defaultItemSize = CGSizeMake(106.0f, 106.0f);
    self.interItemSpacingX = 1.0f;
    self.shelvesPerBookcase = 5;
    self.bookcaseWidth_cm = 55.0f;
}



/**
 *  CLEAN: ICF method.
 */
//- (CGFloat)calculateSineXPositionForY:(CGFloat)yPosition
//{
//    CGFloat currentTime = (yPosition / self.collectionView.bounds.size.height);
//    
//    CGFloat sineCalc = kMaxAmplitude * sinf(2 * kPi * currentTime);
//    CGFloat adjustedXPosition = sineCalc + kCenterXPosition;
//    return adjustedXPosition;
//}


/**
 *  Apple's recommended approach for layouts which change infrequently
 *  and hold hundreds of items (rather than thousands) is to calculate
 *  and cache all of the layout information upfront and then access that
 *  cache when the collection view requests it.
 *   Taking my cue from ICF (Richter & Keeley 2015) and some blogs (e.g., 
 *  http://skeuo.com/uicollectionview-custom-layout-tutorial ), this will
 *  be done with Dictionaries that have (conveniently ordered) indexPath(s)
 *  as keys. Advance one indexPath/key, and you get the next cell's layout
 *  attributes (see the nested for-loop below).
 */
- (void)prepareLayout
{
    /**
     * Note: The sections from the Fetched Results Controller are book "categories", not shelves.
     */
    NSInteger sectionCount = [self.collectionView numberOfSections];

    /**
     *  Track the x-position for laying out, the center points for the cells. X-position
     *  will move like a typewriter. Once we run out of room on a line, we reset. Thus:
        [x] yPosition is a f(shelf#), itself a f(books' spines' thicknesses).
        [x] xPosition is a f(previous book's rect).
     
     */
    CGFloat currentYPosition    = 0.0;
    CGFloat currentXPosition    = 0.0; // derived from combined images
    
    NSUInteger currentShelfPosition_cm = 0.0;
    NSIndexPath *indexPath      = [NSIndexPath indexPathForItem:0 inSection:0]; // The longest indexPath begins with the first step.
    
    self.centerPointsForCells   = [NSMutableDictionary new]; // ... but just in case.
    self.rectsForSectionHeaders = [NSMutableArray new];
    
    NSMutableDictionary *newLayoutInfo          = [NSMutableDictionary new];
    NSMutableDictionary *cellLayoutInfo         = [NSMutableDictionary new];
    NSMutableDictionary *leadingPathsForShelves = [NSMutableDictionary new];
 
    
    for (NSUInteger section = 0; section < sectionCount; section++) {
        NSUInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        for (NSUInteger item = 0; item < itemCount; item++) {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            
            itemAttributes.frame = [self frameForCoverArtImageAtIndexPath:indexPath];
            
            cellLayoutInfo[indexPath] = itemAttributes;
        }
    }
    
    newLayoutInfo[LBRShelvedBookCollectionViewCellKind] = cellLayoutInfo;
    
    self.layoutInfo = newLayoutInfo;
}

#pragma mark - Helper methods (aka private)
/**
 *  Constructs the new item's frame from the coords (= where the last cell "left off"
 *  + whatever inset is specified) and the frame (standard height, scaled width).
 *
 *  @param indexPath <#indexPath description#>
 *
 *  @return <#return value description#>
 */
- (CGRect) frameForCoverArtImageAtIndexPath:(NSIndexPath*)indexPath {
    CGRect newFrame;
    CGFloat width;
    
    NSIndexPath *previousIndexPath = ([indexPath indexPathByRemovingLastIndex])?
    [indexPath indexPathByRemovingLastIndex] : nil;
    if (previousIndexPath) {
        UICollectionViewLayoutAttributes *previousItemsAttributes = self.layoutInfo[previousIndexPath];
        CGRect previousRect = previousItemsAttributes.frame;
        CGFloat newX = CGRectGetMaxX(previousRect) + self.interItemSpacingX;
        CGFloat newY = CGRectGetMinY(previousRect);
        
        self.max_X = MAX(self.max_X, newX);
        
            //
    
        width = [self widthForCellAtIndexPath:indexPath];
        newFrame = CGRectMake(newX, newY, width, kCellDefaultDimension);
    } else {
        newFrame = CGRectMake(kHorizontalInset, kSectionHeight, width, kCellDefaultDimension);
    }
    
    return newFrame;
}

// Retrieve the width of the current cell's coverArt.
-(CGFloat)widthForCellAtIndexPath:(NSIndexPath*)indexPath {
    BookCollectionViewController *bookCollectionVC = self.collectionView/*something something...
                                                                         we need to track the books' combined thickness so that we can see when the typewriter has hit the end of the line, and needs to be reset at the next shelf (until we run out of books, or run out of shelves).
                                                                         
                                                                         */;
    NSFetchedResultsController *fetchedResultsController = bookCollectionVC.fetchedResultsController;
    
    LBRShelvedBookCollectionViewCell *cell = (LBRShelvedBookCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    UIImage *scaledImage = [UIImage imageWithImage:cell.imageView.image scaledToHeight:kCellDefaultDimension];
    CGFloat width = (scaledImage.size.width)? scaledImage.size.width : kCellDefaultDimension;
    return width;
}

-(CGFloat)bookThicknessForCellAtIndexPath:(NSIndexPath*)indexPath {
    LBRShelvedBookCollectionViewCell *cell = (LBRShelvedBookCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    
    CGFloat thickness;
    return thickness;
}

-(CGFloat)yPositionForShelf:(NSUInteger)shelfNum {
#warning This should be non-zero.
    return 0.0f;
}

/**
 *  We start off by creating a mutable array where we can store all the attributes that need to be returned. Next we're going to take advantage of the nice block-based dictionary enumeration to cruise through our layoutInfo dictionary. The outer block iterates through each of the sub-dictionaries we've added (only the cells at the moment), then we iterate through each cell in the sub-dictionary. CGRectIntersectsRect makes it simple to check if the cell we're looking at intersects with the rect that was passed in. If it does, we add it to the array we'll be passing back.
 */
-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    
    [self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier, NSDictionary *elementsInfo, BOOL *stop) {
        [elementsInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attributes, BOOL *innerStop) {
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [allAttributes addObject:attributes];
            }
        }];
    }];
    
    return allAttributes;
}

/**
 *  All we're doing here is looking up the sub-dictionary for cells and then returning the layout attributes for a cell at the passed in index path.
 */
-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.layoutInfo[LBRShelvedBookCollectionViewCellKind][indexPath];
}

-(CGSize)collectionViewContentSize {
    CGFloat max_Y = self.shelvesPerBookcase * (kSectionHeight + kCellDefaultDimension) + kSectionHeight;
    return CGSizeMake(self.max_X, max_Y);
}

@end