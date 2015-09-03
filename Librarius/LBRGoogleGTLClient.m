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
    __block GTLServiceTicket *tempTicket = [GTLServiceTicket new];
    __block id responseObject;
    
    GTLQueryBooks *booksQuery = [GTLQueryBooks queryForVolumesListWithQ:ISBN];
        // The Books API currently requires that search queries not have an
        // authorization header (b/4445456)
    booksQuery.shouldSkipAuthorization = YES;
    
        //"Fields" limits the response to the desired information, saving system resources - the syntax is in the *web* docs: https://developers.google.com/books/docs/v1/reference/volumes/list?hl=en
    booksQuery.fields = @"items(id, volumeInfo)";

    
    [self.service executeQuery:booksQuery completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        NSLog(@"KNOW THIS: ticket.fetchedObject %@ equal to id object!", [ticket.fetchedObject isEqual:object]? @"IS" : @"IS NOT");
        NSLog(@"KNOW ALSO THIS: ticket.fetchedObject is of CLASS: %@. id object is of CLASS: %@!", NSStringFromClass([ticket.fetchedObject class]), NSStringFromClass([object class]));
        
        if (error) {
            NSLog(@"Error in booksQueryWithISBN: %@", error.localizedDescription);
        } else {
            tempTicket = ticket;
            responseObject = object;
            NSLog(@"id object's class is: %@", NSStringFromClass([object class]));
        }
    }];
    
    if (returnTicketInstead) {
        return tempTicket;
    }
    
    GTLBooksVolumes *spelunkMe = responseObject;
    if (spelunkMe.items[0]) {
        return spelunkMe.items[0];
    }
    return nil;
}



@end
