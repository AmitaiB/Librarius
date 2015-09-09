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
    _isbn13          = [NSString new];
    _isbn10          = [NSString new];
    _title           = [NSString new];
    _pageCount       = nil;
    _thickness       = nil;
    _height          = nil;
    _cover_art       = nil;
    _cover_art_large = nil;
    _author          = @"John Doe";
    _authorSurname   = @"Doe";
    _categories      = @[@"No Category"];
    _published       = [NSDate distantPast];
    _rating          = nil;
    _google_id       = [NSString new];

    
    
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
     *  Title
     */
    if (volumeToParse.volumeInfo.title.length > 0) {
        _title = volumeToParse.volumeInfo.title;
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
     *  Categories - though for now we will only pass one over to Volume(s).
     */
    if (volumeToParse.volumeInfo.categories.count) {
        _categories = volumeToParse.volumeInfo.categories;
    }

    
    /**
     *  Date of publication.
     */
    if (volumeToParse.volumeInfo.publishedDate) {
        _published = [volumeToParse.volumeInfo.publishedDate dateValue];
    }
    
    /**
     *  Average rating. TODO: ../ratingsCount?
     */
    if (volumeToParse.volumeInfo.averageRating) {
        _rating = volumeToParse.volumeInfo.averageRating;
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
