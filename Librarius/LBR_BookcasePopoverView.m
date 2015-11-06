//
//  LBR_BookcasePopoverView.m
//  Librarius
//
//  Created by Amitai Blickstein on 11/5/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBR_BookcasePopoverView.h"
#import "UIView+ABB_Categories.h"

@interface LBR_BookcasePopoverView ()
@property (nonatomic, strong) UIView *contentView;
@end

@implementation LBR_BookcasePopoverView

-(instancetype)init
{
    if (!(self = [super init])) return nil;
    
    _contentView = [UIView new];
    [self addSubview:_contentView];
    
    _numShelvesTxField = [UITextField new];
    _numShelvesTxField.placeholder     = @"# of Shelves";
    
    _shelfWidth_cmTxField = [UITextField new];
    _shelfWidth_cmTxField.placeholder  = @"width (cm)";
    
    _numShelvesStepper = [UIStepper new];
    
    _shelfWidthStepper = [UIStepper new];
    
    
    [self.contentView addSubviews:[NSSet setWithArray:@[_numShelvesTxField,
                                                   _numShelvesStepper,
                                                   _shelfWidth_cmTxField,
                                                   _shelfWidthStepper]]];
    

    
    return self;
}

@end
