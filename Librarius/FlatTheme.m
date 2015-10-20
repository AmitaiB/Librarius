//
//  FlatTheme.m
//  ADVFlatUI
//
//  Created by Tope on 05/06/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import "FlatTheme.h"
#import "Utils.h"

@implementation FlatTheme


+(void)styleNavigationBar:(UINavigationBar*)bar withFontName:(NSString*)navigationTitleFont andColor:(UIColor*)color{
    
    bar.barTintColor = color;
    bar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor],
                                NSFontAttributeName : [UIFont fontWithName:navigationTitleFont size:18.0f]};
    
}

+(void)styleSegmentedControlWithFontName:(NSString*)fontName andSelectedColor:(UIColor*)selectedColor andUnselectedColor:(UIColor*)unselectedColor andDidviderColor:(UIColor*)dividerColor{
    
    UIFont* font = [UIFont fontWithName:fontName size:13.0f];
    
    UIImage* segmentedBackground = [Utils drawImageOfSize:CGSizeMake(50, 30) andColor:unselectedColor];
    UIImage* segmentedSelectedBackground = [Utils drawImageOfSize:CGSizeMake(50, 30) andColor:selectedColor];
    UIImage* segmentedDividerImage = [Utils drawImageOfSize:CGSizeMake(1, 30) andColor:dividerColor];
    
    UISegmentedControl *segmentedAppearance = [UISegmentedControl appearance];
    [segmentedAppearance setBackgroundImage:segmentedBackground forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [segmentedAppearance setBackgroundImage:segmentedSelectedBackground forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    [segmentedAppearance setDividerImage:segmentedDividerImage forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    NSShadow *shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeMake(0.0f, 0.0f);

    [segmentedAppearance setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 [UIColor lightGrayColor], NSForegroundColorAttributeName,
                                                 font, NSFontAttributeName, shadow, NSShadowAttributeName,
                                                 nil] forState:UIControlStateNormal];
    
    
    [segmentedAppearance setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 [UIColor whiteColor], NSForegroundColorAttributeName,
                                                 font, NSFontAttributeName, shadow, NSShadowAttributeName,
                                                 nil] forState:UIControlStateSelected];
    
}


@end
