//
//  LBRRecommendationsCollectionViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 9/24/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

    //Controller
#import "LBRRecommendationsCollectionViewController.h"

    //Views
#import "LBRShelvedBook_CollectionViewCell.h"
#import "LBRRecommendedBook_CollectionViewCell.h"
#import "LBRRecommendations_CollectionViewHeader.h"

    //Models
#import "Library.h"
#import "Bookcase.h"
#import "Volume.h"
#import "LBRParsedVolume.h"

    //Data
#import "LBRDataManager.h"
#import <UIImageView+AFNetworking.h>
#import "LBRGoogleGTLClient.h"

    //UI
#import "UIColor+FlatUI.h"

@interface LBRRecommendationsCollectionViewController ()

@property (nonatomic, strong) IBOutlet UICollectionViewFlowLayout *layout;

@property (nonatomic, strong) LBRDataManager *dataManger;
@property (nonatomic, strong) NSMutableArray *sectionChanges;
@property (nonatomic, strong) NSMutableArray *itemChanges;

@property (nonatomic, strong) NSArray <NSString*> *coverArtURLs;

@end

@implementation LBRRecommendationsCollectionViewController {
    LBRGoogleGTLClient *googleClient;
}


static NSString * const reuseIdentifier = @"RecommendationCellID";
static NSString * const headerReuseIdentifier = @"HeaderReuseID";

-(instancetype)init {
    if (!(self = [super init])) return nil;

    _layout.estimatedItemSize = CGSizeMake(106.0, 106.0);
    _layout.headerReferenceSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height * 0.1);

    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.collectionView.backgroundColor = [UIColor cloudsColor];
    self.coverArtURLs = [NSArray array];
    
    self.title = @"Recommended Books";
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register view classes
    [self.collectionView registerClass:[LBRRecommendedBook_CollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerClass:[LBRRecommendations_CollectionViewHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerReuseIdentifier];
    
    // Do any additional setup after loading the view.
    googleClient = [LBRGoogleGTLClient sharedGoogleGTLClient];
    
    
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
    //A recommendation for each genre: good.
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.fetchedResultsController.sections.count;
}

    //Recommend at least 3 books.
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *sections = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> currentSection = sections[section];
    NSUInteger numObjects = [currentSection numberOfObjects];
    return MAX(3, numObjects - (numObjects %3));
}

/**
 For each section, get 3 volumes. Prefer recommendations from different sourceVolumes.
 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LBRRecommendedBook_CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    NSIndexPath *mutableIndexPath = [indexPath copy];
    NSUInteger lackOfOptionsAdjustment = 0;
    
        //If a volume doesn't exist at that index path, back up one, and
        //add a counter so that we traverse the recommendations array,
        //rather than presenting multiple copies of the same recommendation.
    
    while (nil == [self.fetchedResultsController objectAtIndexPath:mutableIndexPath]) {
        mutableIndexPath = [self indexPathByDecrementingItemFrom:mutableIndexPath];
        lackOfOptionsAdjustment++; ///Possible not necessary, since it's random.
    }
    
    Volume *volume = (Volume*)[self.fetchedResultsController objectAtIndexPath:mutableIndexPath];
    [googleClient queryForRecommendationsRelatedToString:[volume isbn] withCallback:^(GTLBooksVolumes *responseCollection) {
        NSMutableArray <LBRParsedVolume*> *parsedRecommendationsArray = [NSMutableArray array];
        
            //The first object is the book itself, not the recommendations. We'll take 10.
        for (NSUInteger i = 1; i < 11; i++)
        {
            LBRParsedVolume *parsedVolume = [[LBRParsedVolume alloc] initWithGoogleVolume:[responseCollection itemAtIndex:i]];
            [parsedRecommendationsArray addObject:parsedVolume];
        }
        cell.recommendationsArray = [parsedRecommendationsArray copy];
            ///Check the volumes for the rest of the genre recommendations - if their are duplicates,
            ///then call the function again.
        
        BOOL isDuplicate;
        do {
            [cell displayRandomRecommendation];
            isDuplicate       = [self.coverArtURLs containsObject:cell.selectedVolumeIdentifier];
            self.coverArtURLs = [self.coverArtURLs arrayByAddingObject:cell.selectedVolumeIdentifier];
        } while (isDuplicate);
    }];

    return cell;
}

/**
 *  Retrieves the indexPath to the previous item by walking backwards one item (or if
 *   this is the first item in the section, walking back to the **last** item of the
 *   previous section).
 */
-(NSIndexPath*)indexPathByDecrementingItemFrom:(NSIndexPath*)indexPath {
    NSUInteger previousItem        = 0;
    NSUInteger previousSection     = 0;
    NSIndexPath *previousIndexPath = nil;
    
    if (indexPath.item) {
        previousItem = indexPath.item - 1;
    } else if (indexPath.section) {
        previousSection = indexPath.section - 1;
        previousItem = [self.collectionView numberOfItemsInSection:previousSection] - offBy1;
    }
    
    if (previousItem && previousSection)
    {
        previousIndexPath = [NSIndexPath indexPathForItem:previousItem inSection:previousSection];
    }
    
    return previousIndexPath;
}



#pragma mark - === UICollectionViewDelegate ===

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

#pragma mark - Header

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
        //Provides a view for the headers in the collection view
    
    LBRRecommendations_CollectionViewHeader *headerView = (LBRRecommendations_CollectionViewHeader *)[self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerReuseIdentifier forIndexPath:indexPath];
    
    NSArray *sections = [self.fetchedResultsController sections];
    NSObject <NSFetchedResultsSectionInfo> *currentSection = (NSObject <NSFetchedResultsSectionInfo> *)sections[indexPath.section];

    if ([currentSection isKindOfClass:[NSString class]]) {
        headerView.bookCategoryLabel.text = (NSString*)currentSection;
    } else
    {
        headerView.bookCategoryLabel.text = @"Error displaying book category";
    }
    
    headerView.bookCategoryLabel.textColor = [UIColor midnightBlueColor];
    return headerView;
}
    
#pragma mark Fetched Results Controller configuration

-(NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    return [[LBRDataManager sharedDataManager] preconfiguredLBRFetchedResultsController:self];
}

#pragma mark - === FetchedResultsController Delegate methods ===

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
