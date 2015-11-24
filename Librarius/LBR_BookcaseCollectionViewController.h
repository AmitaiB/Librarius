//
//  LBR_BookcaseCollectionViewController.h
//  Librarius
//
//  Created by Amitai Blickstein on 10/16/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

    //Frameworks
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <iAd/iAd.h>

@class Bookcase;
@class LBR_BookcaseLayout;
@interface LBR_BookcaseCollectionViewController : UICollectionViewController <NSFetchedResultsControllerDelegate, UIPopoverPresentationControllerDelegate, UIAdaptivePresentationControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *volumesFetchedResultsController;
@property (nonatomic, strong) Bookcase *bookcaseOnDisplay;
@property (nonatomic, strong) LBR_BookcaseLayout *layout;

@end
