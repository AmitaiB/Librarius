//
//  LBR_BookcaseLayout.m
//  Librarius
//
//  Created by Amitai Blickstein on 10/15/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#define kDefaulCellDimension 106.0
#define kDefaultCellSize CGSizeMake(kDefaulCellDimension, kDefaulCellDimension)

#define INSET_TOP    1.0
#define INSET_LEFT   1.0
#define INSET_BOTTOM 1.0
#define INSET_RIGHT  1.0

//#define kMinimumLineSpacing 1.0
//#define kMinimumItemSpacing 1.0

#define kDecorationYadjustment  13.0
#define kDecorationHeight       25.0

    //Models
#import "LBR_BookcaseLayout.h"
#import "LBR_BookcaseModel.h"
#import "Bookcase.h"

    //Views
#import "LBRShelf_DecorationView.h"

    //Controllers
#import "LBR_BookcaseCollectionViewController.h"

    //Data
#import "LBRDataManager.h"


@interface LBR_BookcaseLayout ()

@property (nonatomic, strong) NSMutableDictionary *attributesForCells;

@property (nonatomic, assign, readwrite) CGFloat shelfWidth_cm;
@property (nonatomic, assign) NSUInteger maxShelvesCount;
@property (nonatomic, assign) NSUInteger cellCountForLongestRow;

@property (nonatomic, assign) CGSize contentSize;
//@property (nonatomic, strong) NSArray <NSArray <Volume *> *> *filledBookcaseModel;

@property (nonatomic, strong) NSDictionary *layoutInformation;
@property (nonatomic, assign) UIEdgeInsets insets;

@property (nonatomic, strong) LBRDataManager *dataManager;

    //DecorationView
@property (nonatomic, strong) NSDictionary *rowDecorationRects;
//@property (nonatomic) CGSize headerReferenceSize;
//@property (nonatomic) CGSize footerReferenceSize;
//@property (nonatomic) UIEdgeInsets sectionInset;


@property (nonatomic, assign) NSUInteger currentShelfIndex;
@property (nonatomic, assign) NSUInteger bookOnShelfCounter;
@property (nonatomic, strong, readwrite) LBR_BookcaseModel *bookcaseModel;

    //Required for Switching
@property (nonatomic, assign) LBRLayoutScheme layoutScheme;
@property (nonatomic, strong) NSFetchedResultsController *localFetchedResultsController;

@property (nonatomic, strong) Bookcase *currentBookcase;

@end

@implementation LBR_BookcaseLayout

#pragma mark - == Lifecycle ==

-(instancetype)initWithScheme:(LBRLayoutScheme)layoutScheme maxShelves:(NSUInteger)maxShelves shelfWidth_cm:(CGFloat)width_cm
{
    if (!(self = [super init])) return nil;
    
    _maxShelvesCount    = maxShelves;
    _shelfWidth_cm      = width_cm;
    _layoutScheme       = layoutScheme;
    _insets             = UIEdgeInsetsMake(INSET_TOP, INSET_LEFT, INSET_BOTTOM, INSET_RIGHT);
    _currentShelfIndex  = 0;
    _bookOnShelfCounter = 0;
    _interItemSpacing   = 3.0;
    _interShelfSpacing  = 30.0;
    _cellCountForLongestRow = 0;
    
    [super registerClass:[LBRShelf_DecorationView class] forDecorationViewOfKind:[LBRShelf_DecorationView kind]];
    
    return self;
}

-(instancetype)initWithScheme:(LBRLayoutScheme)layoutScheme
{
    return [self initWithScheme:layoutScheme maxShelves:kDefaultBookcaseShelvesCount shelfWidth_cm:kDefaultBookcaseWidth_cm];
}

-(instancetype)init
{
    return [self initWithScheme:LBRLayoutSchemeGenreAuthorDate];
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
    if (!self.dataManager) {
        self.dataManager = [LBRDataManager sharedDataManager];
    }
    
    
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
            attributes.zIndex = 1;
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
    CGFloat xMax = INSET_LEFT + (kDefaulCellDimension + self.interItemSpacing) * cellCountForLongestRow - self.interItemSpacing + INSET_RIGHT; // - (self.collectionView.contentInset.left + self.collectionView.contentInset.right);
    CGFloat yMax = INSET_TOP + (kDefaulCellDimension + self.interShelfSpacing) * self.bookcaseModel.shelves.count - self.interShelfSpacing + INSET_BOTTOM;
    
    return CGSizeMake(xMax, yMax);
}

