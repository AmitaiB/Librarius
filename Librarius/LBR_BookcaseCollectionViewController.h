//
//  LBR_BookcaseCollectionViewController.h
//  Librarius
//
//  Created by Amitai Blickstein on 10/16/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "LBR_BookcaseModel.h"

@interface LBR_BookcaseCollectionViewController : UICollectionViewController <NSFetchedResultsControllerDelegate, NSFetchedResultsSectionInfo, LBRBookLayoutDataSource>

@property (nonatomic, strong) NSArray *fetchedObjects;

@end
