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
#import "NSString+dateValue.h"

#define CALIPER [@"436" floatValue] //In papes per inch, ppi.
/**
Typical uncoated digital book paper calipers:

50-lb. natural high bulk, 456 PPI.
60-lb. natural trade book, 436 PPI.
80-lb. white opaque smooth, 382 PPI.
 */

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
    
    /**
     *  Default Values
     */
    newLBRVolume.isbn13    = [NSString new];
    newLBRVolume.isbn10    = [NSString new];
    newLBRVolume.title     = [NSString new];
    newLBRVolume.pageCount = nil;
    newLBRVolume.thickness     = nil;
    newLBRVolume.height    = nil;
    newLBRVolume.cover_art = @"https://www.google.com";
    newLBRVolume.author    = @"John Doe";
    newLBRVolume.category  = @"General Literature";
    newLBRVolume.published = [NSDate distantPast];
    newLBRVolume.rating    = @1;
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
     *  PageCount
     */
    if ([volumeToAdd.volumeInfo.pageCount integerValue] > 0) {
        newLBRVolume.pageCount = volumeToAdd.volumeInfo.pageCount;
    } else if ([volumeToAdd.volumeInfo.printedPageCount integerValue] > 0) {
        newLBRVolume.pageCount = volumeToAdd.volumeInfo.printedPageCount;
    }
    
    
    /**
     *  Height, in inches (from cm), if the information is present.
     */
    NSNumber *height = @([volumeToAdd.volumeInfo.dimensions.height floatValue] / 2.54);
    if ([height floatValue] > 0.0) {
        newLBRVolume.height = height;
    }
    /**
     *  Thickness of the book's spine, in inches (from cm). If not given, it will be estimated from the pagecount, if it is defined.
     */
    NSNumber *thickness = @([volumeToAdd.volumeInfo.dimensions.thickness floatValue] / 2.54);
    
    if ([thickness floatValue] > 0.0) {
        newLBRVolume.thickness = thickness;
    }
    else if (newLBRVolume.pageCount) {
        newLBRVolume.thickness = @([newLBRVolume.pageCount floatValue] / CALIPER);
    }
    
    /**
     *  Cover Art URL
     */
    if (volumeToAdd.volumeInfo.imageLinks.thumbnail) {
        newLBRVolume.cover_art = volumeToAdd.volumeInfo.imageLinks.thumbnail;
    }
    else if (volumeToAdd.volumeInfo.imageLinks.smallThumbnail) {
        newLBRVolume.cover_art = volumeToAdd.volumeInfo.imageLinks.smallThumbnail;
    }
    
    /**
     *  Author(s).
     */
    NSUInteger numberOfAuthors = volumeToAdd.volumeInfo.authors.count;
    if (!numberOfAuthors) {
            //Do nothing
    } else if (numberOfAuthors == 1) {
            newLBRVolume.author = volumeToAdd.volumeInfo.authors[0];
    } else if (numberOfAuthors >=2) {
        newLBRVolume.author = [volumeToAdd.volumeInfo.authors componentsJoinedByString:@" & "];
    }
    
    /**
     *  Date of publication.
     */
    if (volumeToAdd.volumeInfo.publishedDate) {
        newLBRVolume.published = [volumeToAdd.volumeInfo.publishedDate dateValue];
    }
    
    /**
     *  Average rating. TODO: ../ratingsCount?
     */
    if (volumeToAdd.volumeInfo.averageRating) {
        newLBRVolume.rating = volumeToAdd.volumeInfo.averageRating;
    }
    
    /**
     *  Google ID for the volume. Vital!
     */
    
    newLBRVolume.google_id = volumeToAdd.identifier;
}


#pragma mark - helper methods

-(NSString*)stringWithOnlyNumbersFrom:(NSString*)string {
    return [[string componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet]invertedSet]]componentsJoinedByString:@""];
}

-(NSString*)lastNameFrom:(NSString*)fullName {
    return [fullName componentsSeparatedByString:@" "][1];
}

@end
