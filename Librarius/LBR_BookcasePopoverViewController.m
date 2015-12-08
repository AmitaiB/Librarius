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
/**
 Workaround the storyboard bug:
 nil everything in the apply...Button, then add a subview txtField to 
 change the Bookcase
 */
@property (nonatomic, strong) UITextField *editBookcaseNameTxField;



@property (nonatomic, weak) IBOutlet UITextField *numShelvesTxField;
@property (nonatomic, weak) IBOutlet UITextField *shelfWidth_cmTxField;
@property (weak, nonatomic) IBOutlet UIButton *applyUndoChangesButton;
- (IBAction)applyUndoChangesButtonTapped:(id)sender;
@end

@implementation LBR_BookcasePopoverViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    self.preferredContentSize = self.contentView.frame.size;
    self.view.layer.cornerRadius = 15;
    self.view.clipsToBounds = YES;
    
    self.contentView.layer.cornerRadius = 5;
    self.contentView.clipsToBounds = YES;
    
    
    [self zombifyButton:self.applyUndoChangesButton];
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


-(void)zombifyButton:(UIButton*)victim
{
    [victim setTitle:nil forState:UIControlStateNormal];
    victim.tintColor = [UIColor clearColor];
}


@end
