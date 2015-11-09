//
//  LBR_LibrarySelection_TableViewCell.h
//  Librarius
//
//  Created by Amitai Blickstein on 11/9/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBR_LibrarySelection_CollectionView.h"

@interface LBR_LibrarySelection_TableViewCell : UITableViewCell
@property (nonatomic, strong) LBR_LibrarySelection_CollectionView *collectionView;

@end
