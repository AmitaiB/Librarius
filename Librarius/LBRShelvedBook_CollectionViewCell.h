//
//  LBRShelvedBookCollectionViewCell.h
//  Librarius
//
//  Created by Amitai Blickstein on 9/11/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBRShelvedBook_CollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSString *coverArtURL;
@property (nonatomic) CGFloat thickness;
@property (nonatomic, strong) NSArray *recommendationsArray;

@end
