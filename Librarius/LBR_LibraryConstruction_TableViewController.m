//
//  LBR_LibraryConstruction_TableViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 11/9/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

    //Models
#import "Library.h"
#import "Bookcase.h"

    //Views
#import "LBR_LibraryConstruction_CollectionViewCell.h"
#import "LBR_Bookcase_TableViewCell.h"

    //Controllers
#import "LBR_LibraryConstruction_TableViewController.h"
#import "LBR_BookcaseCollectionViewController.h"

    //Data
#import "LBRDataManager.h"
#import "RootCollection.h"

/**
 Abstract: This VC displays the library structure, and allows for adding/removing/editing the libraries and shelves.
 The HeaderView will have a collectionView in it, displaying a cell for each Library.
 */

@interface LBR_LibraryConstruction_TableViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController *bookcasesFetchedResultsController;
//@property (nonatomic, strong) NSArray *tableRowsPerSection;

@property (nonatomic, assign) NSIndexPath *selectedLibraryIndexPath;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@property (weak, nonatomic) IBOutlet UICollectionView *librariesCollectionView;
- (IBAction)addButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *addBookcaseFooterView;
- (IBAction)addBookcaseButtonTapped:(id)sender;


@end

@implementation LBR_LibraryConstruction_TableViewController {
    LBRDataManager *dataManager;
}


static NSString * const bookcaseCellReuseID                = @"bookcaseCellReuseID";
static NSString * const addBookcaseCellReuseID             = @"addBookcaseCellReuseID";
static NSString * const librariesCollectionViewCellReuseID = @"librariesCollectionViewCellReuseID";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bookcasesFetchedResultsController.delegate = self;

    dataManager = [LBRDataManager sharedDataManager];

    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    [self configureImagePickerController];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


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
#pragma mark - === UITableView DataSource ===

    ///Each section is a library's bookcases.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.bookcasesFetchedResultsController.sections.count;
}


    ///Each row is a bookcase.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)tableSection
{
    NSArray *sections = self.bookcasesFetchedResultsController.sections;
    if (sections.count) {
        id <NSFetchedResultsSectionInfo> currentSection = sections[tableSection];
        return currentSection.numberOfObjects;
    }
    else
    {
        DDLogWarn(@"Section %lu has no rows.", tableSection);
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LBR_Bookcase_TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bookcaseCellReuseID forIndexPath:indexPath];
    
    
    // Configure the cell...
    // Set the name (& size)
    // Volumes and fullness
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    
    return cell;
}

-(void)configureCell:(LBR_Bookcase_TableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.bookcase = self.bookcasesFetchedResultsController.fetchedObjects[indexPath.row];
}

    ///Just needed to fold when not in selected library.

//-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    
//    NSLayoutConstraint *heightConstraint = [self.addBookcaseFooterView.heightAnchor constraintEqualToConstant:1];
//    heightConstraint.priority = 1000;
//    heightConstraint.active = YES;
//    return self.addBookcaseFooterView;
//}


#pragma mark Header
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == self.selectedLibraryIndexPath.section) {
        return [NSString stringWithFormat:@"Current Library: %@", dataManager.currentLibrary.name];
    }
    else
        return nil;
}

    //TODO: Why is this the wrong height?
/*
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return self.tableView.tableHeaderView.intrinsicContentSize.height;
    }
    else
        return self.tableView.sectionHeaderHeight;
}
*/

#pragma mark - === UITableView Delegate methods ===

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogVerbose(@"didSelectRowAtIndexPath: %@\nrow: %lu\nsection: %lu", indexPath, indexPath.row, indexPath.section);
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
        DDLogDebug(@"section = %lu -- item = %lu", tableViewIndexPath.section,selectedOrDefaultLibraryIndexPath.item);
        return 44;
    }
    else
        return 1;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
//    Make sure it's reflected in Core data
}

-(NSNumber*)orderWhenListedOfBookcaseForIndexPath:(NSIndexPath*)indexPath
{
    return @(indexPath.row);
}

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"bookshelfToBookShelveSegueID"]) {
        LBR_BookcaseCollectionViewController *destinationVC = segue.destinationViewController;
        LBR_Bookcase_TableViewCell *senderCell = (LBR_Bookcase_TableViewCell*)sender;
        destinationVC.bookcaseOnDisplay = senderCell.bookcase;
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
    return MAX(1, dataManager.rootCollection.libraries.count);
    
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
}

#pragma mark - === UICollectionViewDelegate ===


 // Uncomment this method to specify if the specified item should be highlighted during tracking
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
 }


    ///Selects the current library.
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedLibraryIndexPath = indexPath;
    dataManager.currentLibrary;
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
     */
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
//    DDLogDebug(@"frc.fetchedObjects = %@ (count: %lu)", frc.fetchedObjects, frc.fetchedObjects.count);
    DDLogDebug(@"frc.fetchedObjects.count = %lu", frc.fetchedObjects.count);
    
    
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


    //What was this for again??
/*
-(void)configureFetchedResultsController:(NSFetchedResultsController*)frc ForEntityName:(NSString*)entityName
{
    /**
     *  1) The set of all [Entity Name]
     *  2) ...arranged by userOrder,
     *  3) ...then date created.
     * /
    dataManager = dataManager ? dataManager : [LBRDataManager sharedDataManager];
    NSManagedObjectContext *managedObjectContext = dataManager.managedObjectContext;
    [dataManager generateDefaultLibraryIfNeeded];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName]; //(1)
    
        // Edit the sort key as appropriate.
    NSSortDescriptor *orderSorter       = [NSSortDescriptor sortDescriptorWithKey:@"orderWhenListed" ascending:YES];
    NSSortDescriptor *dateCreatedSorter = [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES];
    
    request.fetchBatchSize = 20;
    request.sortDescriptors = @[orderSorter, dateCreatedSorter];
    
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
    frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:[NSString stringWithFormat:@"LBR_LibrarySelection-%@-CacheName", entityName]];
    
    NSError *error = nil;
    if (![frc performFetch:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. !!!:You should not use this function in a shipping application, although it may be useful during development.
        DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}
*/

#pragma mark - === Fetched Results Controller Delegate methods ===

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
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


- (IBAction)addButtonTapped:(id)sender {
    DBLG
}

- (IBAction)addBookcaseButtonTapped:(id)sender {
    DBLG
}
@end
