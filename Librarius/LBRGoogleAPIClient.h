//
//  LBRGoogleAPIClient.h
//  Librarius
//
//  Created by Amitai Blickstein on 8/24/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@interface LBRGoogleAPIClient : NSObject

//+(LBRGoogleAPIClient *)sharedInstance;

-(void)retrieveVolumeWithID:     (NSString*)volumeIDString  withCompletion:(void(^)(NSDictionary *))completionBlock;
-(void)retrieveVolumesWithQuery: (NSString*)queryString     withCompletion:(void(^)(NSDictionary *))completionBlock;

@property (nonatomic, strong) AFHTTPSessionManager * sessionManager;
@property (nonatomic, strong) NSDictionary         * googleVolume;
@property (nonatomic, strong) NSString             * gBooksBaseURL;

@end
