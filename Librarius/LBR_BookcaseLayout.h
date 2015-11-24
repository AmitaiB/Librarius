//
//  LBR_BookcaseLayout.h
//  Librarius
//
//  Created by Amitai Blickstein on 10/15/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "LBR_BookcaseModel.h"

//@protocol LBRBookLayoutDataSource <NSObject>
//
//    ///An array (bookcase model) of arrays (shelf models) of Volume objects.
//@property (nonatomic, strong)  NSArray <NSArray <Volume *> *> *filledBookcaseModel;
//
//@end


@interface LBR_BookcaseLayout : UICollectionViewLayout

@property (nonatomic, assign) CGFloat interItemSpacing;
@property (nonatomic, assign) CGFloat interShelfSpacing;
@property (nonatomic, strong, readonly) Bookcase *bookcase;
@property (nonatomic, assign, readonly) NSUInteger widestShelfWidth;
@property (nonatomic, assign, readonly) LBRLayoutScheme layoutScheme;


@property (nonatomic, strong) NSArray *shelvesNestedArray;


@property (nonatomic, strong) NSArray<NSArray*>  *transientBookcaseLayoutModel;

- (instancetype)initWithScheme:(LBRLayoutScheme)layoutScheme maxShelves:(NSUInteger)maxShelves shelfWidth_cm:(CGFloat)width_cm forVolumes:(NSArray <Volume *> *)volumes;
- (instancetype)initWithScheme:(LBRLayoutScheme)layoutScheme forVolumes:(NSArray <Volume *> *)volumes;
- (NSString*)formatTypeToString:(LBRLayoutScheme)formatType;
@end
