//
//  LBR_BookcasePopoverViewController.h
//  Librarius
//
//  Created by Amitai Blickstein on 11/5/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBR_BookcasePopoverViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, strong) IBOutlet UITextField *numShelvesTxField;
@property (nonatomic, strong) IBOutlet UITextField *shelfWidth_cmTxField;

@end
