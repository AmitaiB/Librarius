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
#warning This is not configured.
    [self.sessionManager GET:self.gBooksBaseURL parameters:nil success:^nullable void(NSURLSessionDataTask * task, NSDictionary * responseObject)
 {
         //success → get volume.
    } failure:^nullable void(NSURLSessionDataTask * task, NSError * error) {
        NSLog(@"Error in %@: %@", [NSStringFromSelector(_cmd),@"");
    }
}

-(void)retrieveVolumesWithQuery:(NSString*)queryString {
#warning This is also not configured.
    
}


@end
