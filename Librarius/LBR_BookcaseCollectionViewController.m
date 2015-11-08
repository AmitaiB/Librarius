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
#import <UIImageView+AFNetworking.h>
#import "CoverArt.h"
#import "UIStepper+FlatUI.h"
#import "UIView+ABB_Categories.h"
#import "LBR_BookcasePopoverViewController.h"
#import "UIView+ConfigureForAutoLayout.h"
#import "LBR_PopoverBackgroundView.h"


@interface LBR_BookcaseCollectionViewController ()

//@property (nonatomic, strong) LBR_BookcaseLayout *layout;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableArray *sectionChanges;
@property (nonatomic, strong) NSMutableArray *itemChanges;
@property (nonatomic, strong) LBRDataManager *dataManager;
@property (nonatomic, strong) UIProgressView *progressView;
//@property (nonatomic, strong) LBR_BookcasePopoverViewController *adjustBookcaseVC;


    //Debug
@property (nonatomic, strong) NSMutableDictionary *debugDictionary;
@property (nonatomic, strong) NSMutableDictionary *debugDictionary2;
@property (nonatomic, strong) NSMutableArray <Volume*> *debugVolumeList;
@property (nonatomic, strong) NSMutableSet *debugCellSet;
- (IBAction)accessBookcaseAttributesButtonTapped:(id)sender;


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

    //Layout Scheme strings
static NSString * const GenreAuthorDateLayoutSchemeID = @"By Genre-Author";
static NSString * const AuthorOnlyLayoutSchemeID      = @"By Author";

#pragma mark - === Lifecycle ===

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutChangeSetup];
    
    self.title = @"Bookshelves";
        //Rope in the singleton dataManger
    self.dataManager = [LBRDataManager sharedDataManager];
    self.collectionView.directionalLockEnabled = YES;
    self.canDisplayBannerAds = YES;
    
        //Set custom layout with protocol
    layout = [LBR_BookcaseLayout new];
    [self.collectionView setCollectionViewLayout:layout];
    
    self.collectionView.backgroundColor = [UIColor cloudsColor];
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Cell classes prototyped in storyboard.

    volumesArray = self.fetchedResultsController.fetchedObjects;
        ///    [self precacheImages];
    
//    self.adjustBookcaseVC = [self buildAttributesAdjustmentPopoverController];
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


#pragma mark - === Navigation (UIPopoverPresentationController) ===

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"bookcasePopoverSegueID"])
    {
        LBR_BookcasePopoverViewController *popoverVC = segue.destinationViewController;
        
        [popoverVC view];
        
        popoverVC.preferredContentSize = popoverVC.contentView.frame.size;
        popoverVC.popoverPresentationController.delegate = self;
        popoverVC.numShelvesTxField.delegate = self;
        popoverVC.shelfWidth_cmTxField.delegate = self;
        
        popoverVC.numShelvesTxField.text = [@(layout.bookcaseModel.shelvesCount) stringValue];
        popoverVC.shelfWidth_cmTxField.text = [@(layout.bookcaseModel.width_cm) stringValue];
        
        
        
            //???: Why popoverBackgroundView so ugly?!
//        popoverVC.popoverPresentationController.popoverBackgroundViewClass = [LBR_PopoverBackgroundView class];
        
    }
}

    //Read-only property, can only be set via this delegate method. `..None` stops it from being a full-screen view.
-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

#pragma mark - === UITextField Delegate (for popover) ===

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.text = [NSString stringWithFormat:@"%@ %@", textField.text,
                      ([textField.accessibilityIdentifier isEqualToString:@"numShelvesTxField"]) ?
                      @"shelves" : @"cm"];
}

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
    cell.backgroundColor = [UIColor clearColor];
    
//    Volume *volumeModel = volumesArray[indexPath.item];
    Volume *volumeModel = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    CoverArt *coverArtModel = volumeModel.correspondingImageData;
