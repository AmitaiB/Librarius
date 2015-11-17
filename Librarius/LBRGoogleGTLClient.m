//
//  LBRGoogleGTLClient.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/31/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBRBarcodeScannerViewController.h"
#import "LBRGoogleGTLClient.h"
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
        _debugCounter = 0;
    }
    return self;
}

#pragma mark - API Query Methods

- (void)queryForVolumeWithString:(NSString *)queryString withCallback:(void (^)(GTLBooksVolume* responseVolume))block {
    GTLQueryBooks *booksQuery = [self booksQueryForString:queryString];
    
    [self.service executeQuery:booksQuery completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
            // callback
        if (error) {
           DDLogError(@"Error in booksQueryWithISBN: %@", error.localizedDescription);
        } else {
                // id  GTLBooksVolume dance:
            GTLBooksVolumes *responceObject = object;
            GTLBooksVolume *mostLikelyObject = [responceObject.items firstObject];
            block(mostLikelyObject); //<--Passes it back.
            DDLogVerbose(@"mostLikelyObject: %@", mostLikelyObject.volumeInfo.title);
        }
    }];
}

- (void)queryForRecommendationsRelatedToString:(NSString *)queryString withCallback:(void (^)(GTLBooksVolumes *))block {
    GTLQueryBooks *booksRecommendationQuery = [self booksQueryForString:queryString];
 
    [self.service executeQuery:booksRecommendationQuery completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        if (error) {
            DDLogError(@"Error in booksRecommendationQuery: %@", error.localizedDescription);
        }
        else
        {
            GTLBooksVolumes *bookAndRecommendations = (GTLBooksVolumes *)object;
            block(bookAndRecommendations);
        }
    }];
}

#pragma mark - Helper methods

-(GTLQueryBooks*)booksQueryForString:(NSString*)queryString {
        //CLEAN: not for shipping...
    DDLogDebug(@"%lu", (unsigned long)self.debugCounter++);
    GTLQueryBooks *booksQuery = [GTLQueryBooks queryForVolumesListWithQ:queryString];
    
        // The Books API currently requires that search queries not have an
        // authorization header (b/4445456)
    booksQuery.shouldSkipAuthorization = YES;
    
        //"Fields" limits the response to the desired information, saving system resources - the syntax is in the *web* docs: https://developers.google.com/books/docs/v1/reference/volumes/list?hl=en
    booksQuery.fields = @"items(id, volumeInfo)";
    
    return booksQuery;
}

//#pragma mark - DataManager Interface


@end
