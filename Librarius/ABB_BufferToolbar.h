//
//  ABB_BufferToolbar.h
//  Librarius
//
//  Created by Amitai Blickstein on 10/29/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ABB_BufferToolbar : UIToolbar

@property (nonatomic, weak) UIView *superView;

-initWithController:(UIViewController*)superViewController;

@end
