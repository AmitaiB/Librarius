//
//  LBR_LibraryConstruction_TableViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 11/9/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

    //Models
#import "RootCollection.h"
#import "Library.h"
#import "Bookcase.h"
#import "Volume.h"

    //Views
#import "LBR_LibraryConstruction_CollectionViewCell.h"
#import "LBR_Bookcase_TableViewCell.h"

    //Controllers
#import "LBR_LibraryConstruction_TableViewController.h"
#import "LBR_BookcaseCollectionViewController.h" //For segue.

    //Data
#import "LBRDataManager.h"
#import "LBR_BookcaseLayout.h"
#import "NSObject+ABBNumberUtils.h"

/**
 Abstract: This VC displays the library structure, and allows for adding/removing/editing the libraries and shelves.
 The HeaderView will have a collectionView in it, displaying a cell for each Library.
 To add a bookcase, we will try to implement a dedicated TableViewCell.
 */

@interface LBR_LibraryConstruction_TableViewController () {
        BOOL userChangingBookcaseOrder;
}

@property (nonatomic, strong) NSFetchedResultsController *bookcasesFetchedResultsController;


    //Library Selection (CollectionView)
@property (weak, nonatomic) IBOutlet UICollectionView *librariesCollectionView;
@property (nonatomic, assign) NSIndexPath *selectedLibraryIndexPath;
- (IBAction)addLibraryButtonTapped:(id)sender; //Add Library button...

    //Bookcase Selection (TableView)
@property (nonatomic, assign) NSInteger rowNumOfAddBookcaseButton;

    //Shelving Support
@property (nonatomic, strong) NSArray<Bookcase*> *shelvedBookcaseObjectsForSegue;


    //Layout Selection (Segmented Control) - NOT YET IMPL

    //Not Yet Implemented
@property (nonatomic, strong) UISegmentedControl *layoutSegmentedControl;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
//@property (weak, nonatomic) IBOutlet UIView *addBookcaseFooterView; //For "Add Bookcase" tableViewCell - if I want to do it that way.


@end

@implementation LBR_LibraryConstruction_TableViewController {
    LBRDataManager *dataManager;
}


static NSString * const bookcaseCellReuseID                = @"bookcaseCellReuseID";
static NSString * const addBookcaseCellReuseID             = @"addBookcaseCellReuseID";
static NSString * const librariesCollectionViewCellReuseID = @"librariesCollectionViewCellReuseID";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dataManager = [LBRDataManager sharedDataManager];
    self.bookcasesFetchedResultsController = [dataManager currentLibraryBookcasesFetchedResultsController:self];
    self.rowNumOfAddBookcaseButton = self.bookcasesFetchedResultsController.fetchedObjects.count;
    
        //Layout
    self.layoutSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"layout 1", @"layout 2"]];
    self.layoutSegmentedControl.selectedSegmentIndex = 0;
    self.navigationItem.titleView = self.layoutSegmentedControl;
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    [self initRefreshControl];
        //Prevents the refreshControl from being visible upon loading.
    [self.tableView setContentOffset:CGPointMake(0, self.topLayoutGuide.length -self.refreshControl.frame.size.height) animated:YES];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    [self reshelveBookcasesInCurrentLibrary];
}

-(void)attachAllVolumesToCurrentLibraryIfNeeded
{
    NSFetchRequest *volumesRequest = [NSFetchRequest fetchRequestWithEntityName:[Volume entityName]];
    NSArray *allVolumes = [dataManager.managedObjectContext executeFetchRequest:volumesRequest error:nil];
//    NSFetchedResultsController *allVolumesFRC = [dataManager currentLibraryVolumesFetchedResultsController];
//    NSArray *allVolumes = allVolumesFRC.fetchedObjects;
    for (Volume *volume in allVolumes) {
        if (!volume.library) {
            DDLogDebug(@"In attachAllVolumesToCurrentLibraryIfNeeded.\nVolume \"%@\"\nBEFORE: library = %@", volume.title, volume.library.name);
            volume.library = dataManager.currentLibrary;
            DDLogDebug(@"\nAFTER: library = %@", volume.library.name);
        }
    }
    [dataManager saveContext];
}

