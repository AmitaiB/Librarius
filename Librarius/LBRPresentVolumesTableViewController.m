//
//  LBRPresentVolumesTableViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 9/1/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBRPresentVolumesTableViewController.h"
#import "UIImage+FromURL.h"
#import "LBRDataStore.h"

@interface LBRPresentVolumesTableViewController ()

@end

@implementation LBRPresentVolumesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return MIN([self.volumes.totalItems integerValue], 5);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"volumeCellID" forIndexPath:indexPath];
    
    // Configure the cell...
    /**
     *  To 'spelunk' a GTLVolumes collection, note its "items" array.
     someGTLVolumesCollection.items[i]
     Each element is a GTLVolume.
     someGTLVolume.volumeInfo.title
     */
    GTLBooksVolume *thisRowsVolume = self.volumes[indexPath.row];
    cell.textLabel.text = thisRowsVolume.volumeInfo.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@", thisRowsVolume.volumeInfo.authors[0]];
    
    NSString *imageURL = thisRowsVolume.volumeInfo.imageLinks.smallThumbnail;
    cell.imageView.image = [UIImage imageWithContentsOfURLString:imageURL];
    
    return cell;
}

#pragma mark - Table view delegate
/**
 *  This is the method to modify when copying this VC code to use for other presentations of GTLBooksVolume objects.
 *
 *  @param tableView GTLVolumes collection of GTLVolume objects
 *  @param indexPath The currently selected indexPath
 */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GTLBooksVolume *selectedVolume = self.volumes[indexPath.row];
    
        //Add the selected volume to your library.
    [self saveGoogleVolumeToLibrary:selectedVolume];
    
}

-(void)saveGoogleVolumeToLibrary:(GTLBooksVolume*)volumeToSave {
    
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
