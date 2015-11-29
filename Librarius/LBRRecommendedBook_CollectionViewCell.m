////
////  LBRRecommendedBook_CollectionViewCell.m
////  Librarius
////
////  Created by Amitai Blickstein on 10/22/15.
////  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
////
//
//#import "LBRRecommendedBook_CollectionViewCell.h"
//#import <UIImageView+AFNetworking.h>
//#import "LBRParsedVolume.h"
//
//@implementation LBRRecommendedBook_CollectionViewCell
//
//-(void)displayRandomRecommendation {
//    BOOL areNoRecommendations = !@(self.recommendationsArray.count).boolValue;
//    if (areNoRecommendations) return;
//    
//    if (self.imageView.image != nil) return;
//    
//    NSUInteger       randomIndex  = arc4random() % self.recommendationsArray.count;
//    LBRParsedVolume *randomVolume = self.recommendationsArray[randomIndex];
//    NSString  *randomRecURLString = randomVolume.cover_art_large;
//    NSURL           *randomRecURL = [NSURL URLWithString:randomRecURLString];
//
//    [self.imageView setImageWithURL:randomRecURL placeholderImage:[UIImage imageNamed:@"placeholder"]];
//    
//    self.selectedVolumeIdentifier = randomRecURLString;
//}
//
//@end
