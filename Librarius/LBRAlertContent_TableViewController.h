//
//  LBRAlertContent_TableViewController.h
//  Librarius
//
//  Created by Amitai Blickstein on 9/21/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Volume;
@interface LBRAlertContent_TableViewController : UITableViewController

@property (nonatomic, strong) Volume *volumeToConfirm;

@end
