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
    BOOL thereAreMoreBooksToShelve;
    
    for (NSUInteger idx = 0; idx < booksArray.count; idx++) {
        
        book                 = booksArray[idx];
        thickness            = book.thickness.floatValue? book.thickness.floatValue : kDefaultBookThickness;
        currentXPosition_cm  += thickness;
        currentShelfHasRoomForBook = currentXPosition_cm < self.width_cm;
        thereAreMoreBooksToShelve  = idx < booksArray.count - 1;
        
        
            //"Continue" = 'Shelve' the current book, then pick up the next book and repeat.
            ///!!!: Need more conditions: 1) No more books, 2) no more room on this shelf 2b) No more room on any shelf 3) Perfect fit...
        if (currentShelfHasRoomForBook &&
            thereAreMoreBooksToShelve)
            continue;
        else
        {
                //Include all the books up *until* this one --> a shelf.
                //It's 'idx' NOT 'idx + 1', because the current book does not fit on this shelf.
            NSRange rangeForCurrentShelf = NSMakeRange(idxOfFirstBookOnShelf, idx - idxOfFirstBookOnShelf);
            NSArray *thisShelf           = [booksArray subarrayWithRange:rangeForCurrentShelf];
            
            [self.mutableShelves addObject:thisShelf];

                ///!!!:Is this broken if we have run out of books, but it does this anyway...?
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
}


#pragma mark - Overriden methods

    //Return the nested NSArrays of the model:
-(NSString *)description
{
    NSMutableString __block *finalString = [NSMutableString string];
    [finalString appendFormat:@"\n\n<%@>", NSStringFromClass([self class])];
    
    if (self.shelves.count) {
        [self.shelves enumerateObjectsUsingBlock:^(NSArray * _Nonnull shelf, NSUInteger idx, BOOL * _Nonnull stop) {
            [finalString appendFormat:@"\n\nShelf #%@:\n", @(idx)];
            for (NSUInteger i = 0; i < shelf.count; i++) {
                [finalString appendFormat:@"\nVolume #%@ on shelf %@: \"%@\"", @(i), @(idx), ((Volume *)shelf[i]).title];
            }
        }];
        [finalString appendString:@"\n\n === END DESCRIPTION ===\n\n\n\n"];
    }
    else
        [finalString appendString:@"Empty bookcase."];
    
    return finalString;
}



@end
