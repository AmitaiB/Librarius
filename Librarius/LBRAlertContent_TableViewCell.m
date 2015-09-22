//
//  LBRAlertContent_TableViewCell.m
//  Librarius
//
//  Created by Amitai Blickstein on 9/21/15.
// Thanks to http://derpturkey.com/autosize-uitableviewcell-height-programmatically/ !!
//

#import "LBRAlertContent_TableViewCell.h"

@implementation LBRAlertContent_TableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (!self) {
        return nil;
    }
    
    self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.textLabel.numberOfLines = 0;
    [self configureViewsForAutoLayout:@[self.textLabel, self.coverArtImageView]];
    NSDictionary *viewsDictionary = @{@"imageView" : self.coverArtImageView,
                                      @"textLabel" : self.textLabel
                                      };
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[imageView]-[textLabel]-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary]];

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[imageView]-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary]];

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[textLabel]-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary]];

    return self;
}

-(void)configureViewsForAutoLayout:(NSArray*)views {
    for (UIView* view in views) {
        [view removeConstraints:view.constraints];
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
        //Make sure the contentView does a layout pass here so that its subviews have their
        // frames set, which we need to use to set the prefferedMaxLayoutWidth below.
    self.textLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.textLabel.frame);
}


@end
