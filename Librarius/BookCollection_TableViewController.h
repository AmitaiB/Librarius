//
//  BookCollectionViewController.h
//
//  Created by Amitai Blickstein on 8/25/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <iAd/iAd.h>
#import "LBR_ResultsTableViewController.h"

@interface BookCollection_TableViewController : UITableViewController <NSFetchedResultsControllerDelegate, UIScrollViewDelegate, UISearchResultsUpdating>

@property (strong, nonatomic) NSFetchedResultsController *volumesFetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

