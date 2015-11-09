//
//  LBR_LibrarySelection_TableViewCell.m
//  Librarius
//
//  Created by Amitai Blickstein on 11/9/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBR_LibrarySelection_TableViewCell.h"

@implementation LBR_LibrarySelection_TableViewCell

static NSString * const collectionViewCellReuseID = @"collectionViewCellReuseID";

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.itemSize = CGSizeMake(44, 44);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[LBR_LibrarySelection_CollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:collectionViewCellReuseID];
    self.collectionView.backgroundColor = [UIColor purpleColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.contentView addSubview:self.collectionView];
    
    
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
