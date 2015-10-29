//
//  BookCollectionViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/25/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//



    //Controllers
#import "BookCollection_TableViewController.h"
#import "BookDetailViewController.h"
#import "LBRDataManager.h"

    //Models
#import "Library.h"
#import "Bookcase.h"
#import "Volume.h"

    //UI
#import "UIColor+FlatUI.h"
#import "UIColor+ABBColors.h"
#import "UIFont+FlatUI.h"
#import "UITableViewCell+FlatUI.h"
#import "UIColor-Expanded.h"


@interface BookCollection_TableViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (strong, nonatomic) UISearchController *searchController;

    // Secondary search results TableView
@property (strong, nonatomic) LBR_ResultsTableViewController *resultsTableController;

    // For state restoration (???)
@property (nonatomic) BOOL searchControllerWasActive;
@property (nonatomic) BOOL searchControllerSearchFieldWasFirstResponder;


@end

@implementation BookCollection_TableViewController
{
    ADBannerView *bannerView;
//    UITableViewHeaderFooterView *headerView;
}

static NSString * const bannerHeaderIdentifier = @"bannerHeaderIdentifier";
static NSString * const searchResultsCellIdentifier = @"searchResultsCellIdentifier";

//-(BOOL)prefersStatusBarHidden {
//    return YES;
//}

#pragma mark - === View LifeCycle ===

- (void)viewDidLoad {

    [super viewDidLoad];
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    [self flattenUI];
    [self configureSearchControllers];
    self.canDisplayBannerAds = YES;
    
/**
 *  TODO: Change the method called here to "Manual Volume Entry", details below.
 */
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationController.navigationBar.translucent = NO;
    self.tableView.scrollsToTop = YES;
    NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView scrollToRowAtIndexPath:firstItemIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

/**
 *  TODO: Change this method to "Manual Volume Entry" and fill in all the fields to add a new Volume to the Library, and save.
 */
//- (void)insertNewObject:(id)sender {
//    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
//    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
//    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
//        
//    // If appropriate, configure the new managed object.
//    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
//    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
//        
//    // Save the context.
//    NSError *error = nil;
//    if (![context save:&error]) {
//        // Replace this implementation with code to handle the error appropriately.
//        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//}

-(void)flattenUI {
    
        //Set the background color
        ///"You must set this property (tableView.backgroundView) to nil to set the background color of the table view." (Apple docs)
    self.tableView.backgroundView = nil;
//    self.tableView.backgroundColor = [UIColor cloudsColor];
    [[UITableView appearance] setSeparatorColor :[UIColor midnightBlueColor]];
    [[UITableView appearance] setBackgroundColor:[UIColor cloudsColor]];
    [[UITableViewCell appearance] setBackgroundColor:[UIColor cloudsColor]];
    [UITableViewCell appearance].textLabel.textColor = [UIColor midnightBlueColor];

    [self.tableView setClipsToBounds:YES];
    self.fetchedResultsController = [[LBRDataManager sharedDataManager] preconfiguredLBRFetchedResultsController:self];
}

-(void)configureSearchControllers
{
    
    self.resultsTableController = [LBR_ResultsTableViewController new];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsTableController];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    // We want to be the delegate for our filtered table, so didSelectRowAtIndexPath is called for both tables
    self.resultsTableController.tableView.delegate = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO; //default is YES
    self.searchController.searchBar.delegate = self; //To monitor text changes + others
    
    
        // Search is now just presenting a view controller. As such, normal view controller
        // presentation semantics apply. Namely that presentation will walk up the view controller
        // hierarchy until it finds the root view controller or one that defines a presentation context.
        //
    self.definesPresentationContext = YES; // Know where you want UISearchController to be displayed.(?)
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
        //Restore the searchController's active state.
    if (self.searchControllerWasActive) {
        self.searchController.active = self.searchControllerWasActive;
        self.searchControllerWasActive = NO;
        
        if (self.searchControllerSearchFieldWasFirstResponder) {
            [self.searchController.searchBar becomeFirstResponder];
            self.searchControllerSearchFieldWasFirstResponder = NO;
        }
    }
    
}

#pragma mark - === UISearchBarDelegate ===

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}


