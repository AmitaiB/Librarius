//
//  LBR_BookcasePopoverViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 11/5/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBR_BookcasePopoverViewController.h"
#import "UIView+ABB_Categories.h"
#import "UIView+ConfigureForAutoLayout.h"

@interface LBR_BookcasePopoverViewController ()
@property (nonatomic, strong) UIView *contentView;
@end

@implementation LBR_BookcasePopoverViewController

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
    
    NSDictionary <NSString *, UIView*> *subViews = @{@"numField"    : _numShelvesTxField,
                                                     @"numStepper"  : _numShelvesStepper,
                                                     @"widthField"  : _shelfWidth_cmTxField,
                                                     @"widthStepper": _shelfWidthStepper
                                                     };
    
        //UIView Categories
    [self.contentView addSubviews:[NSSet setWithArray:[subViews allValues]]];
    [UIView configureViewsForAutolayout:@[_contentView]];
    [UIView configureViewsForAutolayout:[subViews allValues]];
    
    
        //Maybe unneeded. Just do self: sizetofit.
    [_contentView.topAnchor    constraintEqualToAnchor:self.topAnchor].   active = YES;
    [_contentView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [_contentView.leftAnchor   constraintEqualToAnchor:self.leftAnchor].  active = YES;
    [_contentView.rightAnchor  constraintEqualToAnchor:self.rightAnchor]. active = YES;
    
    [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[numField]-[numStepper]-16-[widthField]-[widthStepper]-|" options:0 metrics:nil views:subViews]];
    
    [subViews enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIView * _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *constraintString = [NSString stringWithFormat:@"V:|-%@-|", key];
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintString options:0 metrics:nil views:@{key : obj}]];
    }];
    
    [self sizeToFit];

    return self;
}


@end
