//
//  LBR_ProgrammaticPopoverViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 11/9/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBR_ProgrammaticPopoverViewController.h"
#import "UIView+ABB_Categories.h"
#import "UIView+ConfigureForAutoLayout.h"

@interface LBR_ProgrammaticPopoverViewController ()

@property (nonatomic, strong) UITextField *numShelvesTxField;
@property (nonatomic, strong) UITextField *shelfWidth_cmTxField;
@end

@implementation LBR_ProgrammaticPopoverViewController

-(instancetype)init
{
    if (!(self = [super init])) return nil;
 
        //Initialize views
    _contentView = [UIView new];
    _numShelvesStepper = [UIStepper new];
    _shelfWidthStepper = [UIStepper new];
    _numShelvesTxField = [UITextField new];
    _shelfWidth_cmTxField = [UITextField new];
    
    return nil;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary <NSString*, UIView*> *subViewsDict = @{@"shelvesStepper" : self.numShelvesStepper,
                                                        @"shelvesField" : self.numShelvesTxField,
                                                        @"widthStepper" : self.shelfWidthStepper,
                                                        @"widthField"   : self.shelfWidth_cmTxField
                                                        };
//    @"contentView" : self.contentView
        //View heirarchy
    [self.view addSubview:self.contentView];
    [self.contentView addSubviews:[NSSet setWithArray:[subViewsDict allValues]]];
    
        //Auto Layout
    NSArray *allViews = [[subViewsDict allValues] arrayByAddingObject:self.contentView];
    [UIView configureViewsForAutolayout:allViews];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[shelvesField]-[shelvesStepper]-|" options:0 metrics:nil views:subViewsDict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[widthField]-[widthStepper]-|" options:0 metrics:nil views:subViewsDict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[shelvesField]-[widthField]-|" options:0 metrics:nil views:subViewsDict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[shelvesStepper]-[widthStepper]-|" options:0 metrics:nil views:subViewsDict]];
    
    
    self.preferredContentSize = self.contentView.frame.size;
    
}

-(void)setPopoverNumShelves:(NSUInteger)popoverNumShelves
{
    _popoverNumShelves = popoverNumShelves;
    
    
    if (popoverNumShelves == 1)
    {
        self.numShelvesTxField.text = [NSString stringWithFormat:@"%lu shelf", popoverNumShelves];
    }
    else
    {
        self.numShelvesTxField.text = [NSString stringWithFormat:@"%lu shelves", popoverNumShelves];
    }
}

-(void)setPopoverShelfWidth:(CGFloat)popoverShelfWidth
{
    _popoverShelfWidth = popoverShelfWidth;
    
    self.shelfWidth_cmTxField.text = [NSString stringWithFormat:@"%.01f cm", popoverShelfWidth];
}

@end
