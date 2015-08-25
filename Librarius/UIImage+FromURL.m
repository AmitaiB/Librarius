//
//  UIImage+FromURL.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/24/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "UIImage+FromURL.h"

@implementation UIImage (FromURL)

+(UIImage*)imageWithContentsOfURLString:(NSString*)URLString {
    return [UIImage imageWithCIImage:[CIImage imageWithContentsOfURL:[NSURL URLWithString:URLString]]];
}

@end
