//
//  LBR_BookcaseLayout.h
//  Librarius
//
//  Created by Amitai Blickstein on 10/15/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LBR_BookcaseModel;
@protocol LBRBookLayoutDataSource <NSObject>

@property (nonatomic, strong)  LBR_BookcaseModel* bookcaseModel;

@end


@interface LBR_BookcaseLayout : UICollectionViewLayout

@property (nonatomic, weak) id <LBRBookLayoutDataSource> dataSource;


@end
