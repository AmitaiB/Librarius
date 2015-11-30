//
//  Volume.m
//  Librarius
//
//  Created by Amitai Blickstein on 10/29/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

    //Models
#import "Volume.h"
#import "Bookcase.h"
#import "CoverArt.h"
#import "Library.h"

#import "NSString+dateValue.h"
#import "LBRDataManager.h"

#define CALIPER [@"436" floatValue] //In pages per inch, ppi.
/**
 Typical uncoated digital book paper calipers:
 
 50-lb. natural high bulk, 456 PPI.
 60-lb. natural trade book, 436 PPI.
 80-lb. white opaque smooth, 382 PPI.
 */


@implementation Volume

// Insert code here to add functionality to your managed object subclass
///Credit for these two methods: https://www.objc.io/issues/4-core-data/core-data-models-and-model-objects/#creating-objects
+(NSString *)entityName
{
    return @"Volume";
}

+(instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
}

+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context initializedFromGoogleBooksObject:(GTLBooksVolume*)googleBooksObject withCovertArt:(BOOL)insertWithAssociateCoverArtObject
{
        //One brief thing, one looong thing(s), one last brief thing:
//    (1)
    Volume *volume = [Volume insertNewObjectIntoContext:context];
    
        //Long bit follows:
//    (2)
    /**
     *  ISBN
     */
    for (GTLBooksVolumeVolumeInfoIndustryIdentifiersItem *item in googleBooksObject.volumeInfo.industryIdentifiers) {
        if ([item.type isEqualToString:@"ISBN_10"]) {
            volume.isbn10 = item.identifierProperty;
        }
        if ([item.type isEqualToString:@"ISBN_13"]) {
            volume.isbn13 = item.identifierProperty;
        }
    }
    
    /**
     *  Title & Subtitle
     */
    if (googleBooksObject.volumeInfo.title.length) {
        volume.title = [googleBooksObject.volumeInfo.title capitalizedString];
    }
    if (googleBooksObject.volumeInfo.subtitle.length) {
        volume.subtitle = [googleBooksObject.volumeInfo.subtitle capitalizedString];
    }
    
    /**
     *  PageCount
     */
    if ([googleBooksObject.volumeInfo.pageCount integerValue] > 0) {
        volume.pageCount = googleBooksObject.volumeInfo.pageCount;
    } else if ([googleBooksObject.volumeInfo.printedPageCount integerValue] > 0) {
        volume.pageCount = googleBooksObject.volumeInfo.printedPageCount;
    }
    
    
    /**
     *  Height, in cm, if the information is present.
     */
    NSNumber *height = @([googleBooksObject.volumeInfo.dimensions.height floatValue]);
    if ([height floatValue] > 0.0) {
        volume.height = height;
    }
    /**
     *  Thickness of the book's spine, in cm. If not given, it will be estimated from the pagecount, if it is defined.
     */
    NSNumber *thickness = @([googleBooksObject.volumeInfo.dimensions.thickness floatValue]);
    
    if ([thickness floatValue] > 0.0) {
        volume.thickness = thickness;
    }
    else if (volume.pageCount) {
        volume.thickness = @([volume.pageCount floatValue] / (CALIPER / 2.54)); //Caliper from ppi → ppcm
    }
    
    /**
     *  Cover Art URL
     */
    if (googleBooksObject.volumeInfo.imageLinks.thumbnail) {
        volume.cover_art_large = googleBooksObject.volumeInfo.imageLinks.thumbnail;
    }
    if (googleBooksObject.volumeInfo.imageLinks.smallThumbnail) {
        volume.cover_art = googleBooksObject.volumeInfo.imageLinks.smallThumbnail;
    }
    
    /**
     *  Author(s).
     */
    NSUInteger numberOfAuthors = googleBooksObject.volumeInfo.authors.count;
    if (!numberOfAuthors) {
            //Do nothing
    } else if (numberOfAuthors == 1) {
        volume.author = googleBooksObject.volumeInfo.authors[0];
    } else if (numberOfAuthors >=2) {
        volume.author = [googleBooksObject.volumeInfo.authors componentsJoinedByString:@" & "];
    }
    
    /**
     *  Author's Surname (for sorting purposes).
     */
    if (volume.author) {
        NSArray *authorNameArray = [volume.author componentsSeparatedByString:@" "];
        if (authorNameArray.count >= 2) {
            volume.authorSurname = authorNameArray[1];
        }
        else
        {
            volume.authorSurname = @"Doe";
        }
    }
    /**
     *  Categories - just in case -- for now we will only pass over the mainCategory to Volume(s).
     */
    volume.mainCategory = googleBooksObject.volumeInfo.mainCategory.length? googleBooksObject.volumeInfo.mainCategory : googleBooksObject.volumeInfo.categories.count? googleBooksObject.volumeInfo.categories[0] : @"No Category";

    
    /**
     *  Date of publication & publisher.
     */
    if (googleBooksObject.volumeInfo.publishedDate) {
        volume.published = [googleBooksObject.volumeInfo.publishedDate dateValue];
    }
    if (googleBooksObject.volumeInfo.publisher) {
        volume.publisher = googleBooksObject.volumeInfo.publisher;
    }
    
    /**
     *  Others' Ratings! X-number of others' avg. rating.
     */
    if (googleBooksObject.volumeInfo.averageRating) {
        volume.avgRating = googleBooksObject.volumeInfo.averageRating;
    }
    if (googleBooksObject.volumeInfo.ratingsCount) {
        volume.ratingsCount = googleBooksObject.volumeInfo.ratingsCount;
    }
    
    
    /**
     *  Publisher's description.
     */
    if (googleBooksObject.volumeInfo.descriptionProperty) {
        volume.publDescription = googleBooksObject.volumeInfo.descriptionProperty;
    }
    
    /**
     *  Google ID for the volume. Vital!
     */
    
    volume.google_id = googleBooksObject.identifier;
    
        //DEBUG: (checks whether this object is in core data -- it is!)
    [[LBRDataManager sharedDataManager] logCurrentLibraryTitles:@"[insertNewObjectIntoContext:initializedFromGoogleBooksObject]"];

        //Final brief bit:
        //    (3)
    if (insertWithAssociateCoverArtObject) {
        CoverArt *associatedCoverArt = [CoverArt insertNewObjectIntoContext:context];
        associatedCoverArt.correspondingVolume = volume;
        [associatedCoverArt downloadImagesIfNeeded];
    }
    
    return volume;
}


    ///Not sure if this is neccesary to trigger the loading of images in the CoverArt setter.
