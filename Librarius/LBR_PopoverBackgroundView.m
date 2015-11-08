//
//  LBR_PopoverBackgroundView.m
//  Librarius
//
//  Created by Amitai Blickstein on 11/7/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//
#define ARBASE   20.0f
#define ARHEIGHT 20.0f


#import "LBR_PopoverBackgroundView.h"

@implementation LBR_PopoverBackgroundView

#pragma mark - === Lifecycle ===

-(instancetype)init
{
    if (!(self = [super init])) return nil;
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (!(self = [super initWithCoder:aDecoder])) return nil;
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;
    return self;
}

#pragma mark - === UIPopoverBackgroundViewMethods ===

+(CGFloat)arrowBase
{
    return 5.0f;
}

+(CGFloat)arrowHeight
{
    return 5.0f;
}

+(UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsZero;
}

#pragma mark - === Overridden methods ===

-(CGFloat)arrowOffset
{
    return 20;
}

-(void)setArrowOffset:(CGFloat)arrowOffset
{
//    [super setArrowOffset:arrowOffset];
}

-(UIPopoverArrowDirection)arrowDirection
{
    return UIPopoverArrowDirectionAny;
}

-(void)setArrowDirection:(UIPopoverArrowDirection)arrowDirection
{
    
}

@end
