//
//  Volume.h
//  Librarius
//
//  Created by Amitai Blickstein on 8/25/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LBRVolume : NSObject

    // ALL the things!
@property (nonatomic, strong) NSDictionary *volumeData;

    //Unique Identifier(s)
@property (nonatomic, strong) NSString *volumeID;
@property (nonatomic, strong) NSString *ISBN_10;
@property (nonatomic, strong) NSString *ISBN_13;

    //Human-readable ID, to verify a title from a search
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSData *volumeCoverImageData;

    
-(instancetype)initWithGoogleVolume:(NSDictionary*)JSONcontentDictionary;


@end
