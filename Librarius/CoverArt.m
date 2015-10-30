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

NSString * const imageSizeLarge = @"imageSizeLarge";
NSString * const imageSizeSmall = @"imageSizeSmall";

typedef NS_ENUM (NSUInteger, ABCoverArtImageSize) {
    ABCoverArtImageSizeSmall,
    ABCoverArtImageSizeLarge
};


// Insert code here to add functionality to your managed object subclass
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

@end
