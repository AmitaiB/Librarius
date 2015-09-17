//
//  UIImage+imageScaledToHeight.h
//  Librarius
//
//  Created by Amitai Blickstein on 9/16/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (imageScaledToHeight)

+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToHeight:(CGFloat)i_height;

@end
