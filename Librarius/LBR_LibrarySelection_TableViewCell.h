//
//  LBR_LibrarySelection_TableViewCell.h
//  Librarius
//
//  Created by Amitai Blickstein on 11/9/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//
//  All credit goes to Ash Furrow, see his project: https://github.com/ashfurrow/AFTabledCollectionView
//
//

#import <UIKit/UIKit.h>

@interface LBRIndexedCollectionView : UICollectionView
@property (nonatomic, strong) NSIndexPath *indexPath;
@end


static NSString * const collectionViewCellReuseID = @"collectionViewCellReuseID";

@interface LBR_LibrarySelection_TableViewCell : UITableViewCell
@property (nonatomic, strong) LBRIndexedCollectionView *collectionView;

-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath*)indexPath;

@end
