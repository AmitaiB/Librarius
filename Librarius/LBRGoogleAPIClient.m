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

- (instancetype)init
{
    self = [super init];
    if (self) {
        _gBooksBaseURL = @"https://www.googleapis.com/books/v1/";
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:_gBooksBaseURL]];
        _sessionManager.requestSerializer =
        _googleVolume = @{};
    }
    return self;
}

-(void)retrieveVolumeWithID:(NSString*)volumeIDString {
    [self.sessionManager GET:self.gBooksBaseURL parameters:nil success:^(NSURLSessionDataTask * task, NSDictionary * responseObject)
 {
         //success → get volume.
    } failure:^(NSURLSessionDataTask * task, NSError * error) {
        NSLog(@"Error in retrieveVolumeWithID: %@", error.localizedDescription);
    }];
}

-(void)retrieveVolumesWithQuery:(NSString*)queryString {
#warning This is also not configured.
    
}


@end
