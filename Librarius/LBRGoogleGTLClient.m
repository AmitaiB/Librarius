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
        _mostRecentTicket     = [[GTLServiceTicket alloc] initWithService:_service];
        _service.APIKey       = GOOGLE_APP_KEY;
        _service.retryEnabled = YES;
        
        _dataManager = [LBRDataManager sharedDataManager];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveBarcodeAddedNotification:) name:barcodeAddedNotification object:nil];
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  CLEAN:We don't need the ticket!
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
                // id-to-GTLBooksVolume dance:
            GTLBooksVolumes *responceObject = object;
            GTLBooksVolume *mostLikelyObject = [responceObject.items firstObject];
            self.dataManager.parsedVolumeFromLastBarcode = [[LBRParsedVolume alloc] initWithGoogleVolume:mostLikelyObject];
            NSLog(@"Job's done, because now the dataManager has the ParsedVolume.");
            
            /**
             *  CLEAN: probably not needed anymore.
             */
                //            self.dataManager.responseCollectionOfPotentialVolumeMatches = object;
            self.mostRecentTicket = ticket;
            self.responseObject   = object;
        } else {
            NSLog(@"Error in booksQueryWithISBN: %@", error.localizedDescription);
            self.blockError       = error;
        }
    }];
}

-(void)receiveBarcodeAddedNotification:(NSNotification*)notification {
    NSLog(@"%@ received notification: '%@'", NSStringFromClass([self class]), notification.name);
    [self queryForVolumeWithISBN:[notification.object lastObject] returnTicket:NO];
}




@end
