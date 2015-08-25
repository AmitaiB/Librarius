//
//  LBRGoogleAPIClient.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/24/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBRGoogleAPIClient.h"
#import <AFNetworking.h>

@implementation LBRGoogleAPIClient

//static NSURL * const GBooksBaseURLString = [NSURL URLWithString:@"https://www.googleapis.com/books/v1/"];
+ (LBRGoogleAPIClient*)sharedInstance {
    
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    
    return _sharedInstance;
}



+(NSDictionary*)retrieveVolumeWithID:(NSString*)volumeIDString {
#warning This is not configured.
    return [NSDictionary new];
}

+(NSArray*)retrieveVolumesWithQuery:(NSString*)queryString {
#warning This is also not configured.
    return [NSArray new];
}



@end
