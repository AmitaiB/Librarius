//
//  LBR_Bookcase_TableViewCell.m
//  Librarius
//
//  Created by Amitai Blickstein on 11/12/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBR_Bookcase_TableViewCell.h"
#import "Bookcase.h"

@implementation LBR_Bookcase_TableViewCell

-(void)setBookcase:(Bookcase *)bookcase
{
        // Property
    _bookcase = bookcase;

    
        // Image/Icon
    NSArray *bookcaseShelvesArray = bookcase.laidOutShelvesModel;
    UIImage *bookcaseCellIcon;
    
    
    if (bookcase.isFull.boolValue) {
        bookcaseCellIcon = [UIImage imageNamed:@"bookshelf1"];
    } else {
        bookcaseCellIcon = [UIImage imageNamed:bookcaseShelvesArray.count? @"half-filled-shelf1" : @"empty-shelves"];
    }
    [self.imageView setImage:bookcaseCellIcon];
    
        // TextLabels
//    NSString *trimmedBookcaseName = [bookcase.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    if (!bookcase.name || [trimmedBookcaseName isEqualToString:@""])
//    {
        self.textLabel.text = [NSString stringWithFormat:@"Bookcase #%@ (%@sh. x %@ cm)", bookcase.orderWhenListed, bookcase.shelves, bookcase.width];
//    }
    self.detailTextLabel.text = [NSString stringWithFormat:@"%.01f％ filled: %@ books", [self.bookcase percentFull], bookcase.volumes.count? @(bookcase.volumes.count) : @(0.0)];
}

-(void)prepareForReuse
{
    self.textLabel.text = @"Bookcase Not Set";
    self.detailTextLabel.text = @"∞％ filled: 0 books";
}

@end
