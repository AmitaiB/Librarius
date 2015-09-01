//
//  MasterViewController.h
//  HisMovies
//
//  Created by Amitai Blickstein on 8/25/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "LBRDataStore.h"


@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, NSFetchedResultsSectionInfo>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) LBRDataStore *dataStore;

@end

