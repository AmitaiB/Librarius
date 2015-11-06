//
//  LBR_BookcasePopoverView.h
//  Librarius
//
//  Created by Amitai Blickstein on 11/5/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBR_BookcasePopoverView : UIView

@property (nonatomic, strong) UITextField *numShelvesTxField;
@property (nonatomic, strong) UITextField *shelfWidth_cmTxField;
@property (nonatomic, strong) UIStepper *numShelvesStepper;
@property (nonatomic, strong) UIStepper *shelfWidthStepper;



@end
