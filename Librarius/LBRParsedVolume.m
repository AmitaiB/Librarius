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

#define DBLG NSLog(@"%@ reporting!", NSStringFromSelector(_cmd));
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
    
    /**
     *  ISBN
     */
    for (NSDictionary *industryIDer in volumeToParse.volumeInfo.industryIdentifiers) {
        if ([industryIDer[@"type"] isEqualToString:@"ISBN_13"]) {
            self.isbn13 = industryIDer[@"identifier"];
        }
        if ([industryIDer[@"type"] isEqualToString:@"ISBN_10"]) {
            self.isbn10 = industryIDer[@"identifier"];
        }
    }
    
    /**
     *  Title
     */
    if (volumeToParse.volumeInfo.title.length > 0) {
        self.title = volumeToParse.volumeInfo.title;
    }
    
    /**
     *  PageCount
     */
    if ([volumeToParse.volumeInfo.pageCount integerValue] > 0) {
        self.pageCount = volumeToParse.volumeInfo.pageCount;
    } else if ([volumeToParse.volumeInfo.printedPageCount integerValue] > 0) {
        self.pageCount = volumeToParse.volumeInfo.printedPageCount;
    }
    
    
    /**
     *  Height, in inches (from cm), if the information is present.
     */
    NSNumber *height = @([volumeToParse.volumeInfo.dimensions.height floatValue] / 2.54);
    if ([height floatValue] > 0.0) {
        self.height = height;
    }
    /**
     *  Thickness of the book's spine, in inches (from cm). If not given, it will be estimated from the pagecount, if it is defined.
     */
    NSNumber *thickness = @([volumeToParse.volumeInfo.dimensions.thickness floatValue] / 2.54);
    
    if ([thickness floatValue] > 0.0) {
        self.thickness = thickness;
    }
    else if (self.pageCount) {
        self.thickness = @([self.pageCount floatValue] / CALIPER);
    }
    
    /**
     *  Cover Art URL
     */
    if (volumeToParse.volumeInfo.imageLinks.thumbnail) {
        self.cover_art = volumeToParse.volumeInfo.imageLinks.thumbnail;
    }
    else if (volumeToParse.volumeInfo.imageLinks.smallThumbnail) {
        self.cover_art = volumeToParse.volumeInfo.imageLinks.smallThumbnail;
    }
    
    /**
     *  Author(s).
     */
    NSUInteger numberOfAuthors = volumeToParse.volumeInfo.authors.count;
    if (!numberOfAuthors) {
            //Do nothing
    } else if (numberOfAuthors == 1) {
        self.author = volumeToParse.volumeInfo.authors[0];
    } else if (numberOfAuthors >=2) {
        self.author = [volumeToParse.volumeInfo.authors componentsJoinedByString:@" & "];
    }
    
    /**
     *  Date of publication.
     */
    if (volumeToParse.volumeInfo.publishedDate) {
        self.published = [volumeToParse.volumeInfo.publishedDate dateValue];
    }
    
    /**
     *  Average rating. TODO: ../ratingsCount?
     */
    if (volumeToParse.volumeInfo.averageRating) {
        self.rating = volumeToParse.volumeInfo.averageRating;
    }
    
    /**
     *  Google ID for the volume. Vital!
     */
    
    self.google_id = volumeToParse.identifier;
    
    
    return self;
}

-(instancetype)init {
    self = [self initWithGoogleVolume:nil];
    
    _isbn13    = [NSString new];
    _isbn10    = [NSString new];
    _title     = [NSString new];
    _pageCount = nil;
    _thickness = nil;
    _height    = nil;
    _cover_art = @"https://www.google.com";
    _author    = @"John Doe";
    _category  = @"General Literature";
    _published = [NSDate distantPast];
    _rating    = nil;
    _google_id = [NSString new];
    
    return self;
}

@end