-(void)initRefreshControl
{
    self.refreshControl                 = [UIRefreshControl new];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor       = [UIColor whiteColor];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Reshelving books..."];
   [self.refreshControl addTarget:self action:@selector(reshelveBookcasesInCurrentLibrary) forControlEvents:UIControlEventValueChanged];
}

    /**
     ✅1) Have the library object shelve itself.
     -> Now the Bookcase objects should have shelvesArrays (and the Volumes should be related to the Bookcase), and we should capture the unshelvedRemainderBooks.
     ✅2) Make sure the tableViewCells can read the relevant info from the Bookcase object.
     ✅3) Reload the data [in the current Library's section?].
     4) Delcare Victory and Go Home
     */
-(void)reshelveBookcasesInCurrentLibrary
{
    [self attachAllVolumesToCurrentLibraryIfNeeded];
    DDLogVerbose(@"reshelveBookcasesInCurrentLibrary should be implemented here."); //0
//    NSArray<Volume*> *unshelvedBooksRemaining =
    [dataManager.currentLibrary shelveVolumesOnBookcasesAccordingToLayoutScheme:LBRLayoutSchemeDefault];    //1
    [self.tableView reloadData];                                                    //3
    if ([self.refreshControl isRefreshing]) [self.refreshControl endRefreshing];
}



#pragma mark - === UIImagePickerController delegate ===

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
//    NSData profilePhoto = [info objectForKey:UIImagePickerControllerOriginalImage];
//
//
//        // Convert to JPEG with 50% quality
//    NSData* data = UIImageJPEGRepresentation(self.profilePhoto, 0.3f);
//
//    self.pfPhoto = [PFFile fileWithName:@"ProfilePhoto" data:data];
//
//    [self.uploadProfilePhotoButton setTitle:@"Nice Pic!" forState:UIControlStateDisabled];
//    self.uploadProfilePhotoButton.enabled = NO;
    
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
    
}

/*
    //    [self configureImagePickerController];
-(void)configureImagePickerController
{
    self.imagePickerController = [UIImagePickerController new];
    self.imagePickerController.delegate = self;
    [self.imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
    self.imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
}


-(IBAction)bookcaseIconWasTapped:(id)sender
{
    [self.navigationController presentViewController:self.imagePickerController animated:YES completion:nil];
}
*/

#pragma mark - === UITableView DataSource ===

    ///The bookcases' sections are the libraries.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.bookcasesFetchedResultsController.sections.count;
}


    ///Each row is a bookcase.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)tableSection
{
    NSArray *sections = self.bookcasesFetchedResultsController.sections;
    if (sections.count) {
        id <NSFetchedResultsSectionInfo> currentSection = sections[tableSection];
        return currentSection.numberOfObjects +1;
    }
    else
    {
        DDLogWarn(@"Section %lu has no rows.", tableSection);
        return 0;
    }
}


    // Set the name (& size)
    // Volumes and fullness
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LBR_Bookcase_TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bookcaseCellReuseID forIndexPath:indexPath];
    [self configureCell:cell forRowAtIndexPath:indexPath];

    return cell;
}

    //UPDATE: --> Note still relevant???:
    //Note: If there's no bookcase, it crashes the collectionView.
-(void)configureCell:(LBR_Bookcase_TableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != self.rowNumOfAddBookcaseButton) {
        
        NSArray *bookcasesInOrder = [dataManager.currentLibrary.bookcases sortedArrayUsingDescriptors:dataManager.bookcasesRequest.sortDescriptors];
        cell.bookcase = bookcasesInOrder[indexPath.row];
        
        /* DON'T DELETE - WARNING TO FUTURE TAMPERING -- the cells rely on a transient attribute, which
         is lost when the object is fetched from the persistent store.
         ///This won't have laidOutModel!
        cell.bookcase = self.bookcasesFetchedResultsController.fetchedObjects[indexPath.row];
        cell.bookcase = self.shelvedBookcaseObjectsForSegue[indexPath.row];
        */
        
            ///Cannot delete the last bookcase in a library (workaround the problem of the disappearing Section).
//        if (indexPath.row == self.rowNumOfAddBookcaseButton -1) {
//            cell.accessoryType        = UITableViewCellAccessoryNone;
//            cell.selectionStyle       = UITableViewCellSelectionStyleNone;
//        }
    }
    else
    {
            // Makes the last cell the addBookcaseButton
        [cell.imageView setImage:[UIImage imageNamed:@"add-row"]];
        cell.textLabel.text       = @"Add new bookcase to current library";
        cell.textLabel.font       = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:17];
        cell.detailTextLabel.text = @"";
        cell.accessoryType        = UITableViewCellAccessoryNone;
        cell.selectionStyle       = UITableViewCellSelectionStyleNone;
    }
    
}

    ///Just needed to fold when not in selected library.


