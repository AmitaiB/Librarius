//
//  LBRShelvesFlowCollectionViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 9/9/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBRShelves_CollectionViewController.h"
#import "LBRDataManager.h"
#import <UIImageView+AFNetworking.h>
#import "Volume.h"
#import "LBRShelvedBook_CollectionViewCell.h"
#import "UIColor+FlatUI.h"

#define kDefaultCellSize CGSizeMake(106.0, 106.0)

@interface LBRShelves_CollectionViewController ()

@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) LBRDataManager *dataManager;
@property (nonatomic, strong) NSMutableArray *sectionChanges;
@property (nonatomic, strong) NSMutableArray *itemChanges;

@end

@implementation LBRShelves_CollectionViewController {
        //Reusable imageView
    UIImageView *reusableImageView;
}

static NSString * const reuseIdentifier = @"bookCellID";

@dynamic name;
@dynamic indexTitle;
@dynamic numberOfObjects;
@dynamic objects;



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureBooksFlowLayout:self.layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    self.title = @"Bookshelves";
    
    // Register cell classes
    [self.collectionView registerClass:[LBRShelvedBookCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    self.dataManager = [LBRDataManager sharedDataManager];
    
    reusableImageView = [[UIImageView alloc] init];
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
#pragma mark - UICollectionView FlowLayout configuration

- (void)configureBooksFlowLayout:(UICollectionViewFlowLayout*)layout {
    layout.scrollDirection         = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing      = 1.0;
    layout.minimumInteritemSpacing = 1.0;
    layout.estimatedItemSize       = CGSizeMake(106.0, 106.0);
//    layout.itemSize = CGSizeMake(106.0, 106.0);
}

#pragma mark - === UICollectionViewDataSource ===
/*
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
#warning Incomplete method implementation -- Return the number of sections
        //1 shelf, for now.
    return 0;
}
*/

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    NSArray *sections = [self.fetchedResultsController sections];
//    id <NSFetchedResultsSectionInfo> currentSection = sections[section];
//    return currentSection.numberOfObjects;
    return [self.fetchedResultsController.fetchedObjects count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LBRShelvedBook_CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
        //configure the cell
    cell.backgroundColor = [UIColor asbestosColor];
    
    NSArray *volumesArray = self.fetchedResultsController.fetchedObjects;
    Volume *volume = (Volume*)volumesArray[indexPath.row];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", volume.cover_art_large]];
    [cell.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cell.thickness = [volume.thickness floatValue];
    
    return cell;
}

#pragma mark
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

#pragma mark - FlowLayout Delegate methods

    //???: Why doesn't this work?
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
        //Provides a different size for each individual cell
    
        //Grab the image for/from the cell
    LBRShelvedBook_CollectionViewCell *cell = (LBRShelvedBook_CollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
        //Determine the size and aspect ratio for the cell's image, given
        //that the height is 106.0
    CGSize imageSize = cell.imageView.image.size;
    CGSize itemSize = kDefaultCellSize;
    if (imageSize.height) {
        CGFloat aspectRatio = kDefaultCellSize.height / imageSize.height;
        itemSize = CGSizeMake(imageSize.width * aspectRatio, kDefaultCellSize.height);
    }
    return itemSize;
}


#pragma mark - Helper methods
    //Handy dandy - returns the book at any index path
    //thx to Ash Furrow.
-(void)configureCell:(LBRShelvedBook_CollectionViewCell*)cell forIndexPath:(NSIndexPath*)indexPath {
        //configure the cell
//    cell.backgroundColor = [UIColor clearColor];
//    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wood_floor"]];
    
    NSArray *volumesArray = self.fetchedResultsController.fetchedObjects;
    Volume *volume = (Volume*)volumesArray[indexPath.row];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", volume.cover_art_large]];
    [cell.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cell.thickness = [volume.thickness floatValue];
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

#pragma mark - Fetched Results Controller Delegate methods

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
