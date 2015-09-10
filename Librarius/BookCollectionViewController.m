//
//  BookCollectionViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/25/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "BookCollectionViewController.h"
#import "BookDetailViewController.h"
#import "LBRDataManager.h"
#import "Library.h"
#import "Bookcase.h"
#import "Volume.h"

@interface BookCollectionViewController ()


@end

@implementation BookCollectionViewController

@dynamic name;
@dynamic indexTitle;
@dynamic numberOfObjects;
@dynamic objects;

- (void)awakeFromNib {
        [super awakeFromNib];
}

- (void)viewDidLoad {

        [super viewDidLoad];
        self.navigationItem.leftBarButtonItem = self.editButtonItem;        
/**
 *  TODO: Change the method called here to "Manual Volume Entry", details below.
 */
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
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

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//        [[segue destinationViewController] setDetailItem:object];
    }
}


#pragma mark - Table View data source

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
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *sections = self.fetchedResultsController.sections;
    id<NSFetchedResultsSectionInfo> currentSection = sections[section];
    return [currentSection name];
}

#pragma mark - Table View delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
            
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [object valueForKey:@"title"];
}


#pragma mark - Fetched Results Controller configuration

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    /**
     *  1) The set of all books (TODO: Uniquify the collection, so you cannot add multiple entries accidentally).
     *  2) in the current library
     *  3) arranged by mainCategory
     *  4) then author
     *  5) then year
     */
    LBRDataManager *dataManager = [LBRDataManager sharedDataManager];
    NSManagedObjectContext *managedObjectContext = dataManager.managedObjectContext;
    NSFetchRequest *volumesRequest = [NSFetchRequest fetchRequestWithEntityName:@"Volume"]; //(1)
    
    // Set the batch size to a suitable number.
    [volumesRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *categorySorter = [NSSortDescriptor sortDescriptorWithKey:@"mainCategory" ascending:YES];
    NSSortDescriptor *authorSorter = [NSSortDescriptor sortDescriptorWithKey:@"authorSurname" ascending:YES];
    
    [dataManager generateDefaultLibraryIfNeeded];
        //TODO: Might need @"library.name = datamanager.currentLibrary.name"
    NSPredicate *libraryPredicate = [NSPredicate predicateWithFormat:@"library = %@", dataManager.currentLibrary];
    
    volumesRequest.sortDescriptors = @[categorySorter, authorSorter];
    volumesRequest.predicate = libraryPredicate;
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:volumesRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"mainCategory" cacheName:nil];
    frc.delegate = self;
    self.fetchedResultsController = frc;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. !!!:You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    NSFetchedResultsController *testFRC = [dataManager preconfiguredLBRFetchedResultsController:self];
//    return _fetchedResultsController;
    return testFRC;
}

#pragma mark - Fetched Results Controller Delegate methods

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
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
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



@end