-(NSUInteger)extrapolatedCellCountForLongestRow
{
//    if (self.cellCountForLongestRow == 0) {
        for (NSArray *shelf in self.bookcaseModel.shelves) {
            self.cellCountForLongestRow = MAX(self.cellCountForLongestRow, shelf.count);
        }
//    }
    
    return self.cellCountForLongestRow;
}

    /**
     This value changes depending on the scheme, which alters the fetchedResultsController's fetchRequest to match it.
     */
-(LBR_BookcaseModel *)configuredBookcaseModel
{
    LBR_BookcaseModel *bookcaseModel = [[LBR_BookcaseModel alloc] initWithWidth:self.shelfWidth_cm shelvesCount:self.maxShelvesCount];
    [bookcaseModel shelveBooks:self.localFetchedResultsController.fetchedObjects];

    return bookcaseModel;
}

-(void)incrementBookcaseModelByOneBook {
    NSArray *currentShelf = self.bookcaseModel.shelves[self.currentShelfIndex];

    
//    CLEAN: No longer necessary, methinks:
//    self.maxShelvesCount = self.bookcaseModel.shelves.count;
    
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
        self.currentShelfIndex + offBy1 < self.maxShelvesCount)
    {
        self.currentShelfIndex++;
        self.bookOnShelfCounter = 0;
        return;
    }
        //If all shelves are full - no more shelves.
    if (self.currentShelfIndex + offBy1 >= self.maxShelvesCount)
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
                yPosition += self.interShelfSpacing;
            }
            
//            yPosition += self.sectionInset.bottom;
            yPosition += INSET_BOTTOM;
        }
        
        self.rowDecorationRects = [rowDecorationWork copy];
    }
}

    /**
     This method aligns the fetchedResultsController (FRC) with the chosen layout scheme - which uses the controller to shelve the BookModel's books. This implementation does not disturb the default code in the datamanager, nor wipes the FRC's cache.
     To customize the new FRC, we need to change:
       1) The cache (set to new unique name for the layout scheme).
       2) The sectionNameKeyPath (usually set to nil).
       3) The sort descriptors (where the magic happens!).
       4) The NSFetchRequest's predicate (rare: usually, just leave this as "current library").
     */
-(NSFetchedResultsController *)localFetchedResultsController
{
    if (_localFetchedResultsController == nil) {
        LBR_BookcaseCollectionViewController *collectionViewController = (LBR_BookcaseCollectionViewController *)self.collectionView.dataSource;
        
            //The default.
        if (self.layoutScheme == LBRLayoutSchemeGenreAuthorDate)
        {
            _localFetchedResultsController = collectionViewController.fetchedResultsController;
        }
        
            //Built with extensibility in mind, for future layout customizations.
        else {
            NSFetchedResultsController *globalFRC = collectionViewController.fetchedResultsController;
            
                //            LBRDataManager *dataManager = [LBRDataManager sharedDataManager];
            
                //The default predicate is for "current library". In most forseeable cases, that shouldn't need to change.
            NSFetchRequest *localRequestByScheme = globalFRC.fetchRequest;
            NSString *localCacheNameByScheme;
            
            if (self.layoutScheme == LBRLayoutSchemeAuthorDate)
            {
                localCacheNameByScheme = [self formatTypeToString:LBRLayoutSchemeAuthorDate];
                localRequestByScheme.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"authorSurname" ascending:YES]];
                
                return [[NSFetchedResultsController alloc]
                        initWithFetchRequest:localRequestByScheme
                        managedObjectContext:globalFRC.managedObjectContext
                        sectionNameKeyPath:nil
                        cacheName:localCacheNameByScheme];
            }
        }
    }
    return _localFetchedResultsController;
}

//-(void)setLayoutScheme:(LBRLayoutScheme)layoutScheme
//{
//    _layoutScheme = layoutScheme;
//    
//    [self.bookcaseModel shelveBooks:self.localFetchedResultsController.fetchedObjects];
//}


- (NSString*)formatTypeToString:(LBRLayoutScheme)formatType {
    NSString *result = nil;
    
    switch(formatType) {
        case LBRLayoutSchemeGenreAuthorDate:
            result = @"LBRLayoutSchemeGenreAuthorDate";
            break;
        case LBRLayoutSchemeAuthorDate:
            result = @"LBRLayoutSchemeAuthorDate";
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected FormatType (LBRLayoutScheme)."];
    }
    
    return result;
}


#pragma mark - === DataManager Interface ===

-(Bookcase *)currentBookcase
{
    if (self.dataManager.currentBookcase) {
        return _currentBookcase = self.dataManager.currentBookcase;
    }
    else
    {
        [self.dataManager generateDefaultBookcaseIfNeeded];
        if (self.dataManager.currentBookcase) {
            return _currentBookcase = self.dataManager.currentBookcase;
        }
    }
    
    DDLogWarn(@"No default Bookcase detected.");
    return nil;
}

@end
