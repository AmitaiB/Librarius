//
//  UIView+ConfigureForAutoLayout.m
//  Librarius
//
//  Created by Amitai Blickstein on 9/22/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "UIView+ConfigureForAutoLayout.h"

@implementation UIView (ConfigureForAutoLayout)

-(void)configureForAutolayout
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self removeConstraints:self.constraints];
}


+(void)configureViewsForAutolayout:(NSArray<UIView *> *)views
{
    for (UIView *view in views) {
        [view configureForAutolayout];
    }
}

-(void)removeAllConstraints
{
    [self removeConstraints:self.constraints];
}

@end
