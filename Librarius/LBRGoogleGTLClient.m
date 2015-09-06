//
//  LBRGoogleGTLClient.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/31/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//
#define DBLG NSLog(@"<%@:%@:line %d, reporting!>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);

#import "LBRBarcodeScannerViewController.h"
#import "LBRGoogleGTLClient.h"
#import "LBRParsedVolume.h"
#import "LBRDataManager.h"
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
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNewBarcodeStringNotification:) name:barcodeAddedNotification object:nil];
        
        _debugCounter = 0;
        
        /**
         CLEAN: shouldn't be needed...
         */
//        _mostRecentTicket     = [[GTLServiceTicket alloc] initWithService:_service];
    }
    return self;
}

//-(void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

- (void)queryForVolumeWithString:(NSString *)queryString withCallback:(void (^)(GTLBooksVolume* responseVolume))block {
    NSLog(@"%lu", (unsigned long)self.debugCounter++);
    GTLQueryBooks *booksQuery = [GTLQueryBooks queryForVolumesListWithQ:queryString];

        // The Books API currently requires that search queries not have an
        // authorization header (b/4445456)
    booksQuery.shouldSkipAuthorization = YES;
    
        //"Fields" limits the response to the desired information, saving system resources - the syntax is in the *web* docs: https://developers.google.com/books/docs/v1/reference/volumes/list?hl=en
    booksQuery.fields = @"items(id, volumeInfo)";
    
    [self.service executeQuery:booksQuery completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
            // callback
        if (error) {
            NSLog(@"Error in booksQueryWithISBN: %@", error.localizedDescription);
        } else {
                // id  GTLBooksVolume dance:
            GTLBooksVolumes *responceObject = object;
            GTLBooksVolume *mostLikelyObject = [responceObject.items firstObject];
            block(mostLikelyObject); //<--Passes it back.
            NSLog(@"Job's done, because now the caller has the GTLVolume callback.");
        }
    }];
}


///**
// *  CLEAN: Phasing out this method.
//*/
//-(void)queryForVolumeWithISBN:(NSString*)ISBN returnTicket:(BOOL)returnTicketInstead {
//    
//    GTLQueryBooks *booksQuery = [GTLQueryBooks queryForVolumesListWithQ:ISBN];
//        // The Books API currently requires that search queries not have an
//        // authorization header (b/4445456)
//    booksQuery.shouldSkipAuthorization = YES;
//    
//        //"Fields" limits the response to the desired information, saving system resources - the syntax is in the *web* docs: https://developers.google.com/books/docs/v1/reference/volumes/list?hl=en
//    booksQuery.fields = @"items(id, volumeInfo)";
//
//    
//    [self.service executeQuery:booksQuery completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
//            // callback
//        if (!error) {
//                // id  GTLBooksVolume dance:
//            GTLBooksVolumes *responceObject = object;
//            GTLBooksVolume *mostLikelyObject = [responceObject.items firstObject];
//            LBRParsedVolume *parsedVolume_local = [[LBRParsedVolume alloc] initWithGoogleVolume:mostLikelyObject];
//            
//                // Store reference in data manager, via interface.
//            [self updateAndNotifyDataManagerWithLocalData:parsedVolume_local];
//            NSLog(@"Job's done, because now the dataManager has the ParsedVolume.");
//            
//            /**
//             *  CLEAN: shouldn't need these local variables anymore.
//             self.dataManager.responseCollectionOfPotentialVolumeMatches = object;
//            self.mostRecentTicket = ticket;
//            self.responseObject   = object;
//             */
//            
//                // Error handling.
//        } else {
//            NSLog(@"Error in booksQueryWithISBN: %@", error.localizedDescription);
//            self.blockError       = error;
//        }
//    }];
//}
//
//-(void)receivedNewBarcodeStringNotification:(NSNotification*)notification {
//    NSLog(@"%@ received notification: '%@'", NSStringFromClass([self class]), notification.name);
//    [self queryForVolumeWithISBN:[notification.object lastObject] returnTicket:NO];
//}

#pragma mark - DataManager Interface

/**
 *  Switchboard for updating the dataManager.
 *
 *  @param newLocalData Send in any data, but make sure there is an 'if' statement to catch it.
 */
//-(void)updateAndNotifyDataManagerWithLocalData:(id)newLocalData {
//    if ([newLocalData isMemberOfClass:[LBRParsedVolume class]]) {
//        self.dataManager.parsedVolumeFromLastBarcode = newLocalData;
//        [[NSNotificationCenter defaultCenter] postNotificationName:newParsedVolumeNotification object:newLocalData];
//    }
//}

@end
