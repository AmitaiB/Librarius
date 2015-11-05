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

    //Views
#import "ABB_BufferToolbar.h"

    //UI
#import "UIColor+FlatUI.h"
#import "UIColor+ABBColors.h"
#import "UIFont+FlatUI.h"
#import "UITableViewCell+FlatUI.h"
#import "UIColor-Expanded.h"
#import "UIView+ConfigureForAutoLayout.h"


@interface BookCollection_TableViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, setter=setPreferIndexHidden:) BOOL preferIndexHidden;

@property (strong, nonatomic) UISearchController *searchController;
//@property (nonatomic, strong) UIToolbar *bufferToolbar;

    //Cosmetic view that prevents text collisions with statusBar.
@property (nonatomic, strong) ABB_BufferToolbar *bufferToolbar;

    // search results TableView
@property (strong, nonatomic) LBR_ResultsTableViewController *resultsTableViewController;

    // For state restoration (???)
@property (nonatomic) BOOL searchControllerWasActive;
@property (nonatomic) BOOL searchControllerSearchFieldWasFirstResponder;


//    //Alternative SearchBar implementation
//@property (nonatomic, strong) UITableView *altSearchResultsTableView;

@end

@implementation BookCollection_TableViewController
{
    ADBannerView *bannerView;
//    UITableViewHeaderFooterView *headerView;
}

static NSString * const bannerHeaderID         = @"bannerHeaderIdentifier";
static NSString * const searchResultsCellID    = @"searchResultsCellIdentifier";
static NSString * const altSearchResultsCellID = @"altSearchResultsCellID";


#pragma mark - === LifeCycle ===

- (void)viewDidLoad {

    [super viewDidLoad];
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    [self flattenUI];

        //Uncomment when ready to add and debug searchBar
//    [self configureSearchControllers];
    self.canDisplayBannerAds = YES;
    self.preferIndexHidden = YES;
/**
 *  TODO: Change the method called here to "Manual Volume Entry", details below.
 */
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationController.navigationBar.translucent = NO;
    self.tableView.scrollsToTop = YES;
    self.bufferToolbar = [[ABB_BufferToolbar alloc] initWithController:self];


    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    self.tableView.contentInset = UIEdgeInsetsMake(statusBarHeight, 0, 0, 0);
    [self scrollToFirstCellOnLoad];
    [self configureColorScheme];
}

