//
//  LBRBookshelfDecorationView.m
//  Librarius
//
//  Created by Amitai Blickstein on 10/11/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBRBookshelfDecorationView.h"
#import <QuartzCore/QuartzCore.h>

const NSString *kLBRBookshelfDecorationViewKind = @"LBRBookshelfDecorationView";

@implementation LBRBookshelfDecorationView

-(instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame])) return nil;
    
        //Initialization code
    [self setBackgroundColor:[UIColor whiteColor]];
    
    return self;
}

-(void)drawRect:(CGRect)rect {
        //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
        //// Color Declarations
    UIColor *strokeColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    UIColor *fillColor2 = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
    
        //// Shadow Declarations
    UIColor *shadow = strokeColor;
    CGSize shadowOffset = CGSizeMake(0.1, 0.1);
    CGFloat shadowBlurRadius = 5;
    
        //// Frames
    CGRect frame = CGRectMake(0, 0, 320, 25);
    
        //// Bezier Drawing
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    CGFloat minX = CGRectGetMinX(frame);
    CGFloat minY = CGRectGetMinY(frame);
    [bezierPath moveToPoint:CGPointMake(minX + 3.5, minY + 16.5)];
    [bezierPath addLineToPoint:CGPointMake(minX + 13.8, minY + 8.5)];
    [bezierPath addLineToPoint:CGPointMake(minX + 303.73, minY + 8.5)];
    [bezierPath addLineToPoint:CGPointMake(minX + 315.5, minY + 16.5)];
    [bezierPath addLineToPoint:CGPointMake(minX + 3.5, minY + 16.5)];
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

+(NSString *)kind {
    return (NSString*)kLBRBookshelfDecorationViewKind;
}


@end