/*
 #pragma mark - === UISearchControllerDelegate ===
 
 Called after the search controller's searchbar has agreed to begin editing, or
 when 'active' = YES. There is a default presentation to fall back on.
 We'll implement these methods if the default presentation is inadequate.
 
 -(void)presentSearchController:(UISearchController *)searchController
ALSO
 - (void)willPresentSearchController:(UISearchController *)searchController
 - (void)didPresentSearchController:(UISearchController *)searchController
 - (void)willDismissSearchController:(UISearchController *)searchController
 - (void)didDismissSearchController:(UISearchController *)searchController 
 */

#pragma mark - === UISearchResultsUpdating ===

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
        //Update the filtered array based on the search text
    NSString *searchText = searchController.searchBar.text;
    NSMutableArray *searchResults = [self.fetchedResultsController.fetchedObjects mutableCopy];
    
        // Strip out all the leading and trailing spaces
    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
        // Break up the search terms (seperated by spaces)
    NSArray *searchItems = nil;
    if (strippedString.length > 0) {
        searchItems = [strippedString componentsSeparatedByString:@" "];
    }
    
        // Build all the "AND" expressions for each value in the searchString
        //
    NSMutableArray *andMatchPredicates = [NSMutableArray array];
    
    for (NSString *searchString in searchItems) {
        // each searchString creates an OR predicate for: name, yearIntroduced, introPrice
        //
        // example if searchItems contains "iphone 599 2007":
        //      name CONTAINS[c] "iphone"
        //      name CONTAINS[c] "599", yearIntroduced ==[c] 599, introPrice ==[c] 599
        //      name CONTAINS[c] "2007", yearIntroduced ==[c] 2007, introPrice ==[c] 2007
        //
        NSMutableArray <NSPredicate*> *searchItemsPredicate = [NSMutableArray <NSPredicate*> array];

            //Apple used formal, long-form predicate forming. We used string-predicates.

        NSPredicate *finalPredicate;
        finalPredicate = [NSComparisonPredicate predicateWithFormat:@"title CONTAINS[cd] %@", searchString];
        [searchItemsPredicate addObject:finalPredicate];
        
        finalPredicate = [NSComparisonPredicate predicateWithFormat:@"title CONTAINS[cd] %@",searchString];
        [searchItemsPredicate addObject:finalPredicate];
        
        finalPredicate = [NSComparisonPredicate predicateWithFormat:@"author CONTAINS[cd] %@", searchString];
        [searchItemsPredicate addObject:finalPredicate];
        
            //yearPublished field matching
        NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
        numberFormatter.numberStyle = NSNumberFormatterNoStyle;
        NSNumber *targetNumber = [numberFormatter numberFromString:searchString];
        if (targetNumber != nil) { // searchString may not convert to a number.
            finalPredicate = [NSComparisonPredicate predicateWithFormat:@"published CONTAINS[cd] %@", targetNumber];
            [searchItemsPredicate addObject:finalPredicate];
        }
            // Add this OR predicate to our master AND predicate
        NSCompoundPredicate *orMatchPredicates = [NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
        [andMatchPredicates addObject:orMatchPredicates];
    }
    
        // Match up the fields of the Book object
    NSCompoundPredicate *finalCompoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
    searchResults = [[searchResults filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
    
        // Hand over the filtered results to our search results table.
    LBR_ResultsTableViewController *tableController = (LBR_ResultsTableViewController *)self.searchController.searchResultsController;
    tableController.filteredBooks = searchResults;
    [tableController.tableView reloadData];
}

#pragma mark - === UIStateRestoration ===

    //We restore several items for state restoration:
    // 1) Search controller's active state,
    // 2) search text,
    // 3) first responder.

NSString * const ViewControllerTitleKey = @"ViewControllerTitleKey";
NSString * const SearchControllerIsActivKey = @"SearchControllerIsActivKey";
NSString * const SearchBarTextKey = @"SearchBarTextKey";
NSString * const SearchBarIsFirstResponderKey = @"SearchBarIsFirstResponderKey";

-(void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
        // Encode the view state so that it can be restored later.
    
        // Encode the title
    [coder encodeObject:self.title forKey:ViewControllerTitleKey];
    
    UISearchController *searchController = self.searchController;
    
        // Encode the search controller's active state.
    BOOL searchDisplayControllerIsActive = searchController.isActive;
    [coder encodeBool:searchDisplayControllerIsActive forKey:SearchControllerIsActivKey];
    
        // Encode the first responder status.
    if (searchDisplayControllerIsActive) {
        [coder encodeBool:[searchController.searchBar isFirstResponder] forKey:SearchBarIsFirstResponderKey];
    }
    
        // Encode the search bar text.
    [coder encodeObject:searchController.searchBar.text forKey:SearchBarTextKey];
}

-(void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
        // Restore the title.
        // Apple: We cannot make the searchController active here, since it's
        //  not part of the view heirarchy yet, instead we'll do it in viewWill Appear.
    self.searchControllerWasActive = [coder decodeBoolForKey:SearchControllerIsActivKey];
    
        // Restore the active state. Again, searchController will become firstresponder
        // in viewWillAppear.
    self.searchControllerSearchFieldWasFirstResponder = [coder decodeBoolForKey:SearchBarTextKey];
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    BookDetailViewController *destinationVC = segue.destinationViewController;
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    destinationVC.displayVolume = [[self fetchedResultsController] objectAtIndexPath:indexPath];
}


#pragma mark - === Table View data source ===

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sections = [self.fetchedResultsController sections];
    id <NSFetchedResultsSectionInfo> currentSection = sections[section];
    return currentSection.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
//    if (tableView == self.tableView) {
        [self configureCell:cell atIndexPath:indexPath];
//    }
//    if (tableView == self.resultsTableController.tableView) {
//        
//    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *sections = self.fetchedResultsController.sections;
    id<NSFetchedResultsSectionInfo> currentSection = sections[section];
    return [currentSection name];
}

#pragma mark - === Table View delegate ===

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.tableView) {
        Volume *selectedVolume = self.resultsTableController.filteredBooks[indexPath.row];
        BookDetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"bookDetailStoryboardID"];
        detailViewController.displayVolume = selectedVolume;
        
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    
        //???
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            [tableView reloadData];

            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        [tableView reloadData];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView   = (UITableViewHeaderFooterView *)view;
    headerView.backgroundView.backgroundColor = [UIColor shirazColor];
    headerView.textLabel.backgroundColor      = [UIColor clearColor];
    headerView.textLabel.textColor            = [UIColor whiteColor];
}



