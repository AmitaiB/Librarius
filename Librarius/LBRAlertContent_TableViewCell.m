//
//  LBRAlertContent_TableViewCell.m
//  Librarius
//
//  Created by Amitai Blickstein on 9/21/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBRAlertContent_TableViewCell.h"

@implementation LBRAlertContent_TableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (!self) {
        return nil;
    }
    
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
