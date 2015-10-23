//
//  LBRRecommendationsCollectionViewController.h
//  Librarius
//
//  Created by Amitai Blickstein on 9/24/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <iAd/iAd.h>

@interface LBRRecommendationsCollectionViewController : UICollectionViewController <NSFetchedResultsControllerDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
