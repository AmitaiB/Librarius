//
//  LBRShelvedBookCollectionViewCell.m
//  Librarius
//
//  Created by Amitai Blickstein on 9/11/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBRShelvedBookCollectionViewCell.h"
#import <SAMCache.h>


@implementation LBRShelvedBookCollectionViewCell

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

/**
 *  For TODO: implement cache
 */
//-(void)setCoverArt:(NSString *)coverArtURL {
//    _coverArtURL = coverArtURL;
//    
////    NSDictionary *coverArtDict = NSDictionaryOfVariableBindings(coverArtURL);
////    NSString *key = [coverArtDict allKeys][0];
//    
//    UIImage *coverArt = [[SAMCache sharedCache] imageForKey:key];
//    if (coverArt) {
//        self.imageView.image = coverArt;
//        return;
//    }
//}

@end
