//
//  LBR_BookcaseModel.m
//  Librarius
//
//  Created by Amitai Blickstein on 10/16/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBR_BookcaseModel.h"
#import "LBRParsedVolume.h"

@interface LBR_BookcaseModel ()

@property (nonatomic, assign) NSUInteger shelvesCount;
@property (nonatomic, assign) CGFloat width_cm;

@end

@implementation LBR_BookcaseModel

-(instancetype)initWithWidth:(CGFloat)width shelvesCount:(NSUInteger)shelvesCount {
    if (!(self = [super init])) return nil;
    
    _shelvesCount = shelvesCount;
    _width_cm = width;
    
    return self;
}

-(instancetype)init {
    if (!(self = [super init])) return nil;
    return [self initWithWidth:58.0 shelvesCount:5];
}

-(NSArray *)shelveBooks:(NSArray *)booksArray {
    NSUInteger currentShelf = 0;
    CGFloat currentXPosition_cm = 0.0f;
    
        /*For each book,
         if there is room for it,
            add it to the current shelf,
         else
            if there is another shelf
                add it to the start of the next shelf
            else
                put this and the remaining books in the array into a new array, and return it.
         */
    for (LBRParsedVolume *book in booksArray) {
        if (self.width_cm - currentXPosition_cm > book.thickness) {
            <#statements#>
        }
        
        
    }
    
    
    
}

@end
