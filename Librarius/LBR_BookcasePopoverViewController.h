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
@property (nonatomic, weak) IBOutlet UIStepper *numShelvesStepper;
@property (nonatomic, weak) IBOutlet UIStepper *shelfWidthStepper;

//@property (nonatomic, strong) NSString *numFieldText;
//@property (nonatomic, strong) NSString *widthFieldText;

@property (nonatomic, assign) NSUInteger popoverNumShelves;
@property (nonatomic, assign) CGFloat popoverShelfWidth;

@end
