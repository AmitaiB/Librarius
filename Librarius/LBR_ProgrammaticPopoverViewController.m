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
@property (nonatomic, strong) UIButton *applyUndoChangesButton;
@end

@implementation LBR_ProgrammaticPopoverViewController

-(instancetype)init
{
    if (!(self = [super init])) return nil;


-(void)viewDidLoad
{
    [super viewDidLoad];
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


- (IBAction)applyUndoChangesButtonTapped:(id)sender {
}
@end
