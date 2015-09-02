//
//  LBRDataManager.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/26/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBRDataManager.h"
#import "LBRDataStore.h"
#import "Volume.h"


@implementation LBRDataManager

static NSString * const kUnknown = @"kUnknown";

+ (instancetype)sharedDataManager {
    static LBRDataManager *_sharedDataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDataManager = [self new];
    });
    
    return _sharedDataManager;
}

/**
 *  This will translate a GoogleBooks volume object into our NSManagedObject.
 */
-(void)addVolumeToCollectionAndSave:(GTLBooksVolume*)volumeToAdd {
    LBRDataStore *store = [LBRDataStore sharedDataStore];
    
//    Volume *newLBRVolume = [[Volume alloc] initWithEntity:@"Volume" insertIntoManagedObjectContext:store.managedObjectContext];
    Volume *newLBRVolume = [Volume new];
    
    newLBRVolume.isbn13 = [NSString new];
    newLBRVolume.isbn10 = [NSString new];
    newLBRVolume.title  = [NSString new];
    newLBRVolume.width  = @0.1;
    newLBRVolume.height = @0.1;
    newLBRVolume.pages  = @1;
    newLBRVolume.cover_art = @"https://www.google.com";
    newLBRVolume.author = @"John Doe";
    newLBRVolume.published = [NSDate distantPast];
    newLBRVolume.rating = @1;
    newLBRVolume.google_id = [NSString new];
    
    /**
     *  ISBN
     */
    for (NSDictionary *industryIDer in volumeToAdd.volumeInfo.industryIdentifiers) {
        if ([industryIDer[@"type"] isEqualToString:@"ISBN_13"]) {
            newLBRVolume.isbn13 = industryIDer[@"identifier"];
        }
        if ([industryIDer[@"type"] isEqualToString:@"ISBN_10"]) {
            newLBRVolume.isbn10 = industryIDer[@"identifier"];
        }
    }
    
    /**
     *  Title
     */
    if (volumeToAdd.volumeInfo.title.length > 0) {
        newLBRVolume.title = volumeToAdd.volumeInfo.title;
    }
    
    /**
     *  Dimensions
     */
            newLBRVolume.width;
            newLBRVolume.height;
            newLBRVolume.pages;
            newLBRVolume.cover_art;
            newLBRVolume.author;
            newLBRVolume.published;
            newLBRVolume.rating;
            newLBRVolume.google_id;
            newLBRVolume.library;
            newLBRVolume.bookcase;
}

@end
