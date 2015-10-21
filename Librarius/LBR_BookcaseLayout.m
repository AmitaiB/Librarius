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

@property (nonatomic, assign) NSUInteger shelfCounter;
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

-(LBR_BookcaseModel *)configuredBookcaseModel {
    LBR_BookcaseModel *bookcaseModel = [[LBR_BookcaseModel alloc] initWithWidth:58.0 shelvesCount:5];
    LBR_BookcaseCollectionViewController *collectionViewController = (LBR_BookcaseCollectionViewController *)self.collectionView.dataSource;
    [bookcaseModel shelveBooks:collectionViewController.fetchedResultsController.fetchedObjects];
    return bookcaseModel;
}

-(void)incrementBookcaseModelCounter {
    NSArray *currentShelf = self.bookcaseModel.shelves[self.shelfCounter];
    NSUInteger maxShelves = self.bookcaseModel.shelves.count;

        //No more shelves.
    if (self.shelfCounter == maxShelves)
        return;
    
        //If there are more books on this shelf.
    if (self.bookOnShelfCounter < currentShelf.count)
    {
        self.bookOnShelfCounter++;
        return;
    }
    
        //If this book was the last book on the current shelf.
    if (self.bookOnShelfCounter >= currentShelf.count && self.shelfCounter < maxShelves)
    {
        self.shelfCounter++;
        self.bookOnShelfCounter = 0;
        return;
    }
}

-(CGPoint)originPointForBook:(NSUInteger)bookCounter onShelf:(NSUInteger)shelfCounter {
    CGFloat xPosition = INSET_LEFT + bookCounter  * (kDefaulCellDimension + self.interItemSpacing);
    CGFloat yPosition = INSET_TOP  + shelfCounter * (kDefaulCellDimension + self.interShelfSpacing);
    return CGPointMake(xPosition, yPosition);
}

-(void)prepareLayout {
    
    NSMutableDictionary *layoutInformation = [NSMutableDictionary dictionary];
    NSIndexPath *indexPath;
    
    
    self.shelfCounter = 0;
    self.bookOnShelfCounter = 0;
    self.bookcaseModel = [self configuredBookcaseModel];
    
    CGFloat xMax = 0;
    CGFloat yMax = 0;
    
        ///First, create an attributes object for each cell (keyed to indexPath, provided by the collectionView's dataSource.
    NSInteger numSections = [self.collectionView numberOfSections];
    
    for (NSUInteger section = 0; section < numSections; section++) {
        NSUInteger numItems = [self.collectionView numberOfItemsInSection:section];
        
        for (NSUInteger item = 0; item < numItems; item++) {
                //Many things need to happen here:
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
//            [self layoutAttributesForItemAtIndexPath:indexPath];
            
            CGPoint origin = [self originPointForBook:self.bookOnShelfCounter onShelf:self.shelfCounter];
            attributes.frame = CGRectMake(origin.x, origin.y, kDefaulCellDimension, kDefaulCellDimension);
            [self incrementBookcaseModelCounter];
            
                //Grab ContentSize while we're here.
            xMax = MAX(xMax, origin.x);
            yMax = MAX(yMax, origin.y);
            
            [layoutInformation setObject:attributes forKey:indexPath];
        }
    }
    
        //A bit more tweaking is needed for the contentSize
    xMax += kDefaulCellDimension + INSET_RIGHT;
    yMax += kDefaulCellDimension + INSET_BOTTOM;
    self.contentSize = CGSizeMake(xMax, yMax);
        ///At this point, we should have appropriate layout data for our cells per indexPath,
        ///having fully encapsulated the dirty work of arranging it appropriately.
}


-(CGSize)contentSize
{
    return self.contentSize;
}


-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
        //Check for all elements that are in the rect, and add the corresponding attributes
        //to the array, which is then returned.
    NSMutableArray *attributeObjectsToReturn = [NSMutableArray array];
    
    for (UICollectionViewLayoutAttributes *attributes in self.layoutInformation) {
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            [attributeObjectsToReturn addObject:attributes];
        }
    }
    
    return [attributeObjectsToReturn copy];
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.layoutInformation[indexPath];
}

@end
