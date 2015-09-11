//
//  LBRShelvesFlowCollectionViewController.h
//  Librarius
//
//  Created by Amitai Blickstein on 9/9/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface LBRShelvesViewController : UICollectionViewController <NSFetchedResultsControllerDelegate, NSFetchedResultsSectionInfo, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
