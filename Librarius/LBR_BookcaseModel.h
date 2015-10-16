//
//  LBR_BookcaseModel.h
//  Librarius
//
//  Created by Amitai Blickstein on 10/16/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LBR_BookcaseModel : NSObject

@property (nonatomic, strong) NSArray<NSArray *> *shelves;

-(instancetype)initWithWidth:(CGFloat)width shelvesCount:(NSUInteger)numShelves;

-(NSArray*)shelveBooks:(NSArray *)booksArray;

@end