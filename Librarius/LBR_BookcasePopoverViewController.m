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

@property (nonatomic, strong) IBOutlet UIStepper *numShelvesStepper;
@property (nonatomic, strong) IBOutlet UIStepper *shelfWidthStepper;
@property (weak, nonatomic) IBOutlet UIButton *applyUndoChangesButton;
- (IBAction)applyUndoChangesButtonTapped:(id)sender;
@end

@implementation LBR_BookcasePopoverViewController

-(void)viewDidLoad
{
    [super viewDidLoad];

}

- (IBAction)applyUndoChangesButtonTapped:(id)sender {
}
@end
