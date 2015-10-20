//
//  LBRShelvedBookCollectionViewCell.m
//  Librarius
//
//  Created by Amitai Blickstein on 9/11/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBRShelvedBook_CollectionViewCell.h"


@implementation LBRShelvedBook_CollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
        //custom initialization
    self.imageView = [UIImageView new];
    [self.contentView addSubview:self.imageView];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [self.imageView setImage:[UIImage imageNamed:@"placeholder"]];
    
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
}


@end
