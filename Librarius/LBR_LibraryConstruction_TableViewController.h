//
//  LBR_LibraryConstruction_TableViewController.h
//  Librarius
//
//  Created by Amitai Blickstein on 11/9/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

/**
 Abstract: This Scene displays manipulatable data models of the user's library.
 It will provide a schematic overview of the user's libraries, and is the place
 for creating and setting the details of the spaces (shelves) it contains.
 
TODO:
 1) HeaderView displaying the "Current Library" (in a collectionView)
 2) NavigationItems for Editing and '+' (add bookcase, or add library?)
 3) Rearrange the bookcase order.

 +_+_+ Ability to add an image to bookcase - UIImagePicker
 
 +_+_+ Consider making the dataSource separate, if bookcases will be displayed in the same way. Or maybe that's too much...
 */

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface LBR_LibraryConstruction_TableViewController : UITableViewController <UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end
