//
//  LBR_TemporaryFlowLayout.h
//  Librarius
//
//  Created by Amitai Blickstein on 10/26/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LBR_BookcaseLayoutAttributes.h"

#define kMaxItemDimension 106.0
#define kMaxItemSize      CGSizeMake(kMaxItemDimension, kMaxItemDimension)

@protocol LBR_CollectionViewDelegateFlowLayout <UICollectionViewDelegateFlowLayout>

@optional

-(LBRCollectionViewLayoutMode)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout layoutModeForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface LBR_TemporaryFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) LBRCollectionViewLayoutMode layoutMode;

@end
