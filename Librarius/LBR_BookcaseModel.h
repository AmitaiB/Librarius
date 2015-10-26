//
//  LBR_BookcaseModel.h
//  Librarius
//
//  Created by Amitai Blickstein on 10/16/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

/**
 This model takes an array of book models (specifically, Volume class objects),
 and breaks them up into shelves (sub-arrays), based upon physical space remaining
 in the bookcase.
 
 */

#import <Foundation/Foundation.h>
@class Volume;
@interface LBR_BookcaseModel : NSObject

@property (nonatomic, strong) NSArray<NSArray *> *shelves;
@property (nonatomic, strong) NSArray<Volume  *> *unshelvedRemainder;
@property (nonatomic) BOOL isFull;


-(instancetype)initWithWidth:(CGFloat)width shelvesCount:(NSUInteger)numShelves;

-(void)shelveBooks:(NSArray <Volume *> *)booksArray;

@end
