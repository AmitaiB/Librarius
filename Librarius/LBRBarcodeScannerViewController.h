//
//  LBRBarcodeScannerViewController.h
//  Librarius
//
//  Created by Amitai Blickstein on 8/23/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class Volume;
@interface LBRBarcodeScannerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSMutableArray <NSString*> *uniqueCodes;
//@property (nonatomic, strong) Volume *volumeToConfirm;

@end

