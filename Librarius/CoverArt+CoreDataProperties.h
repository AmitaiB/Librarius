//
//  CoverArt+CoreDataProperties.h
//  Librarius
//
//  Created by Amitai Blickstein on 10/29/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CoverArt.h"

NS_ASSUME_NONNULL_BEGIN

@interface CoverArt (CoreDataProperties)

@property (nullable, nonatomic, retain) NSData *coverArtImageDataSizeSmall;
@property (nullable, nonatomic, retain) NSString *coverArtURLSizeSmall;
@property (nullable, nonatomic, retain) NSData *coverArtImageDataSizeLarge;
@property (nullable, nonatomic, retain) NSString *coverArtURLSizeLarge;
@property (nullable, nonatomic, retain) Volume *correspondingVolume;

@end

NS_ASSUME_NONNULL_END
