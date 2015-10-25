//
//  LBR_BookcaseCollectionViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 10/16/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#define kNumberOfShelvesInBookcase 5


    //Controllers
#import "LBR_BookcaseCollectionViewController.h"
#import "LBRDataManager.h"
#import "LBR_BookcaseLayout.h"


    //Views
//#import "LBR_ShelvedBookCell.h"
#import "LBRShelvedBook_CollectionViewCell.h"

    //Models
#import "Volume.h"
#import "LBR_BookcaseModel.h"

    //Categories
#import "UIColor+FlatUI.h"
#import <UIImageView+AFNetworking.h>


@interface LBR_BookcaseCollectionViewController ()

//@property (nonatomic, strong) LBR_BookcaseLayout *layout;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableArray *sectionChanges;
@property (nonatomic, strong) NSMutableArray *itemChanges;
@property (nonatomic, strong) LBRDataManager *dataManager;


@end

@implementation LBR_BookcaseCollectionViewController

static NSString * const reuseIdentifier = @"bookCellID";
static NSString * const customSectionHeaderID = @"customSectionHeaderID";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Bookshelves";
        //Rope in the singleton dataManger
    self.dataManager = [LBRDataManager sharedDataManager];

    self.canDisplayBannerAds = YES;
    
        //Set custom layout with protocol
    LBR_BookcaseLayout *layout               = [LBR_BookcaseLayout new];
    self.collectionView.collectionViewLayout = layout;
    
    self.collectionView.backgroundColor = [UIColor cloudsColor];
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes? No, prototyped in storyboard.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - === UICollectionViewDataSource ===

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.fetchedResultsController.sections.count;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *sections = [self.fetchedResultsController sections];
    id <NSFetchedResultsSectionInfo> currentSection = sections[section];
    return currentSection.numberOfObjects;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LBRShelvedBook_CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
        //configure the cell
    cell.backgroundColor = [UIColor asbestosColor];
    
    NSArray <Volume*> *volumesArray = self.fetchedResultsController.fetchedObjects;
    Volume *volume = volumesArray[indexPath.row];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", volume.cover_art_large]];
    [cell.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cell.thickness = [volume.thickness floatValue];

    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

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

#pragma mark - Fetched Results Controller configuration

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil)
        return _fetchedResultsController;
    
    return [self.dataManager preconfiguredLBRFetchedResultsController:self];
}

#pragma mark - === FetchedResultsControllerDelegate ===

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
        // Instead of UITableView's '-beginUpdates' method.
    _sectionChanges = [NSMutableArray new];
    _itemChanges = [NSMutableArray new];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    NSMutableDictionary *change = [NSMutableDictionary new];
    change[@(type)] = @(sectionIndex);
    [_sectionChanges addObject:change];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch (type) {
                //???: Update and Delete are the same...?
        case NSFetchedResultsChangeInsert: {
            change[@(type)] = newIndexPath;
            break;
        }
        case NSFetchedResultsChangeDelete: {
            change[@(type)] = indexPath;
            break;
        }
        case NSFetchedResultsChangeMove: {
            change[@(type)] = @[indexPath, newIndexPath];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            change[@(type)] = indexPath;
            break;
        }
        default: {
            break;
        }
    }
    [_itemChanges addObject:change];
}

    // This code is borrowed from Jose Ibanez (http://tmblr.co/ZrbCtvZsT5Ec), and thx to Junda Ong (@samwize) for pointing to it.
/**
 *  In Jose's words: "The high level idea is there are two mutable arrays, _sectionChanges and _itemChanges. As individual changes come in, each one is converted into a dictionary with an NSNumber representation of the change type as the key and the index path to change as the value. That allows you to simply loop through your arrays in `-controllerDidChangeContent:` and make all the updates at once."
 */
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
        // Instead of UITableView's nice -endUpdates, we do some magic.
    [self.collectionView performBatchUpdates:^{
        for (NSDictionary *change in _sectionChanges) {
            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                switch (type) {
                    case NSFetchedResultsChangeInsert: {
                        [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                        break;
                    }
                    case NSFetchedResultsChangeDelete: {
                        [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                        break;
                    }
                }
            }];
        }
        
        for (NSDictionary *change in _itemChanges) {
            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                switch (type) {
                    case NSFetchedResultsChangeInsert: {
                        [self.collectionView insertItemsAtIndexPaths:@[obj]];
                        break;
                    }
                    case NSFetchedResultsChangeDelete: {
                        [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                        break;
                    }
                    case NSFetchedResultsChangeMove: {
                        [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                        break;
                    }
                    case NSFetchedResultsChangeUpdate: {
                        [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                        break;
                    }
                    default: {
                        break;
                    }
                }
            }];
        }
        /**
         *  In Jose's words: "Setting the arrays to nil in the completion block as opposed to simply removing all objects might be safer if new updates are ever sent before the change block is executed."
         */
    } completion:^(BOOL finished) {
        _sectionChanges = nil;
        _itemChanges = nil;
    }];
}

@end
