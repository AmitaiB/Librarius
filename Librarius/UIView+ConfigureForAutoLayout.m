//
//  UIView+ConfigureForAutoLayout.m
//  Librarius
//
//  Created by Amitai Blickstein on 9/22/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "UIView+ConfigureForAutoLayout.h"

@implementation UIView (ConfigureForAutoLayout)

-(void)configureForAutolayout {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self removeConstraints:self.constraints];
}

@end
