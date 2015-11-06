//
//  LBR_BookcasePopoverViewController.h
//  Librarius
//
//  Created by Amitai Blickstein on 11/5/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBR_BookcasePopoverViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *contenView;

@property (nonatomic, strong) IBOutlet UITextField *numShelvesTxField;
@property (nonatomic, strong) IBOutlet UITextField *shelfWidth_cmTxField;
@property (nonatomic, strong) IBOutlet UIStepper *numShelvesStepper;
@property (nonatomic, strong) IBOutlet UIStepper *shelfWidthStepper;

@end
