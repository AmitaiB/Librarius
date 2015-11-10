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
 1) HeaderView displaying the "Current Library" (and/or an Image: pod 'APParallaxHeader'??)
 2) 1st TableViewCell = CollectionView of available Libraries.
 2a) Last collectionView cell is an empty, big "+" sign, to add Libraries (is that annoying? Maybe also
 have another way to get to adding libraries).
 3) Each subsequent cell is a physical bookcase.
 3a) Last tableView cell is an empty, big "+" sign, to add Bookcases to the current library.
 

 +_+_+ Ability to add an image to bookcase?
 
 +_+_+ Consider making the dataSource separate, if bookcases will be displayed in the same way. Or maybe that's too much...
 
 +_+_+ Note: Maybe use a groupedStyle, of one section, so that the header (current selected Library) will Float, always visible.
 
 
 http://ashfurrow.com/blog/putting-a-uicollectionview-in-a-uitableviewcell/
 */

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface LBR_LibraryConstruction_TableViewController : UITableViewController <UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate>

    //Probably not needed
//@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
//@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end
