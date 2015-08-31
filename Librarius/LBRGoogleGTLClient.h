//
//  LBRGoogleGTLClient.h
//  Librarius
//
//  Created by Amitai Blickstein on 8/31/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GTLBooks.h>

@interface LBRGoogleGTLClient : NSObject

@property (nonatomic, strong) GTLServiceBooks *service;

+(instancetype)sharedGoogleGTLClient;
-(instancetype)init;

-(id)queryForVolumeWithISBN:(NSString*)ISBN;

@end
