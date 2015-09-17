//
//  UIImage+imageScaledToHeight.m
//  Librarius
//
//  Created by Amitai Blickstein on 9/16/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "UIImage+imageScaledToHeight.h"

@implementation UIImage (imageScaledToHeight)

+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToHeight:(CGFloat)i_height {
    CGFloat oldHeight = sourceImage.size.height;
    CGFloat scaleFactor = i_height / oldHeight;
    
    CGFloat newWidth = sourceImage.size.width * scaleFactor;
    CGFloat newHeight = oldHeight * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
