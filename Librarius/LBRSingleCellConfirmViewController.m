//
//  LBRSingleCellConfirmViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 9/6/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBRSingleCellConfirmViewController.h"
#import "LBRParsedVolume.h"
#import <UIImageView+AFNetworking.h>

static NSString *cellReuseID = @"cellReuseID";
static NSString *placeholderCellID = @"placeholderCellID";

@interface VolumeDisplayCell : UITableViewCell
@end
@implementation VolumeDisplayCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
        // Ignores the style argument and forces the creation with style UITableViewCellStyleSubtitle.
    return [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellReuseID];
}


@end

@interface LBRSingleCellConfirmViewController ()

@end

@implementation LBRSingleCellConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NYAlertViewController *alertViewController = [[NYAlertViewController alloc] initWithNibName:nil bundle:nil];
    
        // Set a title and message
    alertViewController.title = NSLocalizedString(@"Put this book on your coffee table?", nil);
    alertViewController.message = NSLocalizedString(@"Chuck Norris ipsum. Word out.", nil);
    
    [alertViewController addAction:[NYAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil)
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(NYAlertAction *action) {
                                                              [self dismissViewControllerAnimated:YES completion:^{
                                                                      //Add to TableView and its datasource.
                                                              }];
                                                          }]];
    
    [alertViewController addAction:[NYAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(NYAlertAction *action) {
                                                              [self dismissViewControllerAnimated:YES completion:nil];
                                                          }]];
    
    alertViewController.title = NSLocalizedString(@"Content View", nil);
    alertViewController.message = NSLocalizedString(@"Set the alertViewContentView property to add custom views to the alert view", nil);
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    self.singleCellTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.singleCellTableView registerClass:[VolumeDisplayCell class] forCellReuseIdentifier:cellReuseID];
    [contentView addSubview:self.singleCellTableView];
    self.singleCellTableView.dataSource = self;
    NSDictionary *viewsDictionary = @{@"singleCellTableView" : self.singleCellTableView};
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[singleCellTableView(160)]|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[singleCellTableView]-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary]];
    
        // Customize appearance as desired
    alertViewController.buttonCornerRadius = 20.0f;
    alertViewController.view.tintColor = self.view.tintColor;
    
    alertViewController.titleFont = [UIFont fontWithName:@"AvenirNext-Bold" size:19.0f];
    alertViewController.messageFont = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
    alertViewController.buttonTitleFont = [UIFont fontWithName:@"AvenirNext-Regular" size:alertViewController.buttonTitleFont.pointSize];
    alertViewController.cancelButtonTitleFont = [UIFont fontWithName:@"AvenirNext-Medium" size:alertViewController.cancelButtonTitleFont.pointSize];
    
    alertViewController.swipeDismissalGestureEnabled = YES;
    alertViewController.backgroundTapDismissalGestureEnabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Datasource methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VolumeDisplayCell *cell = nil;
    
    if (self.sourceVolume) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellReuseID forIndexPath:indexPath];
        cell.textLabel.text = self.sourceVolume.title;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@ (%@)", self.sourceVolume.author, [self yearFromDate:self.sourceVolume.published]];
        NSURL *coverArtURL = [NSURL URLWithString:self.sourceVolume.cover_art];
        [cell.imageView setImageWithURL:coverArtURL placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }
    
    if (!self.sourceVolume) {
            // add a placeholder cell while waiting on the data.
        cell = [tableView dequeueReusableCellWithIdentifier:placeholderCellID forIndexPath:indexPath];
        
        cell.detailTextLabel.text = @"Loading…...";
    }
    return cell;
}

#pragma mark - Helper methods

-(NSString*)yearFromDate:(NSDate*)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger yearComponent = [calendar component:NSCalendarUnitYear fromDate:date];
    return [@(yearComponent) stringValue];
}


@end
