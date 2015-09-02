//
//  LBRDataManager.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/26/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBRDataManager.h"
#import "LBRDataStore.h"


@implementation LBRDataManager

+ (instancetype)sharedDataManager {
    static LBRDataManager *_sharedDataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDataManager = [self new];
    });
    
    return _sharedDataManager;
}

-(void)addVolumeToCollectionAndSave:(GTLBooksVolume*)volumeToAdd {
    
}

@end
