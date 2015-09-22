//
//  LBRAlertContent_TableViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 9/21/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBRAlertContent_TableViewController.h"
#import "LBRAlertContent_TableViewCell.h"

@interface LBRAlertContent_TableViewController ()

@end

@implementation LBRAlertContent_TableViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register cell classes
    [self.tableView registerClass:[LBRAlertContent_TableViewCell class] forCellReuseIdentifier:reuseIdentifier];
    
        // Do any additional setup after loading the view.
    self.tableView.estimatedRowHeight = 60;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
}

- (NSString *)getText {
    return @"This is some long text that should wrap. It is multiple long sentences that may or may not have spelling and grammatical errors. Yep it should wrap quite nicely and serve as a nice example!";
}


#pragma mark
#pragma mark <UITableViewDataSource>

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
        // Configure the cell
    cell.textLabel.text = [self getText];
    
    
    return cell;
}


#pragma mark
#pragma mark <UICollectionViewDelegate>



@end
