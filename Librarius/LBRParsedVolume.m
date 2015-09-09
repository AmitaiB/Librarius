//
//  LBRParsedVolume.m
//  Librarius
//
//  Created by Amitai Blickstein on 9/4/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBRParsedVolume.h"
#import <GTLBooks.h>
#import "NSString+dateValue.h"

#define DBLG NSLog(@"<%@:%@:line %d, reporting!>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
#define CALIPER [@"436" floatValue] //In pages per inch, ppi.
/**
 Typical uncoated digital book paper calipers:
 
 50-lb. natural high bulk, 456 PPI.
 60-lb. natural trade book, 436 PPI.
 80-lb. white opaque smooth, 382 PPI.
 */

@implementation LBRParsedVolume


-(instancetype)initWithGoogleVolume:(GTLBooksVolume*)volumeToParse
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
        // Default values.
    _isbn13          = nil;
    _isbn10          = nil;
    _title           = @"Untitled";
    _pageCount       = nil;
    _thickness       = nil;
    _height          = nil;
    _cover_art       = nil;
    _cover_art_large = nil;
    _author          = @"John Doe";
    _authorSurname   = @"Doe";
    _categories      = @[];
    _published       = [NSDate distantPast];
    _rating          = nil;
    _google_id       = nil;

    _mainCategory    = @"No Category";
    _publDescription = @"No Description";
    _subtitle        = nil;
    _publisher       = nil;
    _avgRating       = nil;
    _ratingsCount    = nil;
    
    /**
     *  ISBN
     */
    for (GTLBooksVolumeVolumeInfoIndustryIdentifiersItem *item in volumeToParse.volumeInfo.industryIdentifiers) {
        if ([item.type isEqualToString:@"ISBN_10"]) {
            _isbn10 = item.identifierProperty;
        }
        if ([item.type isEqualToString:@"ISBN_13"]) {
            _isbn13 = item.identifierProperty;
        }
    }
    
    /**
     *  Title & Subtitle
     */
    if (volumeToParse.volumeInfo.title.length) {
        _title = volumeToParse.volumeInfo.title;
    }
    if (volumeToParse.volumeInfo.subtitle.length) {
        _subtitle = volumeToParse.volumeInfo.subtitle;
    }
    
    /**
     *  PageCount
     */
    if ([volumeToParse.volumeInfo.pageCount integerValue] > 0) {
        _pageCount = volumeToParse.volumeInfo.pageCount;
    } else if ([volumeToParse.volumeInfo.printedPageCount integerValue] > 0) {
        _pageCount = volumeToParse.volumeInfo.printedPageCount;
    }
    
    
    /**
     *  Height, in inches (from cm), if the information is present.
     */
    NSNumber *height = @([volumeToParse.volumeInfo.dimensions.height floatValue] / 2.54);
    if ([height floatValue] > 0.0) {
        _height = height;
    }
    /**
     *  Thickness of the book's spine, in inches (from cm). If not given, it will be estimated from the pagecount, if it is defined.
     */
    NSNumber *thickness = @([volumeToParse.volumeInfo.dimensions.thickness floatValue] / 2.54);
    
    if ([thickness floatValue] > 0.0) {
        _thickness = thickness;
    }
    else if (_pageCount) {
        _thickness = @([_pageCount floatValue] / CALIPER);
    }
    
    /**
     *  Cover Art URL
     */
    if (volumeToParse.volumeInfo.imageLinks.thumbnail) {
        _cover_art_large = volumeToParse.volumeInfo.imageLinks.thumbnail;
    }
    if (volumeToParse.volumeInfo.imageLinks.smallThumbnail) {
        _cover_art = volumeToParse.volumeInfo.imageLinks.smallThumbnail;
    }
    
    /**
     *  Author(s).
     */
    NSUInteger numberOfAuthors = volumeToParse.volumeInfo.authors.count;
    if (!numberOfAuthors) {
            //Do nothing
    } else if (numberOfAuthors == 1) {
        _author = volumeToParse.volumeInfo.authors[0];
    } else if (numberOfAuthors >=2) {
        _author = [volumeToParse.volumeInfo.authors componentsJoinedByString:@" & "];
    }
    
    /**
     *  Author's Surname (for sorting purposes).
     */
    if (_author) {
        _authorSurname = [_author componentsSeparatedByString:@" "][1];
    }
    /**
     *  Categories - just in case -- for now we will only pass over the mainCategory to Volume(s).
     */
    BOOL hasEntryForMainCategory = volumeToParse.volumeInfo.mainCategory.length;
    BOOL hasArrayOfCategories    = volumeToParse.volumeInfo.categories.count;
        // If there's no mainCategory, take it from categories.
    if (hasArrayOfCategories) {
        _categories = volumeToParse.volumeInfo.categories;
        _mainCategory = _categories[0];
    }
        // If there's no categories (count == 0), take it from mainCategory.
    if (hasEntryForMainCategory) {
        _mainCategory = volumeToParse.volumeInfo.mainCategory;
        _categories = [_categories arrayByAddingObject:_mainCategory];
    }
    

    
    /**
     *  Date of publication & publisher.
     */
    if (volumeToParse.volumeInfo.publishedDate) {
        _published = [volumeToParse.volumeInfo.publishedDate dateValue];
    }
    if (volumeToParse.volumeInfo.publisher) {
        _publisher = volumeToParse.volumeInfo.publisher;
    }
    
    /**
     *  Ratings! Yours...Google doesn't tell us, X-number of others' avg. rating.
     */
    if (volumeToParse.volumeInfo.averageRating) {
        _avgRating = volumeToParse.volumeInfo.averageRating;
    }
    if (volumeToParse.volumeInfo.ratingsCount) {
        _ratingsCount = volumeToParse.volumeInfo.ratingsCount;
    }
    
    
    /**
     *  Publisher's description.
     */
    if (volumeToParse.volumeInfo.descriptionProperty) {
        _publDescription = volumeToParse.volumeInfo.descriptionProperty;
    }
    
    /**
     *  Google ID for the volume. Vital!
     */
    
    _google_id = volumeToParse.identifier;
    
    
    return self;
}

-(instancetype)init {
    return [self initWithGoogleVolume:nil];
}

@end
