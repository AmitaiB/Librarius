//
//  UIView+ConfigureForAutoLayout.m
//  Librarius
//
//  Created by Amitai Blickstein on 9/22/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "UIView+ConfigureForAutoLayout.h"

@implementation UIView (ConfigureForAutoLayout)

    //Very clean.
+(void)configureViewsForAutolayout:(NSArray<UIView *> *)views
{
    for (UIView *view in views) {
        [view configureForAutolayout];
    }
}

-(void)configureForAutolayout
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self removeConstraints:self.constraints];
}

    //Cannot remember why I broke this out by itself.
-(void)removeAllConstraints
{
    [self removeConstraints:self.constraints];
}

@end
