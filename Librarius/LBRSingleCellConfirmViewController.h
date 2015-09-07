//
//  LBRSingleCellConfirmViewController.h
//  Librarius
//
//  Created by Amitai Blickstein on 9/6/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "NYAlertViewController.h"

@class LBRParsedVolume;
@interface LBRSingleCellConfirmViewController : UITableViewController

@property (nonatomic, strong) LBRParsedVolume *sourceVolume;
@property (nonatomic, strong) UITableView *singleCellTableView;


@end
