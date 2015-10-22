//
//  LBRRecommendedBook_CollectionViewCell.m
//  Librarius
//
//  Created by Amitai Blickstein on 10/22/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBRRecommendedBook_CollectionViewCell.h"
#import <UIImageView+AFNetworking.h>

@implementation LBRRecommendedBook_CollectionViewCell

-(void)displayRandomRecommendation {
    NSUInteger randomIndex = arc4random() % self.recommendationsArray.count;
    NSString *randomRecURL = self.recommendationsArray[randomIndex];
    
    [self.imageView setImageWithURL:<#(nonnull NSURL *)#> placeholderImage:<#(nullable UIImage *)#>]
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