#pragma mark Headers/Footers
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == self.selectedLibraryIndexPath.section) {
        return [NSString stringWithFormat:@"Current Library: %@", dataManager.currentLibrary.name];
    }
    else
        return nil;
}


    ///The footer should display the remaining unshelved books
-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSSet *setOfUnshelvedBooksRemaining = [dataManager.currentLibrary.volumes filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"%K == nil", @"bookcase"]];
    
    CGFloat totalVolumesCount = (CGFloat)dataManager.currentLibrary.volumes.count;
    CGFloat unshelvedVolumesCount = (CGFloat)setOfUnshelvedBooksRemaining.count;
    CGFloat shelvedVolumesCount = totalVolumesCount - unshelvedVolumesCount;
    CGFloat percentShelved = (totalVolumesCount - unshelvedVolumesCount)/totalVolumesCount * 100;
    CGFloat percentUnshelved = 100.0 - percentShelved;
    if (totalVolumesCount == 0) percentShelved = 0; //Cannot divide by 0
    NSString *unshelvedBooksReport = [NSString stringWithFormat:@"%.0f total volumes\n%.0f%% (%.0f volumes) shelved\n%.0f%% (%.0f volumes) remain unshelved", totalVolumesCount, percentShelved, shelvedVolumesCount, percentUnshelved, unshelvedVolumesCount];
    return unshelvedBooksReport;
}


#pragma mark - === UITableView Delegate methods ===



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.rowNumOfAddBookcaseButton) {
//        DDLogVerbose(@"Here is where you add a new bookcase");
        [self addBookcaseCellTapped];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else
        DDLogVerbose(@"didSelectRowAtIndexPath: %@\nrow: %lu\nsection: %lu\n(TODO: Implement a PrepareForSegue for the CollectionView", indexPath, indexPath.row, indexPath.section);
}

    ///Hides unselected libraries, by setting the height for rows of inactive Libraries (sections) to 0 or close to it.
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        //Grab the selected section, and shrink all *other* sections' rows.
    NSIndexPath *tableViewIndexPath = indexPath;
    NSIndexPath *selectedOrDefaultLibraryIndexPath = self.selectedLibraryIndexPath ? self.selectedLibraryIndexPath : [NSIndexPath indexPathForItem:0 inSection:0];
    
//    if (tableViewIndexPath.section == 0)
//        return 106.0;
    if (tableViewIndexPath.section == selectedOrDefaultLibraryIndexPath.item) {
        return 44;
    }
    else
        return 1;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.rowNumOfAddBookcaseButton -1) {
        return NO;
    }
    return YES;
}

    ///TODO: Add check if it's the last section. If so, don't delete, just hide.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        id object = [self.bookcasesFetchedResultsController objectAtIndexPath:indexPath];
        [dataManager.managedObjectContext deleteObject:object];
        [dataManager saveContext];
        self.rowNumOfAddBookcaseButton--;

    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        //UPDATE: Adding bookcases is done via the AddBookcaseCell
    }   
}


 // Uncomment and debug to support rearranging the table view.
