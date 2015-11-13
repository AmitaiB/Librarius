//
//  Volume+CoreDataProperties.h
//  Librarius
//
//  Created by Amitai Blickstein on 11/12/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Volume.h"

NS_ASSUME_NONNULL_BEGIN

@interface Volume (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *author;
@property (nullable, nonatomic, retain) NSString *authorSurname;
@property (nullable, nonatomic, retain) NSNumber *avgRating;
@property (nullable, nonatomic, retain) NSString *cover_art;
@property (nullable, nonatomic, retain) NSString *cover_art_large;
@property (nullable, nonatomic, retain) NSDate *dateCreated;
@property (nullable, nonatomic, retain) NSDate *dateModified;
@property (nullable, nonatomic, retain) NSString *google_id;
@property (nullable, nonatomic, retain) NSNumber *height;
@property (nullable, nonatomic, retain) NSString *isbn10;
@property (nullable, nonatomic, retain) NSString *isbn13;
@property (nullable, nonatomic, retain) NSString *mainCategory;
@property (nullable, nonatomic, retain) NSNumber *pageCount;
@property (nullable, nonatomic, retain) NSString *publDescription;
@property (nullable, nonatomic, retain) NSDate *published;
@property (nullable, nonatomic, retain) NSString *publisher;
@property (nullable, nonatomic, retain) NSNumber *rating;
@property (nullable, nonatomic, retain) NSNumber *ratingsCount;
@property (nullable, nonatomic, retain) NSString *subtitle;
@property (nullable, nonatomic, retain) NSNumber *thickness;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) Bookcase *bookcase;
@property (nullable, nonatomic, retain) CoverArt *correspondingImageData;
@property (nullable, nonatomic, retain) Library *library;

@end

NS_ASSUME_NONNULL_END
