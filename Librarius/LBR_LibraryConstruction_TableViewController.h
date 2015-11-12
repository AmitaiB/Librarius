//
//  LBR_LibraryConstruction_TableViewController.h
//  Librarius
//
//  Created by Amitai Blickstein on 11/9/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

/**
 Abstract: This TVC will allow the user to create a Library of arbitrary size,
  which will be stored in CoreData.
 
 Goals:
 1) HeaderView displaying the "Current Library" (in a collectionView)
 2) NavigationItems for Editing and '+' (add bookcase, or add library?)
 3) Rearrange the bookcase order.

 +_+_+ Ability to add an image to bookcase - UIImagePicker
 
 +_+_+ Consider making the dataSource separate, if bookcases will be displayed in the same way. Or maybe that's too much...
 
 
 http://ashfurrow.com/blog/putting-a-uicollectionview-in-a-uitableviewcell/
 */

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface LBR_LibraryConstruction_TableViewController : UITableViewController <UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate>

@end
