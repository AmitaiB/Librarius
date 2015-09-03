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
        self.service.retryEnabled = YES;
    }
    return self;
}


-(id)queryForVolumeWithISBN:(NSString*)ISBN returnTicket:(BOOL)returnTicketInstead {
    __block GTLServiceTicket *responseTicket = [GTLServiceTicket new];
    
    GTLQueryBooks *booksQuery = [GTLQueryBooks queryForVolumesListWithQ:ISBN];
        // The Books API currently requires that search queries not have an
        // authorization header (b/4445456)
    booksQuery.shouldSkipAuthorization = YES;
    
        //"Fields" limits the response to the desired information, saving system resources - the syntax is in the *web* docs: https://developers.google.com/books/docs/v1/reference/volumes/list?hl=en
    booksQuery.fields = @"items(id, volumeInfo)";

    
    [self.service executeQuery:booksQuery completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        if (error) {
            NSLog(@"Error in booksQueryWithISBN: %@", error.localizedDescription);
        } else {
            responseTicket = ticket;
        }
    }];
    
    if (returnTicketInstead) {
        return responseTicket;
    }
    
    if (responseTicket.fetchedObject) {
        return responseTicket.fetchedObject;
    }
    return nil;
}



@end
