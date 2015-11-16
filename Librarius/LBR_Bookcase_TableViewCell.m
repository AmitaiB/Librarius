//
//  LBR_Bookcase_TableViewCell.m
//  Librarius
//
//  Created by Amitai Blickstein on 11/12/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBR_Bookcase_TableViewCell.h"
#import "Bookcase.h"
#import "LBR_BookcaseModel.h"

@implementation LBR_Bookcase_TableViewCell

//-(instancetype)initWithCoder:(NSCoder *)aDecoder
//{
//    if (!(self = [super initWithCoder:aDecoder])) return nil;
//        
//    return self;
//}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}

-(void)setBookcase:(Bookcase *)bookcase
{
    _bookcase = bookcase;
    
    [self.imageView setImage:[UIImage imageNamed:@"bookshelf1"]];
    self.textLabel.text = bookcase.name ? bookcase.name : [NSString stringWithFormat:@"Bookcase #%@ (%@ x %@ cm)", bookcase.orderWhenListed, bookcase.shelves, bookcase.width];
    self.detailTextLabel.text = [NSString stringWithFormat:@"%.01f％ filled: %@ books", [self.bookcase percentFull], bookcase.volumes.count? @(bookcase.volumes.count) : @(-1)];
}

@end
