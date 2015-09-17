//
//  PHGCustomLayout.m
//  PhotoGallery
//
//  Created by Joe Keeley on 7/21/13.
//  Copyright (c) 2013 ICF. All rights reserved.
//

#import "LBRCustomLayout.h"
#import "LBRShelvedBookCollectionViewCell.h"

#define kCellDefaultDimension   106.0 //assumes square cell
#define kHorizontalInset    10.0 //on the left and right
#define kVerticalSpace  1.0  //vertical space between cells
#define kSectionHeight  20.0
#define kCenterXPosition    160.0

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
     *  will move like a typewriter. Once we run out of room on a line, we reset
     */
    CGFloat currentXPosition    = 0.0;
    CGFloat currentYPosition    = 0.0;
    NSIndexPath *indexPath      = [NSIndexPath indexPathForItem:0 inSection:0];
    self.centerPointsForCells   = [NSMutableDictionary new];
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

- (CGRect) frameForCoverArtImageAtIndexPath:(NSIndexPath*)indexPath {
    NSIndexPath *previousIndexPath = [indexPath indexPathByRemovingLastIndex];
    CGRect *previousRect = (__bridge CGRect *)(self.rectsForCells[previousIndexPath]);
    
}




-(CGFloat)yPositionForShelf:(NSUInteger)shelfNum {
#warning This should be non-zero.
    return 0.0f;
}

@end
