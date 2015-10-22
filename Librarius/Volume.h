//
//  Volume.h
//  Librarius
//
//  Created by Amitai Blickstein on 8/28/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bookcase, Library;

@interface Volume : NSManagedObject

@property (nonatomic, retain) NSString * isbn10;
@property (nonatomic, retain) NSString * isbn13;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * thickness;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSNumber * pageCount;
@property (nonatomic, retain) NSString * cover_art;
@property (nonatomic, retain) NSString * cover_art_large;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, strong) NSString * authorSurname;
@property (nonatomic, retain) NSString * mainCategory;
@property (nonatomic, retain) NSDate * published;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSString * google_id;
@property (nonatomic, retain) Library *library;
@property (nonatomic, retain) Bookcase *bookcase;

@property (nonatomic, retain) NSString * publDescription;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * publisher;
@property (nonatomic, retain) NSNumber * avgRating;
@property (nonatomic, retain) NSNumber * ratingsCount;

-(NSString*)isbn;

@end
