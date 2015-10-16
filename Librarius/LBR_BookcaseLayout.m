//
//  LBR_BookcaseLayout.m
//  Librarius
//
//  Created by Amitai Blickstein on 10/15/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBR_BookcaseLayout.h"

#import "LBR_BookcaseCollectionViewController.h"

@interface LBR_BookcaseLayout ()
@property (nonatomic, strong) NSMutableDictionary *centerPointsForCells;
@property (nonatomic, assign) NSUInteger widestShelfWidth;
@property (nonatomic, assign) CGSize contentSize;
@end

@implementation LBR_BookcaseLayout

    //The layout communicates with the data source by calling methods on the collectionView property.
    ///Take an ordered array of bookModel objects, and put them into a dictionary, where the keys are indexPaths.
    ///The indexPaths should be chosen where Section = shelf (from top).
-(void)prepareLayout {
    NSInteger numSections = [self.collectionView numberOfSections];
    
    
    
}


@end
