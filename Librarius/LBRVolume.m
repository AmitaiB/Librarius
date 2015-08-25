//
//  Volume.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/25/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBRVolume.h"
#import <UIKit/UIKit.h>

@implementation LBRVolume


-(instancetype)initWithGoogleVolume:(NSDictionary*)JSONcontentDictionary {
    self = [super init];
    if (!self) {
        return nil;
    }
    _volumeData       = JSONcontentDictionary;
    _volumeID         = JSONcontentDictionary[@"id"];
    NSString *ISBN_10 = JSONcontentDictionary[@"volumeInfo"][@"industryIdentifiers"][0][@"identifier"];
    NSString *ISBN_13 = JSONcontentDictionary[@"volumeInfo"][@"industryIdentifiers"][1][@"identifier"];
    _ISBN_10          = ISBN_10? ISBN_10 : @"";
    _ISBN_13          = ISBN_13? ISBN_13 : @"";
    
    _title = JSONcontentDictionary[@"volumeInfo"][@"title"];
    NSURL *imageURL = [NSURL URLWithString:JSONcontentDictionary[@"volumeInfo"][@"imageLinks"][@"thumbnail"]];
    _volumeCoverImageData = UIImagePNGRepresentation([UIImage imageWithCIImage:[CIImage imageWithContentsOfURL:imageURL]]);
    
    return self;
}


@end
