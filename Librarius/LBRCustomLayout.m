//
//  PHGCustomLayout.m
//  PhotoGallery
//
//  Created by Joe Keeley on 7/21/13.
//  Copyright (c) 2013 ICF. All rights reserved.
//

#import "LBRCustomLayout.h"
#import "LBRShelvedBookCollectionViewCell.h" //TODO: <--comment this out and fix what breaks -- don't reference the cell, rather get the data from the model. Choose! Representational, or otherwise??
#import "UIImage+imageScaledToHeight.h"
#import "LBRDataManager.h"
#import "BookCollectionViewController.h"

#define kCellHeight 106.0f//for a square cell
#define kHorizontalInset      10.0f //on the left and right
#define kHorizontalSpace      1.0f  //horizontal space between cells
#define kSectionHeight        20.0f
#define offByOneAdjmt         1


@interface LBRCustomLayout ()
@property (nonatomic, strong) NSMutableDictionary *centerPointsForCells;
@property (nonatomic, strong) NSMutableArray *rectsForSectionHeaders;
@property (nonatomic, assign) CGSize defaultItemSize;
@property (nonatomic, assign) CGFloat interItemSpacingX;
@property (nonatomic) UIEdgeInsets insets;

@property (nonatomic) NSUInteger shelvesPerBookcase;
@property (nonatomic) CGFloat bookcaseWidth_cm;
@property (nonatomic) CGFloat xPosition_cm;
@property (nonatomic) NSUInteger shelfPosition;

@property (nonatomic, strong) NSDictionary *layoutInfo;
@property (nonatomic, strong) NSMutableDictionary *rectsForCells;
@property (nonatomic) CGFloat max_X;

@property (nonatomic, strong) NSMutableDictionary *shelvesForCells;



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
 *  ##Strategy
 *  Apple's recommended approach for layouts which change infrequently
 *  and hold hundreds of items (rather than thousands) is to calculate
 *  and cache all of the layout information upfront and then access that
 *  cache when the collection view requests it.
 *
 *  ##Credit
 *   Taking my cue from ICF (Richter & Keeley 2015) and some blogs (e.g.,
 *  http://skeuo.com/uicollectionview-custom-layout-tutorial ), this will
 *  be done with Dictionaries that have (conveniently ordered) indexPath(s)
 *  as keys. Advance one indexPath/key, and you get the next cell's layout
 *  attributes (see the nested for-loop below).
 *
 *  ##Specifics
 *   Layout is simple: One cell follows the next.
 *   Shelving is more complicated: Track book thickness until shelf space runs out.
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
    
    
    NSIndexPath *indexPath      = [NSIndexPath indexPathForItem:0 inSection:0]; // The longest indexPath begins with the first step.
    
//    self.centerPointsForCells   = [NSMutableDictionary new]; // ... but just in case.

    self.rectsForSectionHeaders = [NSMutableArray new];
    self.shelvesForCells        = [NSMutableDictionary new];
    
    NSMutableDictionary *newLayoutInfo          = [NSMutableDictionary new];
    NSMutableDictionary *cellLayoutInfo         = [NSMutableDictionary new];
//    NSMutableDictionary *leadingPathsForShelves = [NSMutableDictionary new];
 
    
    for (NSUInteger section = 0; section < sectionCount; section++) {
        NSUInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        for (NSUInteger item = 0; item < itemCount; item++) {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            self.shelvesForCells[indexPath] = [self shelfForCellAtIndexPath:indexPath];
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
 *
 */
- (CGRect) frameForCoverArtImageAtIndexPath:(NSIndexPath*)indexPath {
    CGRect newFrame;
    CGFloat variableWidth          = [self widthForCellAtIndexPath:indexPath];
    NSIndexPath *previousIndexPath = [self indexPathByDecrementingItem:indexPath];
    BOOL onNewLine                 = ![self.shelvesForCells[indexPath]
                                       isEqual:self.shelvesForCells[previousIndexPath]];

    if (previousIndexPath) {
        UICollectionViewLayoutAttributes *previousItemsAttributes = self.layoutInfo[previousIndexPath];
        CGRect previousRect = previousItemsAttributes.frame;
        
        CGFloat newX = (onNewLine)? (0.0f + self.insets.left) : (CGRectGetMaxX(previousRect) + self.interItemSpacingX);
        CGFloat newY = [self yPositionForShelf:self.shelvesForCells[indexPath]];
    
        newFrame = CGRectMake(newX, newY, variableWidth, kCellHeight);
        
    } else {
            // If this is the first indexPath:
        newFrame = CGRectMake(kHorizontalInset, kSectionHeight, variableWidth, kCellHeight);
    }
    return newFrame;
}

// Retrieve the width of the current cell's coverArt.
-(CGFloat)widthForCellAtIndexPath:(NSIndexPath*)indexPath {
    LBRShelvedBookCollectionViewCell *cell = (LBRShelvedBookCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    UIImage *scaledImage = [UIImage imageWithImage:cell.imageView.image scaledToHeight:kCellHeight];
    CGFloat width = (scaledImage.size.width)? scaledImage.size.width : kCellHeight;

    return width;
}

-(NSNumber*)shelfForCellAtIndexPath:(NSIndexPath*)indexPath {
    LBRShelvedBookCollectionViewCell *cell = (LBRShelvedBookCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    self.xPosition_cm += cell.thickness;
    if (self.xPosition_cm > self.bookcaseWidth_cm) {
        self.xPosition_cm = 0;
        self.shelfPosition++;
    }
    if (self.shelfPosition > self.shelvesPerBookcase) {
        NSLog(@"Error: ran out of space on bookshelf!");
    }

    return @(self.shelfPosition);
}

/**
 *  Retrieves the indexPath to the previous item by walking backwards one item (or if
 *   this is the first item in the section, walking back to the **last** item of the
 *   previous section).
 */
-(NSIndexPath*)indexPathByDecrementingItem:(NSIndexPath*)indexPath {
    NSUInteger previousItem        = 0;
    NSUInteger previousSection     = 0;
    NSIndexPath *previousIndexPath = nil;

    if (indexPath.item) {
        previousItem = indexPath.item - 1;
    } else if (indexPath.section) {
        previousSection = indexPath.section - 1;
        previousItem = [self.collectionView numberOfItemsInSection:previousSection] - offByOneAdjmt;
    }
    if (previousItem && previousSection) {
        previousIndexPath = [NSIndexPath indexPathForItem:previousItem inSection:previousSection];
    }

    return previousIndexPath;
}

-(CGFloat)yPositionForShelf:(NSNumber*)shelfNum {
    CGFloat yPosition = 0.0f;
        // Top-inset + (top section header + superior cells' height) * shelf_number
    NSInteger nthShelf = [shelfNum integerValue] + offByOneAdjmt;
    yPosition = self.insets.top +  nthShelf * (kSectionHeight + kCellHeight);
    
    return yPosition;
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
    CGFloat max_Y = self.shelvesPerBookcase * (kSectionHeight + kCellHeight) + kSectionHeight;
    return CGSizeMake(self.max_X, max_Y);
}

@end
