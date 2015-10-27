//
//  LBR_BookcaseModel.m
//  Librarius
//
//  Created by Amitai Blickstein on 10/16/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#define kDefaultBookThickness 2.50f

#import "LBR_BookcaseModel.h"
#import "Volume.h"

@interface LBR_BookcaseModel ()

@property (nonatomic, assign) NSUInteger shelvesCount;
@property (nonatomic, assign) CGFloat width_cm;
@property (nonatomic, strong) NSMutableArray <NSArray*> *mutableShelves;
@end


@implementation LBR_BookcaseModel

-(instancetype)initWithWidth:(CGFloat)width shelvesCount:(NSUInteger)shelvesCount {
    if (!(self = [super init])) return nil;
    
    _shelvesCount = shelvesCount;
    _width_cm     = width;
    _isFull       = NO;
    
    return self;
}

-(instancetype)init {
    if (!(self = [super init])) return nil;
    
    return [self initWithWidth:kDefaultBookcaseWidth_cm shelvesCount:kDefaultBookcaseShelvesCount];
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
    self.mutableShelves              = [NSMutableArray new];
    CGFloat    currentXPosition_cm   = 0.0f;
    NSUInteger idxOfFirstBookOnShelf = 0;
    Volume *book;
    CGFloat thickness;
    BOOL currentShelfHasRoomForBook;
    
    for (NSUInteger idx = 0; idx < booksArray.count; idx++) {
        
        book                 = booksArray[idx];
        thickness            = book.thickness.floatValue? book.thickness.floatValue : kDefaultBookThickness;
        currentXPosition_cm  += thickness;
        currentShelfHasRoomForBook = currentXPosition_cm < self.width_cm;
        
        if (currentShelfHasRoomForBook)
            continue; //Then go to the next book...
        else
        {
                //Include all the books up *until* this one --> a shelf.
                //It's 'idx' NOT 'idx + 1', because the current book does not fit on this shelf.
            NSRange rangeForCurrentShelf = NSMakeRange(idxOfFirstBookOnShelf, idx - idxOfFirstBookOnShelf);
            NSArray *thisShelf = [booksArray subarrayWithRange:rangeForCurrentShelf];
            
            [self.mutableShelves addObject:thisShelf];

                //If there are more shelves, then this book becomes the first on the next shelf.
            BOOL nextShelfExistsAndIsEmpty = self.mutableShelves.count < self.shelvesCount;
            if (nextShelfExistsAndIsEmpty)
            {
                currentXPosition_cm   = thickness;
                idxOfFirstBookOnShelf = idx;
            }
            else //No more empty shelves. Add all remaining books to the unshelved.
            {
                self.isFull = YES;
                NSUInteger numBooksRemaining = booksArray.count - (idx + offBy1); //+1 b/c it's the nth book
                self.unshelvedRemainder = [booksArray subarrayWithRange:NSMakeRange(idx, numBooksRemaining)];
            }
        }
    }
    
    self.shelves = [self.mutableShelves copy];
    
//    NSLog(@"self.shelves[0] = %@\nself.shelves[1] = %@\nself.shelves[2] = %@\nself.shelves[3] = %@\nself.shelves[4] = %@\n", self.shelves[0], self.shelves[1], self.shelves[2], self.shelves[3], self.shelves[4]);
}


#pragma mark - Helper methods


@end
