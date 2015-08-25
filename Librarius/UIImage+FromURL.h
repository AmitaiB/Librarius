//
//  UIImage+FromURL.h
//  Librarius
//
//  Created by Amitai Blickstein on 8/24/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FromURL)

+(UIImage*)imageWithContentsOfURLString:(NSString*)URLString;

@end
