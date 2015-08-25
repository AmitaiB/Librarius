//
//  LBRGoogleAPIClient.h
//  Librarius
//
//  Created by Amitai Blickstein on 8/24/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^LBRVolumesQueryCompletionBlock)(NSArray *volumes, NSError * error);

@interface LBRGoogleAPIClient : NSObject

+(LBRGoogleAPIClient *)sharedInstance;

+(NSDictionary*)retrieveVolumeWithID:(NSString*)volumeIDString;
+(NSArray*)retrieveVolumesWithQuery:(NSString*)queryString;

@property (nonatomic, strong) NSDictionary *googleVolume;


@end
