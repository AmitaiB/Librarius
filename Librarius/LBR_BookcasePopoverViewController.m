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

@property (nonatomic, weak) IBOutlet UITextField *numShelvesTxField;
@property (nonatomic, weak) IBOutlet UITextField *shelfWidth_cmTxField;
@property (nonatomic, weak) IBOutlet UIStepper *numShelvesStepper;
@property (nonatomic, weak) IBOutlet UIStepper *shelfWidthStepper;
@property (weak, nonatomic) IBOutlet UIButton *applyUndoChangesButton;
- (IBAction)applyUndoChangesButtonTapped:(id)sender;
@end

@implementation LBR_BookcasePopoverViewController

-(void)viewDidLoad
{
    [super viewDidLoad];

}

-(void)setNumFieldText:(NSString *)numFieldText
{
    if ([numFieldText isEqualToString:@"1"])
    {
        _numFieldText = [NSString stringWithFormat:@"%@ shelf", numFieldText];
    }
    else
    {
        _numFieldText = [NSString stringWithFormat:@"%@ shelves", numFieldText];
    }
    
    self.numShelvesTxField.text = _numFieldText;
}

-(void)setWidthFieldText:(NSString *)widthFieldText
{
    _widthFieldText = [NSString stringWithFormat:@"%@ cm", widthFieldText];
    
    self.shelfWidth_cmTxField.text = _widthFieldText;
}


- (IBAction)applyUndoChangesButtonTapped:(id)sender {
}
@end
