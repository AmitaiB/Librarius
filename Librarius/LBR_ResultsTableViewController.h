//
//  LBR_ResultsTableViewController.h
//  Librarius
//
//  Created by Amitai Blickstein on 10/27/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

//Abstract: The TableView Controller responsible for displaying the filtered books as the user types in the search field.

#import <UIKit/UIKit.h>
#import "BookCollection_TableViewController.h"

@interface LBR_ResultsTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *filteredBooks;

@end
