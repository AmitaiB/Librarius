//
//  ABB_BufferToolbar.m
//  Librarius
//
//  Created by Amitai Blickstein on 10/29/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "ABB_BufferToolbar.h"

@implementation ABB_BufferToolbar

-(instancetype)initWithController:(UIViewController *)superViewController
{
    if (!(self = [super init])) return nil;
    
        //BLOGPOST???:
    UIToolbar *toolbar = [UIToolbar new];
    UIView *superView = superViewController.view;
    [superView addSubview:toolbar];
    
    toolbar.tintColor = [UIColor clearColor];
    toolbar.backgroundColor = [UIColor clearColor];
    
    [toolbar removeConstraints:toolbar.constraints];
    toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    
    [toolbar.topAnchor constraintEqualToAnchor:superViewController.topLayoutGuide.topAnchor].active       = YES;
    [toolbar.bottomAnchor constraintEqualToAnchor:superViewController.topLayoutGuide.bottomAnchor].active = YES;
    [toolbar.centerXAnchor constraintEqualToAnchor:superViewController.view.centerXAnchor].active         = YES;
    [toolbar.widthAnchor constraintEqualToAnchor:superViewController.view.widthAnchor].active             = YES;
        //remember to call this in viewDidLoad!
    
    return self;
}

@end