/*
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
        //Bypass the fetchedResultsController delegates temporarily
    userChangingBookcaseOrder = YES;
    
        //Get a handle to the bookcases we're moving
    NSMutableArray *sortedBookcases = [NSMutableArray arrayWithArray:self.bookcasesFetchedResultsController.fetchedObjects];
    
        //Get a handle to the call we're moving
    Bookcase *bookcaseWeAreMoving = sortedBookcases[fromIndexPath.row];
    
        //Remove the call from its current position
    [sortedBookcases removeObjectAtIndex:fromIndexPath.row];
    
        //Insert it at its new position
    [sortedBookcases insertObject:bookcaseWeAreMoving atIndex:toIndexPath.row];
    
        //Update the order of the objects, each according to its index in the mutable array
    [sortedBookcases enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Bookcase *myBookcase = (Bookcase*)obj;
        myBookcase.orderWhenListed = @(idx);
    }];

    NSInteger section = fromIndexPath.section;
    /*
    
        for (NSInteger row = 0; row < [tableView numberOfRowsInSection:section]; row++) {
            LBR_Bookcase_TableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
            cell.bookcase.orderWhenListed = @(row);
            DDLogDebug(@"Row %lu has a Bookcase of order: %@", row, cell.bookcase.orderWhenListed);
        }
     
     /* /
    
        //Save the managed object context
    [dataManager saveContext];
    
        //Allow the delegates to work once more
    userChangingBookcaseOrder = NO;
    
        //reload the altered section
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
}


 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
     if (indexPath.row >= self.rowNumOfAddBookcaseButton -1) {
         return NO;
     }
     
     
 return YES;
 }
*/

#pragma mark private methods

    ///???:
-(NSNumber*)orderWhenListedOfBookcaseForIndexPath:(NSIndexPath*)indexPath
{
    return @(indexPath.row);
}

-(void)addBookcaseCellTapped
{
    Bookcase *newBookcase = [Bookcase insertNewObjectIntoContext:dataManager.managedObjectContext];

        //Standard
    newBookcase.dateCreated     = [NSDate date];
    newBookcase.dateModified    = [newBookcase.dateCreated copy];
    newBookcase.shelves         = @(kDefaultBookcaseShelvesCount);
    newBookcase.width           = @(kDefaultBookcaseWidth_cm);
    newBookcase.name            = [NSString stringWithFormat:@"BookcaseID #%.01f", [NSObject randomFloatBetweenNumber:10000 andNumber:99999]];
    newBookcase.isFull          = @NO;
    
        //Specific to this object
    newBookcase.orderWhenListed = @(++self.rowNumOfAddBookcaseButton);
    newBookcase.library         = dataManager.currentLibrary;
    
    [dataManager saveContext];
        ///How do we shelve it? Automatically when you add it?
}



#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"bookcaseTableViewToBookshelfCollectionViewSegueID"])
    {
        LBR_Bookcase_TableViewCell *cell = sender;
        if (cell.bookcase == nil) return NO;
    }
    
    return YES;
}
    ///Needs to send a Bookcase object. Does send bookcase object.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"bookcaseTableViewToBookshelfCollectionViewSegueID"]) {
        LBR_BookcaseCollectionViewController *destinationVC = segue.destinationViewController;
        LBR_Bookcase_TableViewCell *senderCell = (LBR_Bookcase_TableViewCell*)sender;
        destinationVC.bookcaseOnDisplay        = senderCell.bookcase; /// <~
        dataManager.currentBookcase            = senderCell.bookcase;
    } else {
        DDLogWarn(@"WARNING: prepareForSegue shouldn't have triggered this.");
    }
}


#pragma mark - === UICollectionView DataSource ===

    ///The CollectionView has only 1 section, each item/cell representing one library (or tableView-section).
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return MAX(1, dataManager.userRootCollection.libraries.count);
    
//    if (self.bookcasesFetchedResultsController.sections.count <= 0)
//        DDLogError(@"There are no sections returned from the FRC!");
//    return MAX(1, self.bookcasesFetchedResultsController.sections.count);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LBR_LibraryConstruction_CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:librariesCollectionViewCellReuseID forIndexPath:indexPath];
    
        //configure cell here
    [self configureCollectionViewCell:cell forItemAtIndexPath:indexPath];
    
    return cell;
}


    ///Each collectionViewCell represents a Library.
