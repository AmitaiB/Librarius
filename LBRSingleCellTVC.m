//
//  LBRSingleCellTVC.m
//  Librarius
//
//  Created by Amitai Blickstein on 9/7/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//
#import "LBRSingleCellTVC.h"
#import <NYAlertViewController.h>
#import <MapKit/MapKit.h>

@interface LBRSingleCellTVC ()

-(void)showMapViewAlertView;

@end

static NSString * const kTableViewCellReuseIdentifier = @"kTableViewCellReuseIdentifier";

@implementation LBRSingleCellTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kTableViewCellReuseIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCellReuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

-(void)showMapViewAlertView {
    NYAlertViewController *alertViewController = [[NYAlertViewController alloc] initWithNibName:nil bundle:nil];
    
    [alertViewController addAction:[NYAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(NYAlertAction *action) {
        NSLog(@"action: %@", action.description);
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [alertViewController addAction:[NYAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(NYAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    alertViewController.title = @"Content View";
    alertViewController.message = @"I do not know why this isn't working.";
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
//    UITableView *mapView = [[UITableView alloc] initWithFrame:CGRectZero];
    
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
    [mapView setTranslatesAutoresizingMaskIntoConstraints:NO];
    mapView.layer.cornerRadius = 6.0f;
    CLLocationCoordinate2D lowerManahattanCoords = CLLocationCoordinate2DMake(-43, 70);
    mapView.region = MKCoordinateRegionMakeWithDistance(lowerManahattanCoords, 1000.0f, 1000.0f);
    
    [contentView addSubview:mapView];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mapView(160)]|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:NSDictionaryOfVariableBindings(mapView)]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[mapView]-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:NSDictionaryOfVariableBindings(mapView)]];
    
    alertViewController.alertViewContentView = contentView;
    
    [self presentViewController:alertViewController animated:YES completion:nil];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