//    [cell.imageView setImage:coverArtModel.preferredImageLarge];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", volumeModel.cover_art_large]];
    [cell.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cell.coverArtURLString = volumeModel.cover_art_large ? volumeModel.cover_art_large : volumeModel.cover_art ? volumeModel.cover_art: nil;
    
    
    cell.thickness = [volumeModel.thickness floatValue];
//    UIImage *coverArtImage = ((UIImageView*)coverArtArray[indexPath.item]).image;
//    [cell.imageView setImage:coverArtImage];

    /**
     //Debug
    NSData *imageData = UIImagePNGRepresentation(cell.imageView.image);
    [self.debugDictionary setObject:imageData forKey:cell.coverArtURLString];
    [self.debugCellSet addObject:cell];
    
    [self.debugVolumeList addObject:volumeModel];
    
    [self.debugDictionary2 setObject:volumeModel forKey:indexPath];
     */
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

//- (IBAction)accessBookcaseAttributesButtonTapped:(id)sender {
//    LBR_BookcasePopoverViewController *popoverController = [self buildAttributesAdjustmentPopoverController];
//    [self presentViewController:popoverController animated:YES completion:nil];
//}

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
    
    
    layoutChangesSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[GenreAuthorDateLayoutSchemeID, AuthorOnlyLayoutSchemeID, @"Flow (delete)"]];
    layoutChangesSegmentedControl.selectedSegmentIndex = 0;
    [layoutChangesSegmentedControl addTarget:self action:@selector(layoutChangesSegmentedControlDidChangeValue:) forControlEvents:UIControlEventValueChanged];
        //TODO: replace this, and make it work.
        //    self.navigationItem.titleView = layoutChangesSegmentedControl;
}

-(void)layoutChangesSegmentedControlDidChangeValue:(id)sender
{
    NSString *selectedLayout = [layoutChangesSegmentedControl titleForSegmentAtIndex:layoutChangesSegmentedControl.selectedSegmentIndex];
    
    if ([selectedLayout isEqualToString:GenreAuthorDateLayoutSchemeID]) {
        [self.collectionView setCollectionViewLayout:layout animated:YES];
    }
    
    
    
        //CLEAN: delete when "flow (delete)" is removed.
    else if ([selectedLayout isEqualToString:@"Flow (delete)"]) {
        [self.collectionView setCollectionViewLayout:standardFlowLayout animated:YES];
    }
}


#pragma mark - === UIPopoverPresentationController Delegate ===


//-(UIViewController *)buildAttributesAdjustmentPopoverController
//{
//        ///FIXME:
//    
//    UIViewController *viewController = [UIViewController new];
//    
//    UIView *contentView = viewController.view;
//    UITextField *numShelvesTxField = [UITextField new];
//    numShelvesTxField.placeholder     = @"# of Shelves";
//    UITextField *shelfWidth_cmTxField = [UITextField new];
//    shelfWidth_cmTxField.placeholder  = @"width (cm)";
//    UIStepper *numShelvesStepper = [UIStepper new];
//    UIStepper *shelfWidthStepper = [UIStepper new];
//    
//        //For both View Heirarchy and AutoLayout constraints
//    NSDictionary <NSString *, UIView*> *subViews = @{@"numField"    : numShelvesTxField,
//                                                     @"numStepper"  : numShelvesStepper,
//                                                     @"widthField"  : shelfWidth_cmTxField,
//                                                     @"widthStepper": shelfWidthStepper
//                                                     };
//    
//        //UIView Categories
//    [contentView addSubviews:[NSSet setWithArray:[subViews allValues]]];
//    [UIView configureViewsForAutolayout:[subViews allValues]];
//    
//    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[numField]-[numStepper]-16-[widthField]-[widthStepper]-|"
//                                                                        options:0
//                                                                        metrics:nil
//                                                                          views:subViews]];
//    
//    [subViews enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIView * _Nonnull obj, BOOL * _Nonnull stop) {
//        NSString *constraintString = [NSString stringWithFormat:@"V:|-[%@]-|", key];
//        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintString
//                                                                            options:0
//                                                                            metrics:nil
//                                                                              views:@{key : obj}]];
//    }];
//    
//    [contentView sizeToFit];
//    
//    viewController.modalPresentationStyle = UIModalPresentationPopover;
//    viewController.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
//    viewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
//    viewController.popoverPresentationController.delegate = self;
//    return viewController;
//}


@end
