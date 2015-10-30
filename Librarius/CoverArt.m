//
//  CoverArt.m
//  Librarius
//
//  Created by Amitai Blickstein on 10/29/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "CoverArt.h"
#import "Volume.h"
#import <UIImageView+AFNetworking.h>

@implementation CoverArt

typedef NS_ENUM (NSUInteger, ABCoverArtImageSize) {
    ABCoverArtImageSizeSmall,
    ABCoverArtImageSizeLarge
};


// Insert code here to add functionality to your managed object subclass
#pragma mark - Accessors (overridden)

-(void)downloadImagesIfNeeded
{
//Make sure the images exist, and agree with the volume.
    BOOL storedImageCorrespondsToVolume = ([self.coverArtURLSizeLarge isEqualToString:self.correspondingVolume.cover_art_large] || [self.coverArtURLSizeSmall isEqualToString:self.correspondingVolume.cover_art]);
    
    if ([self hasNoImages] || !storedImageCorrespondsToVolume) {
        [self downloadImagesForCorrespondingVolume:self.correspondingVolume];
    }
}



#pragma mark - Image Downloading

/**
 Downloads the images of the volume, and associates itself with the volume with a
 relationship in the database. Initialize the Volume object first, specifically
 with a non-null URL for cover_art or cover_art_large.
 */
-(void)downloadImagesForCorrespondingVolume:(Volume *)volume
{
    self.correspondingVolume = volume;
    if (volume.cover_art) {
        [self downloadImageAtURL:volume.cover_art forSize:ABCoverArtImageSizeSmall];
    }
    if (volume.cover_art_large) {
        [self downloadImageAtURL:volume.cover_art_large forSize:ABCoverArtImageSizeLarge];
    }
}


-(void)downloadImageAtURL:(NSString *)urlString forSize:(ABCoverArtImageSize)size
{
    UIImageView *imageView = [UIImageView new];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [imageView setImageWithURLRequest:request
                     placeholderImage:nil
                              success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
                                  if (size == ABCoverArtImageSizeLarge) {
                                      self.coverArtImageDataSizeLarge = UIImagePNGRepresentation(image);
                                      self.coverArtURLSizeLarge = urlString;
                                  }
                                  if (size == ABCoverArtImageSizeSmall) {
                                      self.coverArtImageDataSizeSmall = UIImagePNGRepresentation(image);
                                      self.coverArtURLSizeSmall = urlString;
                                  }
                              }
                              failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
                                  NSLog(@"Error in %@: %@", NSStringFromSelector(_cmd), error.localizedDescription);
                              }];
}



#pragma mark - Image Reporting

-(BOOL)hasNoImages
{
    return !(self.coverArtImageDataSizeLarge || self.coverArtURLSizeSmall);
}



#pragma mark - Image Delivery

-(UIImage *)preferredImageLarge
{
    if (self.coverArtImageDataSizeLarge)
        return [UIImage imageWithData:self.coverArtImageDataSizeLarge];
    if (self.coverArtURLSizeSmall)
        return [UIImage imageWithData:self.coverArtImageDataSizeSmall];
    return nil;
}


-(UIImage *)preferredImageSmall
{
    if (self.coverArtURLSizeSmall)
        return [UIImage imageWithData:self.coverArtImageDataSizeSmall];
    if (self.coverArtImageDataSizeLarge)
        return [UIImage imageWithData:self.coverArtImageDataSizeLarge];
    return nil;
}

@end