-(void)scrollToFirstCellOnLoad
{
    BOOL section0hasAtLeastOneRow = [self.tableView numberOfRowsInSection:0];
    NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForRow: 0 inSection:0];
    
        //Scroll to the first section
    if ([self.tableView numberOfSections] > 0) {
        if (section0hasAtLeastOneRow) {
            [self.tableView scrollToRowAtIndexPath:firstItemIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        else
        {  ///Apple Docs: "NSNotFound is a valid row index for scrolling to a section with zero rows."
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:NSNotFound inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    }
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

-(void)configureColorScheme
{
        //Set the background color
        ///"You must set this property (tableView.backgroundView) to nil to set the background color of the table view." (Apple docs)
    [UITableView appearance].backgroundView = nil;
//    [UITableView appearance].backgroundColor = [UIColor wellReadColor];
    [[UITableView appearance] setSeparatorColor :[UIColor wellReadColor]];
    [[UITableView appearance] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLineEtched];
    
    [[UITableView appearance] setBackgroundColor:[UIColor casalColor]];
    
    [[UITableViewCell appearance] setBackgroundColor:[UIColor cloudsColor]];
    [UITableViewCell appearance].textLabel.textColor = [UIColor midnightBlueColor];
    [UITableViewCell appearance].textLabel.font = [UIFont fontWithName:@"Avenir-Book" size:20];

        //        Crashes:
        //    [[UITableViewCell appearance] setSeparatorHeight:5];
}

-(void)flattenUI {
    
//    [UICollectionViewCell appearance].backgroundColor = [UIColor clearColor];
    
    [self.tableView setClipsToBounds:YES];
    self.fetchedResultsController = [[LBRDataManager sharedDataManager] preconfiguredLBRFetchedResultsController:self];
}

-(void)viewWillLayoutSubviews
{
    self.resultsTableViewController = [LBR_ResultsTableViewController new];
    [super viewWillLayoutSubviews];
}

-(void)configureSearchControllers
{
    self.searchController                      = [[UISearchController alloc] initWithSearchResultsController:self.resultsTableViewController];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];

    self.tableView.tableHeaderView             = self.searchController.searchBar;

    // We want to be the delegate for our filtered table, so didSelectRowAtIndexPath is called for both tables
    self.resultsTableViewController.tableView.delegate     = self;
    self.searchController.delegate                         = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;//default is YES
    self.searchController.searchBar.delegate               = self;//To monitor text changes + others


        // Search is now just presenting a view controller. As such, normal view controller
        // presentation semantics apply. Namely that presentation will walk up the view controller
        // hierarchy until it finds the root view controller or one that defines a presentation context.
        //
    self.definesPresentationContext                        = YES;// Know where you want UISearchController to be displayed.(?)
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

#pragma mark - == Section Index methods ==

-(void)setPreferIndexHidden:(BOOL)preferIndexHidden
{
    _preferIndexHidden = preferIndexHidden;
    [self.tableView reloadSectionIndexTitles];
}

#pragma mark - === UISearchBarDelegate ===

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
//    self.resultsTableViewController.filteredBooks = @[];
    [searchBar resignFirstResponder];
}

/*
 #pragma mark - === UISearchControllerDelegate ===
 
 Called after the search controller's searchbar has agreed to begin editing, or
 when 'active' = YES. There is a default presentation to fall back on.
 We'll implement these methods if the default presentation is inadequate.
 -(void)presentSearchController:(UISearchController *)searchController
 */

/*
ALSO
 - (void)willPresentSearchController:(UISearchController *)searchController
 - (void)didPresentSearchController:(UISearchController *)searchController
 - (void)willDismissSearchController:(UISearchController *)searchController
 - (void)didDismissSearchController:(UISearchController *)searchController 
 */

#pragma mark - === UISearchResultsUpdating ===

/**
 0) The SB has been presented (it's a 0-row array).
 1) Search the dataset for the search text, update the results array, redraw.
 */
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
        //Update the filtered array based on the search text
    NSString *searchText = [searchController.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; // Trimmed
    
        // Break up the search terms (seperated by spaces)
    NSArray *searchItems = (searchText.length > 0) ? [searchText componentsSeparatedByString:@" "] : nil;
    
    NSMutableArray *mutableSearchResults = [self.fetchedResultsController.fetchedObjects mutableCopy];
    
    
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
        [searchItemsPredicate addObject:[finalPredicate copy]];

//       Accidental repeat, or necessary?
//        finalPredicate = [NSComparisonPredicate predicateWithFormat:@"title CONTAINS[cd] %@",searchString];
//        [searchItemsPredicate addObject:[finalPredicate copy]];
        
        finalPredicate = [NSComparisonPredicate predicateWithFormat:@"author CONTAINS[cd] %@", searchString];
        [searchItemsPredicate addObject:[finalPredicate copy]];
        
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
    mutableSearchResults = [[mutableSearchResults filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
    
        // Hand over the filtered results to our search results table.
    LBR_ResultsTableViewController *tableController = (LBR_ResultsTableViewController *)self.searchController.searchResultsController;
    tableController.filteredBooks = mutableSearchResults;
    [tableController.tableView reloadData];
}

#pragma mark - === UIStateRestoration ===

    //We restore several items for state restoration:
    // 1) Search controller's active state,
    // 2) search text,
    // 3) first responder.

NSString * const ViewControllerTitleKey       = @"ViewControllerTitleKey";
NSString * const SearchControllerIsActivKey   = @"SearchControllerIsActivKey";
NSString * const SearchBarTextKey             = @"SearchBarTextKey";
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

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue
{
    
}

#pragma mark - === TableView DataSource ===

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numSections = -1; //Crash if
    if (tableView == self.tableView) {
        numSections = [[self.fetchedResultsController sections] count];
    }
    if (tableView == self.resultsTableViewController.tableView) {
//        NSLog(@"Results TableView");
        numSections = 1;
    }
    
    return numSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sections = [self.fetchedResultsController sections];
    if (sections.count) {
        id <NSFetchedResultsSectionInfo> currentSection = sections[section];
        return currentSection.numberOfObjects;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *sections = self.fetchedResultsController.sections;
    id<NSFetchedResultsSectionInfo> currentSection = (sections.count)? sections[section] : nil;
    return (currentSection)? [currentSection name] : @"Empty Library. Me Sad.";
}


-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (self.preferIndexHidden)
        return nil;
    
    
    __block NSMutableArray <NSString *> *indexTitles = [NSMutableArray array];
    [self.fetchedResultsController.sections enumerateObjectsUsingBlock:^(id<NSFetchedResultsSectionInfo>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *abbreviatedGenreTitle = [obj.name stringByReplacingCharactersInRange:NSMakeRange(5, obj.name.length - 5) withString:@".."];
        [indexTitles addObject:abbreviatedGenreTitle];
    }];

    return [indexTitles copy];
}

#pragma mark - === TableView Delegate ===

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.tableView) {
        Volume *selectedVolume = self.resultsTableViewController.filteredBooks[indexPath.row];
        BookDetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"bookDetailStoryboardID"];
        detailViewController.displayVolume = selectedVolume;
        [self presentViewController:detailViewController animated:YES completion:nil];
    }
    
        //???
//    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
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
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        [tableView reloadData];
    }
}


