//
//  UIView+ABB_Categories.m
//  Librarius
//
//  Created by Amitai Blickstein on 11/5/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "UIView+ABB_Categories.h"

@implementation UIView (ABB_Categories)

-(void)addSubviews:(NSSet<UIView *> *)objects
{
    for (UIView *view in objects) {
        [self addSubview:view];
    }
}

@end