#pragma mark private delegate helpers

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
        //Grabbing the text and context.
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *title         = [object valueForKey:@"title"];
    NSString *subtitle      = [object valueForKey:@"subtitle"];
    [self makeTitleCase:title];
    [self makeTitleCase:subtitle];
    
    cell.textLabel.text = title;
    if (subtitle) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", title, subtitle];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-Book" size:20];
    cell.textLabel.textColor = [UIColor midnightBlueColor];

    
        // Rounding the upper and lower corners of the cells in each group.
    NSUInteger lastRowInSection = [self tableView:self.tableView numberOfRowsInSection:indexPath.section] - 1;
    UIRectCorner cornersToRound = -1;
    
    if (indexPath.row == lastRowInSection) {
        cornersToRound = UIRectCornerBottomLeft | UIRectCornerBottomRight;
    }
    if (indexPath.row == 0) {
        cornersToRound = UIRectCornerTopLeft | UIRectCornerTopRight;
    }
    if (lastRowInSection == 0) {
        cornersToRound = UIRectCornerAllCorners;
    }
    
    [cell configureFlatCellWithColor:[UIColor crayonOrangeColor] selectedColor:[UIColor pumpkinColor] roundingCorners:cornersToRound];
    

    if (indexPath.row == 0 || indexPath.row == lastRowInSection) {
        [cell setCornerRadius:10];
    }
    else{
        [cell setCornerRadius:0];
    }
}

-(void)configureCell:(UITableViewCell *)cell forVolume:(Volume *)volume
{
    
}

- (void)makeTitleCase:(NSString*)string {
    NSArray *words = [string componentsSeparatedByString:@" "];
    for (NSString __strong *word in words) {
        if ([@[@"the", @"and", @"a", @"of"] containsObject:word]) {
                // Don't capitalize = do nothing.
        } else {
            word = word.capitalizedString;
        }
    }
    string = [words componentsJoinedByString:@" "];
}

#pragma mark - Fetched Results Controller configuration

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    return [[LBRDataManager sharedDataManager]
            preconfiguredLBRFetchedResultsController:self];
}

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
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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

//#pragma mark - Helper methods


#pragma mark - === UISrollViewDelegate ===

-(BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    return NO;
}

@end
