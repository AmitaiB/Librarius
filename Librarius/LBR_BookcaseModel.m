//
//  LBR_BookcaseModel.m
//  Librarius
//
//  Created by Amitai Blickstein on 10/16/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#define kDefaultBookThickness 2.5f

#import "LBR_BookcaseModel.h"
#import "Volume.h"

#define DBLG NSLog(@"<%@:%@:line %d, mutableShelves.count = %lu>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__, (unsigned long)mutableShelves.count);

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

-(void)shelveBooks:(NSArray<Volume *> *)booksArray {
    
/**
    For each book, add its thickness to the x-position. If that takes us over 
 the shelf width, then we have a complete shelf: so add the appropriate substring
 to "shelves". 
    If there are more shelves, model placing the current book as the first of a new
 shelf: reset the index to the current book's index, reset the x-position to the
 current book's thickness, and <continue>.
    else (no more shelf space) substring the rest to unshelvedRemainder, and break/stop.
 */
    NSMutableArray<NSArray *> *mutableShelves = [NSMutableArray array];
    CGFloat    currentXPosition_cm            = 0.0f;
    NSUInteger idxOfFirstBookOnShelf          = 0;
    Volume *book;
    DBLG
    NSLog(@"BooksArray.count: %lu", booksArray.count);
    
    for (NSUInteger idx = 0; idx < booksArray.count; idx++) {
        book = booksArray[idx];
        CGFloat thickness = [self bookThicknessOrDefault:book.thickness];
        currentXPosition_cm += thickness? thickness : 2.5f;
    DBLG
        
        
        
        if (currentXPosition_cm > self.width_cm)
        {
                //Add all the books up until this one (exclusive, hence "-1") as a shelf.
            NSRange rangeForCurrentShelf = NSMakeRange(idxOfFirstBookOnShelf, (idx - 1) - idxOfFirstBookOnShelf);
            NSArray *temp = [booksArray subarrayWithRange:rangeForCurrentShelf];
            DBLG
            [mutableShelves addObject:temp];
            DBLG
            
                //If there are more shelves, then this book becomes the first on the next shelf.
            BOOL nextShelfExistsAndIsEmpty = mutableShelves.count < self.shelvesCount;

            
            DBLG
            if (nextShelfExistsAndIsEmpty)
            { //CLEAN: just call 'thickness' again (D.R.Y.)
                currentXPosition_cm = [self bookThicknessOrDefault:book.thickness];
                idxOfFirstBookOnShelf = idx;
                DBLG
            }
            else
            {
                DBLG
                    //No more empty shelves. Add all remaining books to the unshelved.
                NSUInteger numBooksRemaining = booksArray.count - (idx + offBy1);
                self.unshelvedRemainder = [booksArray subarrayWithRange:NSMakeRange(idx, numBooksRemaining)];
            } DBLG
        }DBLG
    }
    DBLG
    self.shelves = [mutableShelves copy];
    DBLG
}


#pragma mark - Helper methods

-(CGFloat)bookThicknessOrDefault:(NSNumber*)thickness {
    CGFloat downloadedThicknessValue = [thickness floatValue];
    return downloadedThicknessValue? downloadedThicknessValue : kDefaultBookThickness;
}

@end
