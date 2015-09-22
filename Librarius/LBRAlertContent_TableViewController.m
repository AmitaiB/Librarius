//
//  LBRAlertContent_TableViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 9/21/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBRAlertContent_TableViewController.h"
#import "LBRAlertContent_TableViewCell.h"
#import "LBRParsedVolume.h"
#import <UIImageView+AFNetworking.h>

@interface LBRAlertContent_TableViewController ()

@property (nonatomic, strong) NSArray *sourceData;
@property (nonatomic, strong) LBRAlertContent_TableViewCell *prototypeCell;

@end

@implementation LBRAlertContent_TableViewController

static NSString * const reuseIdentifier = @"Cell";

#pragma mark -
#pragma mark === Accessors ===
#pragma mark -

-(NSArray *)sourceData {
    if (!_sourceData) {
        _sourceData = [NSArray arrayWithObject:self.volumeToConfirm];
    }
    return _sourceData;
}

-(LBRAlertContent_TableViewCell *)prototypeCell {
    if (!_prototypeCell) {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    }
    return _prototypeCell;
}


#pragma mark -
#pragma mark === View Life Cycle ===
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)didChangePreferredContentSize:(NSNotification *)notification {
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark === <UITableViewDataSource> ===
#pragma mark -

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sourceData.count;
        //    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
        // Configure the cell
    [self configureCell:cell forRowAtIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[LBRAlertContent_TableViewCell class]]) {
        LBRParsedVolume *volume = self.sourceData[indexPath.row];
        LBRAlertContent_TableViewCell *confirmationCell = (LBRAlertContent_TableViewCell *)cell;

        
        NSString *fullTitle = volume.title;
        if (volume.subtitle.length) {
            fullTitle = [NSString stringWithFormat:@"%@: %@", volume.title, volume.subtitle];
        }
        NSString *byline = [NSString stringWithFormat:@"\nby %@ (%@: %@)", volume.author, [self yearFromDate:volume.published], volume.publisher];
        
        confirmationCell.titleLabel.text = [fullTitle stringByAppendingString:byline];
    }
    
    NSURL *url = [NSURL URLWithString:self.volumeToConfirm.cover_art_large];
    
    [cell.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder"]];
}



-(NSString*)yearFromDate:(NSDate*)date {
    NSCalendar *calendar    = [NSCalendar currentCalendar];
    NSInteger yearComponent = [calendar component:NSCalendarUnitYear fromDate:date];
    return [@(yearComponent) stringValue];
}


#pragma mark
#pragma mark <UICollectionViewDelegate>



@end
