//
//  LBRAlertContent_TableViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 9/21/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBRAlertContent_TableViewController.h"

@interface LBRAlertContent_TableViewController ()

@end

@implementation LBRAlertContent_TableViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register cell classes
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark
#pragma mark <UITableViewDataSource>

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
        // Configure the cell
    
    return cell;
}


#pragma mark
#pragma mark <UICollectionViewDelegate>



@end
