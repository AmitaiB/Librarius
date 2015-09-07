//
//  LBRPresentVolumesTableViewController.h
//  Librarius
//
//  Created by Amitai Blickstein on 9/1/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

/* CLEAN:
 produce a three-stage lazy load:
 1. No data (i.e. an empty table)
 2. Text-only data from the model's RSS feed
 3. Images loaded over the network asynchronously
 
 This process allows for asynchronous loading of the table to keep the UI responsive.
 Images are scaled to the desired height.
 If rapid scrolling is in progress, downloads do not begin until scrolling has ended.
*/

#import <UIKit/UIKit.h>
#import "LBRGoogleGTLClient.h"
#import "LBRDataManager.h"


/**
 *  Given an array of GTLVolumes, this tableViewController should display the top [up to 5] possibilities, and will "return" the one selected by the user -- that is, pass it to the dataManager.
 */
@interface LBRSelectVolumeTableViewController : UITableViewController

@property (nonatomic, strong) GTLBooksVolumes *volumesToDisplay;
@property (nonatomic, strong) LBRDataManager *dataManager;

@end
