//
//  LBR_BookcaseLayoutAttributes.h
//  
//
//  Created by Amitai Blickstein on 10/15/15.
//
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    LBRCollectionViewLayoutModeBookcaseCustomLayout,
    LBRCollectionViewLayoutModeBookcaseFlowLayout
}LBRCollectionViewLayoutMode;

@interface LBR_BookcaseLayoutAttributes : UICollectionViewLayoutAttributes

@property (nonatomic, assign) LBRCollectionViewLayoutMode layoutMode;

@end