-(void)updateCoverArtModelIfNeeded
{
    if (self.correspondingImageData)
        [self.correspondingImageData downloadImagesIfNeeded];
}


#pragma mark - === Access Helper methods ===
-(NSString *)isbn {
    return self.isbn13? self.isbn13 : self.isbn10? self.isbn10 : nil;
}

-(NSString *)coverArtPreferLarge
{
    return self.cover_art_large ? self.cover_art_large : self.cover_art ? self.cover_art: nil;
}

-(NSString *)fullTitle
{
    NSString *fullTitle = self.title;
    if (self.subtitle.length)
        fullTitle = [NSString stringWithFormat:@"%@: %@", self.title, self.subtitle];
    return fullTitle;
}

-(NSString *)byline
{
    NSString *byline = [NSString stringWithFormat:@"\nby %@ (%@: %@)", self.author, [NSString yearFromDate:self.published], self.publisher];
    return byline;
}

- (void)makeTitleCase:(NSString*)string {
    NSArray *words = [string componentsSeparatedByString:@" "];
    for (NSString __strong *word in words) {
        if ([@[@"the", @"and", @"a", @"of"] containsObject:word]) {
                // Don't capitalize = do nothing.
        }
        else if ([@[@"ios"] containsObject:word.lowercaseString]) {
            word = @"iOS";
        }
        else {
            word = word.capitalizedString;
        }
    }
    string = [words componentsJoinedByString:@" "];
}

@end
