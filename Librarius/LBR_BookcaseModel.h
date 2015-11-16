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
#import "Volume.h"

@class Bookcase;

@interface LBR_BookcaseModel : NSObject

@property (nonatomic, assign, readonly) CGFloat width_cm;
@property (nonatomic, assign) NSUInteger shelvesCount;
@property (nonatomic, strong) NSArray<NSArray *> *shelves;
@property (nonatomic, strong) NSArray<Volume  *> *unshelvedRemainder;
@property (nonatomic) BOOL isFull;
@property (nonatomic, assign) CGFloat percentFull;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray <Volume *> *booksArray;


-(instancetype)initWithWidth:(CGFloat)width shelvesCount:(NSUInteger)shelvesCount;
-(instancetype)initWithBookcaseObject:(Bookcase *)bookcaseObject;


-(void)shelveBooks:(NSArray <Volume *> *)booksArray;

@end
