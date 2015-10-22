//
//  LBRRecommendedBook_CollectionViewCell.h
//  Librarius
//
//  Created by Amitai Blickstein on 10/22/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBRShelvedBook_CollectionViewCell.h"

@interface LBRRecommendedBook_CollectionViewCell : LBRShelvedBook_CollectionViewCell

@property (nonatomic, strong) NSArray *recommendationsArray;

-(void)displayRandomRecommendation;

@end
