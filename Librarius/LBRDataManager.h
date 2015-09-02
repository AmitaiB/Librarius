//
//  LBRDataManager.h
//  Librarius
//
//  Created by Amitai Blickstein on 8/26/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LBRGoogleGTLClient.h"

@interface LBRDataManager : NSObject

    // ScannerVC:GoogleBooksClient → VolumePresentationTVC
@property (nonatomic, strong) NSMutableArray *uniqueCodes;

+(instancetype)sharedDataManager;

-(void)addVolumeToCollectionAndSave:(GTLBooksVolume*)volumeToAdd;

@end
