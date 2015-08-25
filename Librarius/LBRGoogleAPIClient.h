//
//  LBRGoogleAPIClient.h
//  Librarius
//
//  Created by Amitai Blickstein on 8/24/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^LBRVolumesQueryCompletionBlock)(NSArray *volumes, NSError * error);

@class AFHTTPSessionManager;
@interface LBRGoogleAPIClient : NSObject

+(AFHTTPSessionManager *)sharedSessionManager;

+(NSDictionary*)retrieveVolumeWithID:(NSString*)volumeIDString;

@property (nonatomic, strong) <#type#> *<#value#>;


@end
