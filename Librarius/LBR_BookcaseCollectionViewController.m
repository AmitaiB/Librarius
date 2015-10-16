//
//  LBR_BookcaseCollectionViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 10/16/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#define kNumberOfShelvesInBookcase 5

#import "LBR_BookcaseCollectionViewController.h"
#import "LBRDataManager.h"


    //Views
#import "LBR_ShelvedBookCell.h"

    //Models
#import "Volume.h"

    //Layout
#import "LBR_BookcaseLayout.h"



@interface LBR_BookcaseCollectionViewController ()

@property (nonatomic, weak) IBOutlet LBR_BookcaseLayout *layout;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableArray *sectionChanges;


@end

@implementation LBR_BookcaseCollectionViewController {
    LBRDataManager *dataManager;
}

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.title = @"Bookshelves";
    
    // Register cell classes
    [self.collectionView registerClass:[LBR_ShelvedBookCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
        //Rope in the singleton dataManger
    dataManager = [LBRDataManager sharedDataManager];
    
    self.fetchedObjects = [self.fetchedResultsController.fetchedObjects copy];

    
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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return kNumberOfShelvesInBookcase;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of items
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    
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
    
    return [dataManager preconfiguredLBRFetchedResultsController:self];
}

@end