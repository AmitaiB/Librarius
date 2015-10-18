//
//  LBR_BookcaseModel.m
//  Librarius
//
//  Created by Amitai Blickstein on 10/16/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBR_BookcaseModel.h"
#import "Volume.h"

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

-(void)shelveBooks:(NSArray *)booksArray {
    
/*
    For each book, add its thickness to the x-position. If that takes us over 
 the shelf width, then we have a complete shelf: so add the appropriate substring
 to "shelves". 
    If there are more shelves, model placing the current book as the first of a new
 shelf: reset the index to the current book's index, reset the x-position to the
 current book's thickness, and <continue>.
    else (no more shelf space) substring the rest to unshelvedRemainder, and break/stop.
 */
    NSMutableArray<NSArray *> __block *mutableShelves = [NSMutableArray new];
    CGFloat    __block currentXPosition_cm            = 0.0f;
    NSUInteger __block idxOfFirstBookOnShelf          = 0;
    
    [booksArray enumerateObjectsUsingBlock:^(Volume *book, NSUInteger idx, BOOL * _Nonnull stop)
    {
        currentXPosition_cm += [book.thickness floatValue];
    
        if (currentXPosition_cm > self.width_cm)
        {
                //Add all the books up until this one (exclusive, hence "-1") as a shelf.
            NSRange rangeForCurrentShelf = NSMakeRange(idxOfFirstBookOnShelf, (idx - 1) - idxOfFirstBookOnShelf);
            [mutableShelves addObject:[booksArray subarrayWithRange:rangeForCurrentShelf]];
            
                //If there are more shelves, then this book becomes the first on the next shelf.
            if (mutableShelves.count < self.shelvesCount)
            {
                currentXPosition_cm = [book.thickness floatValue];
                idxOfFirstBookOnShelf = idx;
            }
            else
            {
                    //No more room. Add all remaining books to the unshelved.
                NSUInteger numBooksRemaining = booksArray.count - (idx + offBy1);
                self.unshelvedRemainder = [booksArray subarrayWithRange:NSMakeRange(idx, numBooksRemaining)];
                *stop = YES;
            }
        }
    }];
    
    self.shelves = [mutableShelves copy];
}


#pragma mark - Helper methods

-(void)addBook:(Volume *)book toShelf:(NSUInteger)shelf {
    
}

@end
