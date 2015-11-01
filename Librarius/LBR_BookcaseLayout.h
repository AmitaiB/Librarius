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

typedef NS_ENUM(NSUInteger, LBRLayoutScheme) {
    LBRLayoutSchemeGenreAuthorDate, //default
    LBRLayoutSchemeAuthorDate
//    ,LBRLayoutSchemeLOC  not implemented yet
//    ,LBRLayoutSchemeDDS
};

@interface LBR_BookcaseLayout : UICollectionViewLayout

@property (nonatomic, assign) CGFloat interItemSpacing;
@property (nonatomic, assign) CGFloat interShelfSpacing;

//@property (nonatomic, weak) id <LBRBookLayoutDataSource> dataSource;


- (instancetype)initWithScheme:(LBRLayoutScheme)layoutScheme;
-(NSString*)formatTypeToString:(LBRLayoutScheme)formatType;
@end
