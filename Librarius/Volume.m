//
//  Volume.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/28/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "Volume.h"
#import "Bookcase.h"
#import "Library.h"


@implementation Volume

@dynamic isbn10;
@dynamic isbn13;
@dynamic title;
@dynamic thickness;
@dynamic height;
@dynamic pageCount;
@dynamic cover_art_large;
@dynamic cover_art;
@dynamic author;
@dynamic authorSurname;
@dynamic mainCategory;
@dynamic published;
@dynamic rating;
@dynamic google_id;
@dynamic library;
@dynamic bookcase;

@dynamic publDescription;
@dynamic subtitle;
@dynamic publisher;
@dynamic avgRating;
@dynamic ratingsCount;

-(NSString *)isbn {
    return self.isbn13? self.isbn13 : self.isbn10? self.isbn10 : nil;
}

@end