-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView   = (UITableViewHeaderFooterView *)view;
    headerView.backgroundView.backgroundColor = [UIColor cloudsColor];
    headerView.textLabel.backgroundColor      = [UIColor clearColor];
    headerView.textLabel.textColor            = [UIColor wellReadColor];
    headerView.textLabel.font                 = [UIFont fontWithName:@"Avenir-HeavyOblique" size:16];
}


#pragma mark private delegate helpers

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
        //Grabbing the text and context.
    BOOL arrayIsEmptyOrNil = !@(self.fetchedResultsController.fetchedObjects.count).boolValue;
    NSManagedObject *object = (arrayIsEmptyOrNil)? nil : [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *title         = [object valueForKey:@"title"];
    NSString *subtitle      = [object valueForKey:@"subtitle"];
    [self makeTitleCase:title];
    [self makeTitleCase:subtitle];
    NSString *formattedSubtitle = [@": " stringByAppendingString:subtitle ? subtitle : @""];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@%@", title, subtitle ?  formattedSubtitle : @""];
    
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

    /*
     casalColor; //Dark Green
     wellReadColor; //Red
     tulipTreeColor; //Yellow
     charcoalColor; //Grey
     */

    
        ///AHA!
    [cell configureFlatCellWithColor:[UIColor casalColor] selectedColor:[UIColor tulipTreeColor] roundingCorners:cornersToRound];
//    [cell configureFlatCellWithColor:[UIColor shirazColor] selectedColor:[UIColor mySinColor] roundingCorners:cornersToRound];
    

    if (indexPath.row == 0 || indexPath.row == lastRowInSection) {
        [cell setCornerRadius:10];
    }
    else{
        [cell setCornerRadius:0];
    }
}

    //CLEAN:
//-(void)configureCell:(UITableViewCell *)cell forVolume:(Volume *)volume
//{
//    
//}

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
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] forIndexPath:indexPath];
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

    //Might not be good enough.
-(BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];

    return NO;
}




@end
