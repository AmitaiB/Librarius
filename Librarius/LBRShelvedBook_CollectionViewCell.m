//
//  LBRShelvedBookCollectionViewCell.m
//  Librarius
//
//  Created by Amitai Blickstein on 9/11/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBRShelvedBook_CollectionViewCell.h"
#import "UIColor+FlatUI.h"


@implementation LBRShelvedBook_CollectionViewCell

-(instancetype)init
{
    if (!(self = [super init])) return nil;
    
        //???: Does this work?
    NSLayoutConstraint *fallbackWidthConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30];
    NSLayoutConstraint *fallbackHeightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30];
    fallbackWidthConstraint.priority  = 1.0;
    fallbackHeightConstraint.priority = 1.0;
    [self addConstraints:@[fallbackWidthConstraint, fallbackHeightConstraint]];
    return self;
}



@end
