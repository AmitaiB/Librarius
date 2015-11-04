//
//  UIView+ConfigureForAutoLayout.h
//  Librarius
//
//  Created by Amitai Blickstein on 9/22/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ConfigureForAutoLayout)

-(void)configureForAutolayout;

+(void)configureViewsForAutolayout:(NSArray <UIView*> *)views;

-(void)removeAllConstraints;


@end
