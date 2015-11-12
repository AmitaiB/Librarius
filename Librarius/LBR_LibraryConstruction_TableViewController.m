//
//  LBR_LibraryConstruction_TableViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 11/9/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

    //Models
#import "Library.h"

    //Views
#import "LBR_LibrarySelection_TableViewCell.h"

    //Controllers
#import "LBR_LibraryConstruction_TableViewController.h"

    //Data
#import "LBRDataManager.h"
#import "LBR_LibraryConstruction_CollectionViewCell.h"
#import "Bookcase.h"
/**
 Abstract: The HeaderView will have a collectionView in it, displaying a cell for each Library.
 
 
 */

@interface LBR_LibraryConstruction_TableViewController ()
@property (nonatomic, strong) NSFetchedResultsController *bookcasesFetchedResultsController;

@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;
@property (nonatomic, strong) NSArray *tableRowsPerSection;
@property (nonatomic, assign) NSIndexPath *selectedLibraryIndexPath;

    //Reboot
@property (weak, nonatomic) IBOutlet UICollectionView *librariesCollectionView;
- (IBAction)addButtonTapped:(id)sender;




@end

@implementation LBR_LibraryConstruction_TableViewController {
    LBRDataManager *dataManager;
}


static NSString * const bookcaseCellReuseID = @"bookcaseCellReuseID";
static NSString * const librariesCollectionViewCellReuseID = @"librariesCollectionViewCellReuseID";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.contentOffsetDictionary = [NSMutableDictionary new];
    
    self.bookcasesFetchedResultsController.delegate = self;
//    self.collectionView.delegate = self;
//    self.collectionView.dataSource = self;

    dataManager = [LBRDataManager sharedDataManager];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - = Private Method here =

    ///*Logic encapsulated here.*
    ///
    ///Each section is a Library, as per the Fetch request, PLUS the HeaderView is a collectionView.
    ///Each section has its bookcases, a row for each.
-(NSArray *)tableRowsPerSection
{
    if (_tableRowsPerSection != nil) {
        return _tableRowsPerSection;
    }
    else
    {
        NSArray <id<NSFetchedResultsSectionInfo> > *dataSourceSections = self.bookcasesFetchedResultsController.sections;
        
        __block NSMutableArray <NSNumber*> *mutableTableSections = [NSMutableArray new];
        
        [dataSourceSections enumerateObjectsUsingBlock:^(id<NSFetchedResultsSectionInfo>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [mutableTableSections addObject:@(obj.numberOfObjects + 1)]; //Last Row in each Section is the 'addBookcase' cell.
        }];
        [mutableTableSections insertObject:@(1) atIndex:0]; //For the collectionView
        
        return [mutableTableSections copy];
    }
}

#pragma mark - === UITableView DataSource ===

    ///First section for the collectionView, then a section for each library.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.bookcasesFetchedResultsController.sections.count + 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Current Library: %@", dataManager.currentLibrary.name];
}

    ///Each row is a bookcase.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)tableSection
{
    NSNumber *rowsInSection = self.tableRowsPerSection[tableSection];
    return rowsInSection.integerValue;
}

    //
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LBR_LibrarySelection_TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bookcaseCellReuseID forIndexPath:indexPath];
    
    // Configure the cell...
    if (indexPath.section == 0) {
        [self addCollectionViewToTableViewCell:cell];
    }
    
    
    /**
     FirstSection - CollectionView
     [...] - TableView (what do I want the bookcase cell to look like?
     LastRow - Add Bookcase cell.
     */
    
    return cell;
}

    //CLEAN: Holdover from collectionView in tableViewCell method
/*
    ///Really not sure about this one here.
-(void)collectionView:(UICol lectionView *)collectionView willDisplayCell:(LBR_LibrarySelection_TableViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];
    NSInteger index = cell.collectionView.tag;
    
    CGFloat horizontalOffset = [self.contentOffsetDictionary[@(index).stringValue] floatValue];
    [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
}
*/
 
#pragma mark private method
-(void)addCollectionViewToTableViewCell:(UITableViewCell*)cell
{
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.itemSize = CGSizeMake(44, 44);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:collectionViewCellReuseID];
    collectionView.backgroundColor = [UIColor purpleColor];
    collectionView.showsHorizontalScrollIndicator = NO;
    
    [cell.contentView addSubview:collectionView];
    collectionView.frame = cell.bounds;
}


#pragma mark - === UITableView Delegate methods ===

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogVerbose(@"didSelectRowAtIndexPath: %@\nrow: %lu\nsection: %lu", indexPath, indexPath.row, indexPath.section);
}

    //Hides unselected libraries, by setting the unselected rows to 0 or close to it.
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *tableIndexPath = indexPath;
    NSIndexPath *collectionIndexPath = self.selectedLibraryIndexPath ? self.selectedLibraryIndexPath : [NSIndexPath indexPathForItem:0 inSection:0];
    
    if (tableIndexPath.section == 0)
        return 106.0;
    else if (tableIndexPath.section == collectionIndexPath.item + 1)
        return 44.0;
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
//    self.bookcasesFetchedResultsController.fetchedObjects
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - === UICollectionView DataSource ===

    ///CollectionView will display the libraries, so #items = #libraries, which are the sections of the FetchRequest.
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.bookcasesFetchedResultsController.sections.count <= 0)
        DDLogError(@"There are no sections returned from the FRC!");
    return MAX(1, self.bookcasesFetchedResultsController.sections.count);
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
//    NSArray <id <NSFetchedResultsSectionInfo>> *librariesArray = self.bookcasesFetchedResultsController.sections;
//    UITextView *textView = [[UITextView alloc] initWithFrame:cell.frame];
//    [cell addSubview:textView];
//    textView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
//    textView.text = [NSString stringWithFormat:@"This cell represents Library \"%@\", at indexPath: %@", librariesArray[indexPath.item].name, indexPath];
}

#pragma mark - === UICollectionViewDelegate ===

/*
 // Uncomment this method to specify if the specified item should be highlighted during tracking
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
 }
 */

    ///Selects the current library.
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
     self.selectedLibraryIndexPath = indexPath;
         ///!!!:     dataManager.currentLibrary = {grab the library indicate}
     
 return YES;
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

#pragma mark - === UIScrollViewDelegate ===

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![scrollView isKindOfClass:[UICollectionView class]]) return;
    
    CGFloat horizontalOffset = scrollView.contentOffset.x;
    
    UICollectionView *collectionView = (UICollectionView*)scrollView;
    NSInteger index = collectionView.tag;
    self.contentOffsetDictionary[@(index).stringValue] = @(horizontalOffset);
}


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
}
@end
