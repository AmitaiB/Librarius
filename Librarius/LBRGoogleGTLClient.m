//
//  LBRGoogleGTLClient.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/31/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBRGoogleGTLClient.h"
#import "LBRConstants.h"

@implementation LBRGoogleGTLClient

+(instancetype)sharedGoogleGTLClient
{
    static LBRGoogleGTLClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] init];
    });
    
    return _sharedClient;
}

-(instancetype)init
{
    self = [super init];
    if(self) {
            // Initialize a service
        self.service = [GTLServiceBooks new];
        self.service.APIKey = GOOGLE_APP_KEY;
    }
    return self;
}


-(id)queryForVolumeWithISBN:(NSString*)ISBN {
    __block GTLServiceTicket *tempTicket = [GTLServiceTicket new];
    
    GTLQueryBooks *booksQuery = [GTLQueryBooks queryForVolumesListWithQ:ISBN];
    [self.service executeQuery:booksQuery completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        if (error) {
            NSLog(@"Error in booksQueryWithISBN: %@", error.localizedDescription);
        } else {
            tempTicket = ticket;
            NSLog(@"id object's class is: %@", NSStringFromClass([object class]));
        }
    }];
    return tempTicket;
}



@end
