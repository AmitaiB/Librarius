//
//  LBRGoogleGTLClient.h
//  Librarius
//
//  Created by Amitai Blickstein on 8/31/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GTLBooks.h>
#import "LBRDataManager.h"

@class LBRParsedVolume;
@interface LBRGoogleGTLClient : NSObject

@property (nonatomic, strong) LBRDataManager *dataManager;
@property (nonatomic, strong) GTLServiceBooks *service;
@property (nonatomic, strong) GTLServiceTicket *mostRecentTicket;
@property (nonatomic, strong) GTLBooksVolumes *responseObject;
@property (nonatomic, strong) NSError *blockError;

+(instancetype)sharedGoogleGTLClient;
-(instancetype)init;

-(void)queryForVolumeWithISBN:(NSString*)ISBN returnTicket:(BOOL)returnTicketInstead;

@end
