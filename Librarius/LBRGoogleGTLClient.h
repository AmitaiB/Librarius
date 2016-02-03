//
//  LBRGoogleGTLClient.h
//  Librarius
//
//  Created by Amitai Blickstein on 8/31/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GTLBooks.h>

/**
 TODO: Use http://isbndb.com/api/v2/docs/books which has DDN
 (Dewey decimal number) AND LOC (Library of Congress) INFORMATION!
 */

@class Volume;
@class LBRDataManager;
@interface LBRGoogleGTLClient : NSObject

@property (nonatomic, strong) LBRDataManager *dataManager;
@property (nonatomic, strong) GTLServiceBooks *service;
@property (nonatomic, strong) GTLBooksVolumes *responseObject;


+(instancetype)sharedGoogleGTLClient;
-(instancetype)init;

- (void)queryForVolumeWithString:(NSString *)queryString withCallback:(void (^)(GTLBooksVolume* responseVolume))block;

- (void)queryForRecommendationsRelatedToString:(NSString *)queryString withCallback:(void (^)(GTLBooksVolumes *responseCollection))block;

@end
