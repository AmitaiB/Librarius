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
        _googleVolume = @{};
    }
    return self;
}

-(void)retrieveVolumeWithID:(NSString*)volumeIDString withCompletion:(void(^)(NSDictionary *))completionBlock
{
    NSString *fullVolumeURL = [NSString stringWithFormat:@"%@%@%@", self.gBooksBaseURL, @"volumes/", volumeIDString];
    [self.sessionManager GET:fullVolumeURL parameters:nil
                     success:^(NSURLSessionDataTask * task, NSDictionary * responseObject) {
                         NSLog(@"ResponseObject allKeys: %@", [[responseObject allKeys] description]);
                         completionBlock(responseObject);
                             //success → get volume.
                     }
                     failure:^(NSURLSessionDataTask * task, NSError * error) {
                         NSLog(@"Error in retrieveVolumeWithID: %@", error.localizedDescription);
    }];
}

-(void)retrieveVolumesWithQuery:(NSString *)queryString withCompletion:(void(^)(NSDictionary * ))completionBlock {
    NSString *fullQueryURL = [NSString stringWithFormat:@"%@%@", self.gBooksBaseURL, @"volumes/"];
    NSDictionary *params = @{@"q" : queryString};
    [self.sessionManager GET:fullQueryURL parameters:params
                     success:^(NSURLSessionDataTask * task, NSDictionary *responseObject) {
                         completionBlock(responseObject);
                         NSLog(@"retrieveVolumesWithQuery → responseObject: %@", [responseObject description]/*? @"There is a description" : @"No description"*/ );
    } failure:^(NSURLSessionDataTask * task, NSError * error) {
            //failure :(
        NSLog(@"Error in retrieveVolumesWithQuery: %@", error.localizedDescription);
    }];
}


@end
