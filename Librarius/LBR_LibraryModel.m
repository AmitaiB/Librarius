//
//  LBR_LibraryModel.m
//  Librarius
//
//  Created by Amitai Blickstein on 11/15/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBR_LibraryModel.h"
#import "LBR_BookcaseModel.h"
#import "Library.h"
#import "LBRDataManager.h"
#import "Bookcase.h"
#import "Volume.h"

@interface LBR_BookcaseModel ()
@property (nonatomic, strong) NSArray <Volume*> *remainingVolumes;
@end


@implementation LBR_LibraryModel

-(instancetype)initWithLibrary:(Library *)library layoutScheme:(LBRLayoutScheme)layoutScheme
{
    if (!(self = [super init])) return nil;
    
    _library = library;
    _layoutScheme = &layoutScheme;
    
    return self;
}

-(instancetype)initWithLibrary:(Library *)library
{
    return [self initWithLibrary:library layoutScheme:LBRLayoutSchemeDefault];
}

-(instancetype)init
{
    return [self initWithLibrary:[LBRDataManager sharedDataManager].currentLibrary];
}

-(void)processLibrary
{
//    NSMutableDictionary *mutableBookcaseModels = [NSMutableDictionary dictionary];
//    NSIndexPath *currentLibraryPath = self.librariesCollectionView.indexPathsForSelectedItems.firstObject;
//    NSInteger targetSection = currentLibraryPath ? currentLibraryPath.item : 0;

    LBRDataManager *dataManager = [LBRDataManager sharedDataManager];
    NSFetchedResultsController *volumesInCurrentLibraryFRC = [dataManager preconfiguredLBRFetchedResultsController];
    NSArray *allVolumesInCurrentLibrary = volumesInCurrentLibraryFRC.fetchedObjects;
    
        //Prepare for for-loop
    NSSortDescriptor *orderDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"orderWhenListed" ascending:YES];
    NSArray *bookcasesInListOrder = [self.library.bookcases sortedArrayUsingDescriptors:@[orderDescriptor]];

    NSArray <Volume*> *remainderVolumes = allVolumesInCurrentLibrary;
    LBR_BookcaseModel *bookcaseModel;
    NSMutableArray <LBR_BookcaseModel*> *mutableShelvedBookcaseModels = [NSMutableArray array];

        /**
         1 - Model the bookcaseModel on the persistent (Core Data) Bookcase model.
         2 - Shelve the remaining books.
         3 - Add the shelved bookcase to our Library model's array.
         4 - Reset the remaining volumes for the next cycle of the loop.
         */
    for (Bookcase *bookcase in bookcasesInListOrder) {
        bookcaseModel = [[LBR_BookcaseModel alloc] initWithWidth:bookcase.width.floatValue shelvesCount:bookcase.shelves.integerValue];
        [bookcaseModel shelveBooks:remainderVolumes];
        [mutableShelvedBookcaseModels addObject:bookcaseModel];
        remainderVolumes = bookcaseModel.unshelvedRemainder;
    }
    self.bookcaseModels = [mutableShelvedBookcaseModels copy];
}

@end
