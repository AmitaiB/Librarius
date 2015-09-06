//
//  LBRGoogleGTLClient.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/31/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBRGoogleGTLClient.h"
#import "LBRConstants.h"
#import "LBRBarcodeScannerViewController.h"
#import "LBRDataManager.h"
#import "LBRParsedVolume.h"
#import "LBRConstants.h"

@implementation LBRGoogleGTLClient

#pragma mark - Lifecycle

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
        _service              = [GTLServiceBooks new];
        _service.APIKey       = GOOGLE_APP_KEY;
        _service.retryEnabled = YES;
        
        _dataManager = [LBRDataManager sharedDataManager];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNewBarcodeStringNotification:) name:barcodeAddedNotification object:nil];
        
        /**
         CLEAN: shouldn't be needed...
         */
        _mostRecentTicket     = [[GTLServiceTicket alloc] initWithService:_service];
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  CLEAN:We don't need the ticket!
*/
/**
 *  The workhorse of the GoogleClient. Hits the API, and receives the requested volume, as well as a collection of similar volumes.
 *
 *  @param ISBN                An NSString of the ISBN (other string values will probably work as well [e.g., author, title, etc.]).
 *  @param returnTicketInstead If YES, will return a GTL Service Ticket object instead, which carries more information. ticket.fetchedObject is returned if NO (default).
 */
-(void)queryForVolumeWithISBN:(NSString*)ISBN returnTicket:(BOOL)returnTicketInstead {
    
    GTLQueryBooks *booksQuery = [GTLQueryBooks queryForVolumesListWithQ:ISBN];
        // The Books API currently requires that search queries not have an
        // authorization header (b/4445456)
    booksQuery.shouldSkipAuthorization = YES;
    
        //"Fields" limits the response to the desired information, saving system resources - the syntax is in the *web* docs: https://developers.google.com/books/docs/v1/reference/volumes/list?hl=en
    booksQuery.fields = @"items(id, volumeInfo)";

    
    [self.service executeQuery:booksQuery completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
            // callback
        if (!error) {
                // id  GTLBooksVolume dance:
            GTLBooksVolumes *responceObject = object;
            GTLBooksVolume *mostLikelyObject = [responceObject.items firstObject];
            LBRParsedVolume *parsedVolume_local = [[LBRParsedVolume alloc] initWithGoogleVolume:mostLikelyObject];
            
                // Store reference in data manager, via interface.
            [self updateAndNotifyDataManagerWithLocalData:parsedVolume_local];
            NSLog(@"Job's done, because now the dataManager has the ParsedVolume.");
            
            /**
             *  CLEAN: shouldn't need these local variables anymore.
             self.dataManager.responseCollectionOfPotentialVolumeMatches = object;
            self.mostRecentTicket = ticket;
            self.responseObject   = object;
             */
            
                // Error handling.
        } else {
            NSLog(@"Error in booksQueryWithISBN: %@", error.localizedDescription);
            self.blockError       = error;
        }
    }];
}

-(void)receivedNewBarcodeStringNotification:(NSNotification*)notification {
    NSLog(@"%@ received notification: '%@'", NSStringFromClass([self class]), notification.name);
    [self queryForVolumeWithISBN:[notification.object lastObject] returnTicket:NO];
}

#pragma mark - DataManager Interface

/**
 *  Switchboard for updating the dataManager.
 *
 *  @param newLocalData Send in any data, but make sure there is an 'if' statement to catch it.
 */
-(void)updateAndNotifyDataManagerWithLocalData:(id)newLocalData {
    if ([newLocalData isMemberOfClass:[LBRParsedVolume class]]) {
        self.dataManager.parsedVolumeFromLastBarcode = newLocalData;
        [[NSNotificationCenter defaultCenter] postNotificationName:newParsedVolumeNotification object:newLocalData];
    }
}

@end
