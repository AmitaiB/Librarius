//
//  LBRAlertContent_TableViewCell.m
//  Librarius
//
//  Created by Amitai Blickstein on 9/21/15.
// Thanks to http://derpturkey.com/autosize-uitableviewcell-height-programmatically/ !!
//

#import "LBRAlertContent_TableViewCell.h"

@implementation LBRAlertContent_TableViewCell


-(void)layoutSubviews {
    [super layoutSubviews];
        //Make sure the contentView does a layout pass here so that its subviews have their
        // frames set, which we need to use to set the prefferedMaxLayoutWidth below.
    [self.contentView layoutIfNeeded];
    self.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabel.frame);
}


@end
