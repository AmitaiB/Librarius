//
//  LBR_ProgrammaticPopoverViewController.h
//  Librarius
//
//  Created by Amitai Blickstein on 11/9/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBR_ProgrammaticPopoverViewController : UIViewController

@property (strong, nonatomic) UIView *contentView;
@property (nonatomic, strong)  UIStepper *numShelvesStepper;
@property (nonatomic, strong)  UIStepper *shelfWidthStepper;

    //@property (nonatomic, strong) NSString *numFieldText;
    //@property (nonatomic, strong) NSString *widthFieldText;

@property (nonatomic, assign) NSUInteger popoverNumShelves;
@property (nonatomic, assign) CGFloat popoverShelfWidth;


@end
