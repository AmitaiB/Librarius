//
//  LBR_BookcaseLayout.m
//  Librarius
//
//  Created by Amitai Blickstein on 10/15/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//
#define kDefaulCellDimension 106.0
#define kDefaultCellSize CGSizeMake(kDefaulCellDimension, kDefaulCellDimension)

#define INSET_TOP 1.0
#define INSET_LEFT 1.0
#define INSET_BOTTOM 1.0
#define INSET_RIGHT 1.0


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

-(void)prepareLayout {
    
    NSMutableDictionary *layoutInformation = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellInformation   = [NSMutableDictionary dictionary];
    NSIndexPath __block *indexPath;
    
    
    
    self.shelfCounter = 0;
    self.bookOnShelfCounter = 0;
    self.bookcaseModel = [self configuredBookcaseModel];
    NSUInteger maxShelves = self.bookcaseModel.shelves.count;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    LBR_BookcaseCollectionViewController *dataSource = (LBR_BookcaseCollectionViewController *)self.collectionView;
    
//    NSUInteger numSections = dataSource.fetchedObjects ;
    
    NSMutableDictionary __block *booksDictByIndexPath = [NSMutableDictionary new];
    
//    Key each book to an indexPath
//    [[self.dataSource filledBookcaseModel] enumerateObjectsUsingBlock:^(NSArray<Volume *> * shelfModel, NSUInteger idx, BOOL * _Nonnull stop) {
//        for (NSUInteger bookIndex = 0; bookIndex < shelfModel.count; bookIndex++) {
//            indexPath = [NSIndexPath indexPathForItem:bookIndex inSection:idx];
//            [booksDictByIndexPath setObject:shelfModel[bookIndex] forKey:indexPath];
//        }
//    }];
    
//    Frames for IndexPath
    NSIndexPath *indexPathKey;
    CGPoint newOrigin;
    CGRect rect;
    UICollectionViewLayoutAttributes *attributes;
    
//    Grab content size at the same time.
    CGFloat xMax = 0.0f;
    CGFloat yMax = 0.0f;
    
    for (NSUInteger i = 0; i < [booksDictByIndexPath allKeys].count; i++) {
        indexPathKey = [booksDictByIndexPath allKeys][i];
        newOrigin = CGPointMake(indexPathKey.item * kDefaulCellDimension, indexPathKey.section * kDefaulCellDimension);
        rect = CGRectMake(newOrigin.x, newOrigin.y, kDefaulCellDimension, kDefaulCellDimension);
        attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPathKey];
        attributes.frame = rect;
        
        [self.attributesForCells setObject:[attributes copy] forKey:indexPathKey];
        
        
        xMax = MAX(xMax, newOrigin.x);
        yMax = MAX(yMax, newOrigin.y);
    }
    
    self.contentSize = CGSizeMake(xMax + kDefaulCellDimension, yMax + kDefaulCellDimension);
}



-(CGSize)contentSize {
    return self.contentSize;
}

-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
        //Check for all elements that are in the rect, and add the corresponding attributes
        //to the array, which is then returned.
    NSMutableArray __block *attributeObjectsToReturn = [NSMutableArray new];
    [self.attributesForCells enumerateKeysAndObjectsUsingBlock:^(NSIndexPath * indexPathKey, UICollectionViewLayoutAttributes *attributes, BOOL * _Nonnull stop) {
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            [attributeObjectsToReturn addObject:attributes];
        }
    }];
    
    return [attributeObjectsToReturn copy];
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.attributesForCells[indexPath];
}

@end
