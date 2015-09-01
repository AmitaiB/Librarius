//
//  LBRPresentVolumesTableViewController.h
//  Librarius
//
//  Created by Amitai Blickstein on 9/1/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBRGoogleGTLClient.h"


/**
 *  Given an array of GTLVolumes, this tableViewController should display the top [up to 5] possibilities, and will "return" the one selected by the user -- that is, pass it to the dataManager.
 */
@interface LBRPresentVolumesTableViewController : UITableViewController

@property (nonatomic, strong) GTLBooksVolumes *volumes;


@end