-(void)configureCollectionViewCell:(LBR_LibraryConstruction_CollectionViewCell*)cell forItemAtIndexPath:(NSIndexPath*)indexPath
{
    cell.libraryLabel.text = dataManager.currentLibrary.name;
    [cell.librarySelectionCellImageView setImage:[UIImage imageNamed:@"home-library1"]];
    cell.libraryLabel.layer.cornerRadius = 10;
}

#pragma mark - === UICollectionViewDelegate ===


 // Uncomment this method to specify if the specified item should be highlighted during tracking
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}


    ///Selects the current library.
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
        //If tapped currently selected cell, then change nothing.
    if (self.selectedLibraryIndexPath == indexPath)
        return;
    
    [self respondToLibraryItemSelectionAtIndexPath:indexPath];
}

-(void)respondToLibraryItemSelectionAtIndexPath:(NSIndexPath*)indexPath
{
    self.selectedLibraryIndexPath = indexPath;
    NSArray *orderedLibraries = [dataManager.userRootCollection.libraries sortedArrayUsingDescriptors:@[dataManager.sortDescriptors[kOrderSorter]]];
    dataManager.currentLibrary = orderedLibraries[indexPath.item];
    [self.refreshControl beginRefreshing];
    
//    [dataManager.currentLibrary shelveVolumesOnBookcasesAccordingToLayoutScheme:LBRLayoutSchemeDefault];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    DDLogVerbose(@"dataManager.currentLibrary now = %@", dataManager.currentLibrary.name);
}

/*
 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
 }
 
 - (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
 }
 
 - (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
 }
 */


#pragma mark - === NSFetchedResultsController ===

#pragma mark Fetched Results Controller configuration

//-(NSFetchedResultsController *)librariesFetchedResultsController
//{
//    if (_librariesFetchedResultsController != nil) {
//        return _librariesFetchedResultsController;
//    }
//    
//    NSFetchedResultsController *frc;
//    [self configureFetchedResultsController:frc ForEntityName:@"Library"];
//    
//    return frc;
//}

/*
-(NSFetchedResultsController *)bookcasesFetchedResultsController
{
    if (_bookcasesFetchedResultsController != nil) {
        return _bookcasesFetchedResultsController;
    }
    
    NSFetchedResultsController *frc;
    /**
     *  1) The set of all [Entity Name]
     *  2) ...arranged by userOrder,
     *  3) ...then date created.
     * /
    dataManager = dataManager ? dataManager : [LBRDataManager sharedDataManager];
    NSManagedObjectContext *managedObjectContext = dataManager.managedObjectContext;
    [dataManager generateDefaultLibraryIfNeeded];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[Bookcase entityName]]; //(1)
    
        // Edit the sort key as appropriate.
    NSSortDescriptor *orderSorter       = [NSSortDescriptor sortDescriptorWithKey:@"orderWhenListed" ascending:YES];
    NSSortDescriptor *dateCreatedSorter = [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES];
    
    request.fetchBatchSize = 200;
    request.sortDescriptors = @[orderSorter, dateCreatedSorter];
    request.returnsObjectsAsFaults = NO;
    
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
    frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                              managedObjectContext:managedObjectContext
                                                sectionNameKeyPath:@"library.name"
                                                         cacheName:@"LBR_Bookcase_CacheName"];
    
    NSError *error = nil;
    if (![frc performFetch:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. !!!:You should not use this function in a shipping application, although it may be useful during development.
        DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    NSArray *bookcasesMaybe = [frc.managedObjectContext executeFetchRequest:request error:nil];
    
    if (bookcasesMaybe.count == 0) {
        [dataManager generateBookcasesForLibrary:dataManager.currentLibrary withDimensions:@{@3 : @7,
                                                                                             @5 : @5,
                                                                                             @2 : @20
                                                                                             }];
        [frc performFetch:nil];
    }
    
    return frc;
}
*/
#pragma mark - === Fetched Results Controller Delegate methods ===

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (userChangingBookcaseOrder) return;
    
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if (userChangingBookcaseOrder) return;
    
    UITableView *tableView = self.tableView;
    
        //Note to self: changed UITableViewRowAnimationFade to UI..Automatic. Does it look good?
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
//            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] forIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */


- (IBAction)addLibraryButtonTapped:(id)sender {
    DBLG
}

@end
