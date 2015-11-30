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
    UIImage *bookcaseCellIcon = [UIImage imageNamed:bookcase.volumes.count? @"bookshelf1" : @"empty-shelves"];
    [self.imageView setImage:bookcaseCellIcon];
    
        // TextLabels
    self.textLabel.text = bookcase.name ? bookcase.name : [NSString stringWithFormat:@"Bookcase #%@ (%@ x %@ cm)", bookcase.orderWhenListed, bookcase.shelves, bookcase.width];
    self.detailTextLabel.text = [NSString stringWithFormat:@"%.01f％ filled: %@ books", [self.bookcase percentFull], bookcase.volumes.count? @(bookcase.volumes.count) : @(-1)];
}

-(void)prepareForReuse
{
    self.textLabel.text = @"Bookcase Not Set";
    self.detailTextLabel.text = @"∞％ filled: 0 books";
}

@end
