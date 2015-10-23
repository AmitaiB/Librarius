//
//  LBRShelf_DecorationView.m
//  Librarius
//
//  Created by Amitai Blickstein on 10/23/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBRShelf_DecorationView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+FlatUI.h"

const NSString *LBRDecorationViewKind = @"LBRDecorationViewKind";

@implementation LBRShelf_DecorationView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;
    
    self.backgroundColor = [UIColor cloudsColor];
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
        /// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
        /// Color Declarations
    UIColor *strokeColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    UIColor *fillColor2  = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
    
        /// Shadow Declarations
    UIColor *shadow = strokeColor;
    CGSize shadowOffset = CGSizeMake(0.1, 3.1);
    CGFloat shadowBlurRadius = 5;
    
        /// Frames
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 25);
    
        /// Bezier Drawing
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 3.5, CGRectGetMinY(frame) + 16.5)];
    [bezierPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 13.8, CGRectGetMinY(frame) + 8.5)];
    [bezierPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 3030.73, CGRectGetMinY(frame) + 8.5)];
    [bezierPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 315.5, CGRectGetMinY(frame) + 16.5)];
    [bezierPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 3.5, CGRectGetMinY(frame) + 16.5)];
    [bezierPath closePath];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
    [fillColor2 setFill];
    [bezierPath fill];
    CGContextRestoreGState(context);

    [fillColor2 setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
}

+(NSString *)kind
{
    return (NSString *)LBRDecorationViewKind;
}

@end
