//
//  Bookcase.m
//  Librarius
//
//  Created by Amitai Blickstein on 10/29/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//


#import "Bookcase.h"
#import "Library.h"
#import "Volume.h"
#import "NSObject+ABBNumberUtils.h"

@implementation Bookcase

// Insert code here to add functionality to your managed object subclass
+(NSString *)entityName
{
    return @"Bookcase";
}

+(instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
}

+(instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context withDefaultValues:(BOOL)defaultValueChoice
{
    Bookcase *bookcase = [Bookcase insertNewObjectIntoContext:context];
    
    if (defaultValueChoice) {
        bookcase.orderWhenListed = @0;
        bookcase.dateCreated     = [NSDate date];
        bookcase.dateModified    = [bookcase.dateCreated copy];
        bookcase.shelves         = @(kDefaultBookcaseShelvesCount);
        bookcase.width           = @(kDefaultBookcaseWidth_cm);
        bookcase.name            = [NSString stringWithFormat:@"BookcaseID #%f", [NSObject randomFloatBetweenNumber:10000 andNumber:99999]];
        bookcase.isFull          = @NO;
    }
    return bookcase;
}

/*
-(void)setOrderWhenListed:(NSNumber *)orderWhenListed
{
    self.orderWhenListed = orderWhenListed;
    
        //This is called less frequently, and saves performance.
    NSString *trimmedName = [self.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!self.name || [trimmedName isEqualToString:@""])
    {
        self.name = [NSString stringWithFormat:@"Bookcase #%@", orderWhenListed];
//         = [NSString stringWithFormat:@"Bookcase #%@ (%@ x %@ cm)", bookcase.orderWhenListed, bookcase.shelves, bookcase.width];

    }
    
}
*/

-(CGFloat)percentFull
{
    CGFloat totalShelfSpace = self.width.floatValue * self.shelves.floatValue;
    __block CGFloat occupiedShelfSpace = 0;
    [self.volumes enumerateObjectsUsingBlock:^(Volume * _Nonnull volume, BOOL * _Nonnull stop) {
        occupiedShelfSpace += volume.thickness? volume.thickness.floatValue : 2.5f;
    }];
    
    return occupiedShelfSpace / totalShelfSpace * 100;
}


    ///This needs to return a dictionary to replace these two properties...OR, make a Value Transformer.
    ///@property (nonatomic, strong) NSArray<NSArray *> *shelves;
    ///@property (nonatomic, strong) NSArray<Volume  *> *unshelvedRemainder;
-(NSArray *)fillShelvesWithBooks:(NSArray<Volume *> *)booksArray
{
    if ([booksArray isEqual:[NSNull null]]) {
        return @[];
    }
    
    NSArray<Volume  *> *unshelvedRemainder   = [NSArray array];
    NSArray<NSArray *> *internalShelvesArray = [NSArray array];
    /**
     For each book, add its thickness to the x-position. If that takes us over
     the shelf width, then we have a complete shelf: so add the appropriate substring
     to "shelves".
     If there are more shelves, model placing the current book as the first of a new
     shelf: reset the index to the current book's index, reset the x-position to the
     current book's thickness, and <continue>.
     else (no more shelf space) substring the rest to unshelvedRemainder, and break/stop.
     */
    NSMutableArray *mutableShelves   = [NSMutableArray new];
    CGFloat    currentXPosition_cm   = 0.0f;
    NSUInteger idxOfFirstBookOnShelf = 0;
    Volume *book;
    CGFloat thickness;
    BOOL currentShelfHasRoomForBook;
    BOOL thereAreMoreBooksToShelve;
    
//    if (booksArray) 
        for (NSInteger idx = 0; idx < booksArray.count; idx++) {
            book                 = booksArray[idx];
            thickness            = book.thickness.floatValue? book.thickness.floatValue : kDefaultBookThickness;
            currentXPosition_cm  += thickness;
            currentShelfHasRoomForBook = currentXPosition_cm < self.width.floatValue;
            thereAreMoreBooksToShelve  = idx < booksArray.count - 1;
            
            
                //"Continue" = 'Shelve' the current book, then pick up the next book and repeat.
                ///!!!: Need more conditions: 1) No more books, 2) no more room on this shelf 2b) No more room on any shelf 3) Perfect fit...
                ///UPDATE: Initializing
            if (thereAreMoreBooksToShelve && currentShelfHasRoomForBook)
            {
                continue; //continue to the next book, and shelve it where it belongs.
            }
            else
            {
                    //Include all the books up *until* this one --> a shelf.
                    //It's 'idx' NOT 'idx + 1', because the current book does not fit on this shelf.
                NSRange rangeForCurrentShelf = NSMakeRange(idxOfFirstBookOnShelf, idx - idxOfFirstBookOnShelf);
                NSArray *thisShelf           = [booksArray subarrayWithRange:rangeForCurrentShelf];
                
                [mutableShelves addObject:thisShelf];
                    ///!!!:Is this broken if we have run out of books, but it does this anyway...?
                    //If there are more shelves, then this book becomes the first on the next shelf.
                BOOL nextShelfExistsAndIsEmpty = mutableShelves.count < self.shelves.integerValue;
                if (nextShelfExistsAndIsEmpty)
                {
                    currentXPosition_cm   = thickness;
                    idxOfFirstBookOnShelf = idx;
                }
                else //No more empty shelves. Add all remaining books to the unshelved.
                {
                    self.isFull = @YES;
                    NSUInteger numBooksRemaining = booksArray.count - (idx + offBy1); //+1 b/c it's the nth book
                    unshelvedRemainder = [booksArray subarrayWithRange:NSMakeRange(idx, numBooksRemaining)];
                }
            }
                //Either way, this book has been added to the shelf.
            book.bookcase = self;
        }
    internalShelvesArray = [NSArray arrayWithArray:mutableShelves];
    
    self.laidOutShelvesModel = [internalShelvesArray copy];
    return unshelvedRemainder.count? [unshelvedRemainder copy] : [NSNull null];
}


@end
