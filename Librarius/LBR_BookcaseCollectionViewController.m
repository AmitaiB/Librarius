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
#import "LBR_EmptyFlowLayout.h"


    //Views
//#import "LBR_ShelvedBookCell.h"
#import "LBRShelvedBook_CollectionViewCell.h"
#import "LBRShelf_DecorationView.h"

    //Models
#import "Volume.h"
#import "LBR_BookcaseModel.h"

    //Categories
#import "UIColor+FlatUI.h"
//#import <UIImageView+AFNetworking.h>
#import "UIImageView+ProgressView.h"
#import "CoverArt.h"


@interface LBR_BookcaseCollectionViewController ()

//@property (nonatomic, strong) LBR_BookcaseLayout *layout;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableArray *sectionChanges;
@property (nonatomic, strong) NSMutableArray *itemChanges;
@property (nonatomic, strong) LBRDataManager *dataManager;
@property (nonatomic, strong) UIProgressView *progressView;


    //Debug
@property (nonatomic, strong) NSMutableDictionary *debugDictionary;
@property (nonatomic, strong) NSMutableDictionary *debugDictionary2;
@property (nonatomic, strong) NSMutableArray <Volume*> *debugVolumeList;
@property (nonatomic, strong) NSMutableSet *debugCellSet;


@end

@implementation LBR_BookcaseCollectionViewController
{
    UISegmentedControl *layoutChangesSegmentedControl;
    
    UICollectionViewFlowLayout *standardFlowLayout;
    LBR_BookcaseLayout *layout;
    NSArray <Volume*> *volumesArray;
    
        ///THIS MIGHT WORK with a Dictionary instead of an array:
    NSDictionary <NSIndexPath*,  NSData*> *precachedImageData;
}

static NSString * const reuseIdentifier          = @"bookCellID";
static NSString * const customSectionHeaderID    = @"customSectionHeaderID";
static NSString * const decorationViewIdentifier = @"decorationViewIdentifier";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutChangeSetup];
    
    self.title = @"Bookshelves";
        //Rope in the singleton dataManger
    self.dataManager = [LBRDataManager sharedDataManager];

    self.canDisplayBannerAds = YES;
    
        //Set custom layout with protocol
    layout = [LBR_BookcaseLayout new];
    [self.collectionView setCollectionViewLayout:layout];
    
    self.collectionView.backgroundColor = [UIColor cloudsColor];
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Cell classes prototyped in storyboard.

    volumesArray = self.fetchedResultsController.fetchedObjects;
        ///    [self precacheImages];
}

-(void)setupProgressView
{
    UIProgressView *progressView;
    progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progressView.progressTintColor = [UIColor colorWithRed:187.0/255 green:160.0/255 blue:209.0/255 alpha:1.0];
    [[progressView layer]setCornerRadius:10.0f];
    [[progressView layer]setBorderWidth:2.0f];
    [[progressView layer]setMasksToBounds:TRUE];
    progressView.clipsToBounds = YES;
    progressView.layer.frame = CGRectMake(30, 295, 260, 25);
    progressView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor whiteColor]);
    progressView.trackTintColor = [UIColor clearColor];
//    [progressView setProgress: (float)count/15 animated:YES];
    self.progressView = progressView;
}


    //Debug override
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self cellTest];
}

    ///May not be needed, now that the images are in CoreData.
//-(void)precacheImages
//{
//    NSMutableArray *tempImageViewArray = [NSMutableArray array];
//    for (Volume *volume in volumesArray) {
//        UIImageView *imageView = [[UIImageView alloc] init];
//        NSURL *url = [NSURL URLWithString:volume.cover_art_large];
//        
//            //!!!: Why not working?
//        [imageView sd_setImageWithURL:url usingProgressView:self.progressView];
//        
////        [imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder"]];
//        [tempImageViewArray addObject:imageView];
//    }
//    coverArtArray = [tempImageViewArray copy];
//}


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
    
//    Volume *volumeModel = volumesArray[indexPath.item];
    
CoverArt *coverArtModel = 
    
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", volume.cover_art_large]];
//    [cell.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cell.coverArtURLString = volume.cover_art_large;
    
    
    cell.thickness = [volume.thickness floatValue];
