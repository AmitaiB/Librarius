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

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (!(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) return nil;
    _contentView = [UIView new];
    [self.view addSubview:_contentView];
    _numShelvesTxField = [UITextField new];
    _numShelvesTxField.placeholder     = @"# of Shelves";
    _shelfWidth_cmTxField = [UITextField new];
    _shelfWidth_cmTxField.placeholder  = @"width (cm)";
    _numShelvesStepper = [UIStepper new];
    _shelfWidthStepper = [UIStepper new];
    
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
        //For both View Heirarchy and AutoLayout constraints
    NSDictionary <NSString *, UIView*> *subViews = @{@"numField"    : self.numShelvesTxField,
                                                     @"numStepper"  : self.numShelvesStepper,
                                                     @"widthField"  : self.shelfWidth_cmTxField,
                                                     @"widthStepper": self.shelfWidthStepper
                                                     };
    
        //UIView Categories
    [self.contentView addSubviews:[NSSet setWithArray:[subViews allValues]]];
    [UIView configureViewsForAutolayout:@[self.contentView]];
    [UIView configureViewsForAutolayout:[subViews allValues]];
    
        //Maybe unneeded. Just do self: sizetofit.
    [self.contentView.topAnchor    constraintEqualToAnchor:self.view.topAnchor].   active = YES;
    [self.contentView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.contentView.leftAnchor   constraintEqualToAnchor:self.view.leftAnchor].  active = YES;
    [self.contentView.rightAnchor  constraintEqualToAnchor:self.view.rightAnchor]. active = YES;
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[numField]-[numStepper]-16-[widthField]-[widthStepper]-|" options:0 metrics:nil views:subViews]];
    
    [subViews enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIView * _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *constraintString = [NSString stringWithFormat:@"V:|-%@-|", key];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintString options:0 metrics:nil views:@{key : obj}]];
    }];
    
    [self.view sizeToFit];

}


@end
