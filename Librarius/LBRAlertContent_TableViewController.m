//
//  LBRAlertContent_TableViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 9/21/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//
/**
 Abstract: To be honest, I don't know WHAT I was thinking when I coded this.
 All I can tell, is that I made sure to do it the hard way. And I don't mean
 the "hard, skillful, clever way," but the "it doesn't have to be that hard" way.
 :/
 
 */


    //Controllers
#import "LBRAlertContent_TableViewController.h"

    //Views
#import "LBRAlertContent_TableViewCell.h"
#import <UIImageView+AFNetworking.h>

    //Models
#import "Volume.h"

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
    LBRAlertContent_TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
        // Configure the cell
    [self configureCell:cell forRowAtIndexPath:indexPath];
    return cell;
}

    //FIXME: This is not fixed yet!
- (void)configureCell:(LBRAlertContent_TableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Volume *volume = self.sourceData[indexPath.row];
    
    NSString *fullTitle = [volume fullTitle];
    NSString *byline = [volume byline];
    
    cell.titleLabel.text = [fullTitle stringByAppendingString:byline];
    
    NSURL *url = [NSURL URLWithString:self.volumeToConfirm.cover_art_large];
    
    [cell.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder"]];
}



-(NSString*)yearFromDate:(NSDate*)date {
    NSCalendar *calendar    = [NSCalendar currentCalendar];
    NSInteger yearComponent = [calendar component:NSCalendarUnitYear fromDate:date];
    return [@(yearComponent) stringValue];
}


#pragma mark -
#pragma mark === UICollectionViewDelegate ===
#pragma mark -

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self configureCell:self.prototypeCell forRowAtIndexPath:indexPath];
    
        // As in UseYourLoaf (blog): Need to set the width of the prototype cell to the width of
        //  the table view as this will change when the device is rotated.
    self.prototypeCell.bounds = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), CGRectGetHeight(self.prototypeCell.bounds));
    
    [self.prototypeCell layoutIfNeeded];
    
    CGSize size = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    return size.height+1;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}


@end
