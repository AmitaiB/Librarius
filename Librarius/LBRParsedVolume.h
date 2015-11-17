//
//  LBRParsedVolume.h
//  Librarius
//
//  Created by Amitai Blickstein on 9/4/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GTLBooksVolume;
@interface LBRParsedVolume : NSObject

@property (nonatomic, strong) NSString * author;
@property (nonatomic, strong) NSString * authorSurname;
@property (nonatomic, strong) NSNumber * avgRating;
@property (nonatomic, strong) NSString * cover_art;
@property (nonatomic, strong) NSString * cover_art_large;
@property (nonatomic, strong) NSString * google_id;
@property (nonatomic, strong) NSNumber * height;
@property (nonatomic, strong) NSString * isbn10;
@property (nonatomic, strong) NSString * isbn13;
@property (nonatomic, strong) NSString * mainCategory;
@property (nonatomic, strong) NSNumber * pageCount;
@property (nonatomic, strong) NSString * publDescription;
@property (nonatomic, strong) NSDate   * published;
@property (nonatomic, strong) NSString * publisher;
@property (nonatomic, strong) NSNumber * rating;
@property (nonatomic, strong) NSNumber * ratingsCount;
@property (nonatomic, strong) NSString * subtitle;
@property (nonatomic, strong) NSNumber * thickness;
@property (nonatomic, strong) NSString * title;

@property (nonatomic, strong) NSArray  * categories;



-(instancetype)initWithGoogleVolume:(GTLBooksVolume*)volumeToParse;

-(NSString *)isbn;

@end