//    UIImage *coverArtImage = ((UIImageView*)coverArtArray[indexPath.item]).image;
//    [cell.imageView setImage:coverArtImage];

        //Debug
    NSData *imageData = UIImagePNGRepresentation(cell.imageView.image);
    [self.debugDictionary setObject:imageData forKey:cell.coverArtURLString];
    [self.debugCellSet addObject:cell];
    
    [self.debugVolumeList addObject:volume];
    
    [self.debugDictionary2 setObject:volume forKey:indexPath];
    return cell;
}

    //Debug
-(void)cellTest
{
    NSArray *visibleCells = [self.collectionView visibleCells];
    NSUInteger counter = 0;
    NSData *debugImageData;
    NSData *visibleCellImageData;
        //For each cell, check the cell's actual image against its URL.
    for (LBRShelvedBook_CollectionViewCell *cell in visibleCells) {
        visibleCellImageData = UIImagePNGRepresentation(cell.imageView.image);
        debugImageData = self.debugDictionary[cell.coverArtURLString];
        counter += @([visibleCellImageData isEqual:debugImageData]).integerValue;
    }
    
    
    NSLog(@"Test #1: There are %@ visible cells, and %@ of them have the correct image. [%d]", @(visibleCells.count), @(counter), visibleCells.count == counter);
    
    NSArray *visibleURLs = [self.debugDictionary allKeys];
    NSArray *uniquifiedVisibleURLs = [[NSSet setWithArray:visibleURLs] allObjects];
    
    NSLog(@"Test #2: There are %@ visible cells, and %@ unique visible cells (by URL). [%d]", @(visibleURLs.count), @(uniquifiedVisibleURLs.count), visibleURLs.count == uniquifiedVisibleURLs.count);
    
    [self.debugDictionary2 description];
    [self.debugDictionary2 enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *key, Volume *obj, BOOL * _Nonnull stop) {
        NSLog(@"Key: %@ ||| Object: %@", key, obj.title);
    }];
}

#pragma mark Debug-related Lifecycle

    //Debug
-(NSMutableDictionary *)debugDictionary
{
    if (_debugDictionary == nil)
        _debugDictionary= [NSMutableDictionary dictionary];
    
    return _debugDictionary;
}

    //Debug
-(NSMutableDictionary *)debugDictionary2
{
    if (_debugDictionary2 == nil)
        _debugDictionary2= [NSMutableDictionary dictionary];
    
    return _debugDictionary2;
}


    //Debug
-(NSMutableArray <Volume*> *)debugVolumeList
{
    if (_debugVolumeList == nil) {
        _debugVolumeList = [NSMutableArray array];
    }
    return _debugVolumeList;
}

    //Debug
-(NSMutableSet *)debugCellSet
{
    if (_debugCellSet == nil) {
        _debugCellSet = [NSMutableSet set];
    }
    
    return _debugCellSet;
}

//#pragma mark - === UICollectionViewDelegate ===

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

#pragma mark - ++Layout change methods (Delete before Shipping?)

-(void)layoutChangeSetup
{
    standardFlowLayout = [UICollectionViewFlowLayout new];
    
    standardFlowLayout.itemSize                = CGSizeMake(106.0, 106.0);
    standardFlowLayout.sectionInset            = UIEdgeInsetsMake(1, 1, 1, 1);
    standardFlowLayout.minimumInteritemSpacing = 1.0;
    standardFlowLayout.minimumLineSpacing      = 1.0;
    standardFlowLayout.scrollDirection         = UICollectionViewScrollDirectionHorizontal;
    
    
    layoutChangesSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Bookcase Layout", @"Flow Layout"]];
    layoutChangesSegmentedControl.selectedSegmentIndex = 0;
    [layoutChangesSegmentedControl addTarget:self action:@selector(layoutChangesSegmentedControlDidChangeValue:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = layoutChangesSegmentedControl;
}

-(void)layoutChangesSegmentedControlDidChangeValue:(id)sender
{
    NSString *classString = NSStringFromClass([self.collectionViewLayout class]);
    NSString *bkClassString = NSStringFromClass([LBR_BookcaseLayout class]);
    NSString *flClassString = NSStringFromClass([LBR_EmptyFlowLayout class]);
    
    if ([classString isEqualToString:bkClassString]) {
        [self.collectionView setCollectionViewLayout:standardFlowLayout animated:YES];
    }
    if ([classString isEqualToString:flClassString]) {
        [self.collectionView setCollectionViewLayout:layout animated:YES];
    }
}


#pragma mark - === ScrollView Delegate ===

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//
//}

@end
