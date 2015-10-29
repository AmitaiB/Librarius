//
//  LBRRecommendations_FlowLayout.m
//  Librarius
//
//  Created by Amitai Blickstein on 10/23/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBRRecommendations_FlowLayout.h"
#import "LBRShelf_DecorationView.h"

#define kDecorationYAdjustment  13.0
#define kDecorationHeight       25.0

@interface LBRRecommendations_FlowLayout ()
@property (nonatomic, strong) NSDictionary *rowDecorationRects;
@end

@implementation LBRRecommendations_FlowLayout

    //Prototpyed in storyboard, so this in place of `init`
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (!(self = [super initWithCoder:aDecoder])) return nil;
    
    [self registerClass:[LBRShelf_DecorationView class] forDecorationViewOfKind:[LBRShelf_DecorationView kind]];
    
    return self;
}

-(void)prepareLayout
{
    [super prepareLayout];
    
    NSInteger numSections = [self.collectionView numberOfSections];
    
    CGFloat availableWidth = self.collectionViewContentSize.width -
    (self.sectionInset.left + self.sectionInset.right);
    
    NSInteger cellsPerRow = floorf((availableWidth + self.minimumInteritemSpacing) /
                                   (self.itemSize.width + self.minimumInteritemSpacing));
    
    NSMutableDictionary *rowDecorationWork = [NSMutableDictionary dictionary];
    
    CGFloat yPosition = 0;
    
    for (NSUInteger sectionIndex = 0; sectionIndex < numSections; sectionIndex++)
    {
        yPosition += self.headerReferenceSize.height;
        yPosition += self.sectionInset.top;
        
        NSUInteger cellCount =
        [self.collectionView numberOfItemsInSection:sectionIndex];
        
        NSUInteger rows = ceilf(cellCount/(CGFloat)cellsPerRow);
        for (NSInteger row = 0; row < rows; row++) {
            yPosition += self.itemSize.height;
            
            CGRect decorationFrame = CGRectMake(0, yPosition - kDecorationYAdjustment, self.collectionViewContentSize.width, kDecorationHeight);
            
            NSIndexPath *decIndexPath = [NSIndexPath indexPathForRow:row inSection:sectionIndex];
            
            rowDecorationWork[decIndexPath] = [NSValue valueWithCGRect:decorationFrame];
            
            if (row < rows - 1) {
                yPosition += self.minimumLineSpacing;
            }
            
            yPosition += self.sectionInset.bottom;
            yPosition += self.footerReferenceSize.height;
        }
        
        self.rowDecorationRects = [rowDecorationWork copy];
    }
}

-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *layoutAttributes = [super layoutAttributesForElementsInRect:rect];
    
    for (UICollectionViewLayoutAttributes *attributes in layoutAttributes) {
        attributes.zIndex = 1;
    }
    
    NSMutableArray *newLayoutAttributes = [layoutAttributes mutableCopy];
    
    [self.rowDecorationRects enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, NSValue *rowRectValue, BOOL * stop) {
        
        if (CGRectIntersectsRect([rowRectValue CGRectValue], rect)) {
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:[LBRShelf_DecorationView kind] withIndexPath:indexPath];
            
            attributes.frame = [rowRectValue CGRectValue];
            attributes.zIndex = 0;
            [newLayoutAttributes addObject:attributes];
        }
    }];
    
    layoutAttributes = [newLayoutAttributes copy];
    
    return layoutAttributes;
}



@end
