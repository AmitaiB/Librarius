//
//  LBRPresentVolumesTableViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 9/1/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//
#define DBLG NSLog(@"<%@:%@:line %d, reporting!>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
#define kCustomRowCount 5

#import "LBRSelectVolumeTableViewController.h"
#import "UIImage+FromURL.h"
//#import "LBRDataStore.h"
#import <UIKit+AFNetworking.h>


@interface LBRSelectVolumeTableViewController ()

@end

@implementation LBRSelectVolumeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
        //Should have been populated in BarcodeScannerVC:
    self.dataManager = [LBRDataManager sharedDataManager];
    self.volumesToDisplay = self.dataManager.responseCollectionOfPotentialVolumeMatches;
    
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // If there's no data yet, return enough rows to look good and responsive.
    if (self.volumesToDisplay.items.count == 0) {
        return kCustomRowCount;
    }
    
        //With data, return enough to contain the data, but not too much.
    return MIN(self.volumesToDisplay.items.count, kCustomRowCount);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *volumeCellID = @"volumeCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:volumeCellID];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:volumeCellID];
    }
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"volumeCellID" forIndexPath:indexPath];
    
    
    
    // Configure the cell...
    /**
     *  To 'spelunk' a GTLVolumes collection, note its "items" array.
     someGTLVolumesCollection.items[i]
     Each element is a GTLVolume.
     someGTLVolume.volumeInfo.title
     */
        //!!! Stuck here!
    GTLBooksVolume *thisRowsVolume = self.volumesToDisplay[indexPath.row];
    cell.textLabel.text = thisRowsVolume.volumeInfo.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@", thisRowsVolume.volumeInfo.authors[0]];
    
    NSString *imageURL = thisRowsVolume.volumeInfo.imageLinks.smallThumbnail;
    cell.imageView.image = [UIImage imageWithContentsOfURLString:imageURL];
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        //Selected a book on the confirmTVC popover...
    GTLBooksVolume *selectedVolume = self.volumesToDisplay[indexPath.row];
    [self.dataManager addGTLVolumeToCurrentLibrary:selectedVolume andSaveContext:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
      DBLG
    }];
}


//#pragma mark - Table view delegate
///**
// *  This is the method to modify when copying this VC code to use for other presentations of GTLBooksVolume objects.
// *
// *  @param tableView GTLVolumes collection of GTLVolume objects
// *  @param indexPath The currently selected indexPath
// */
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    GTLBooksVolume *selectedVolume = self.volumes[indexPath.row];
//    
//        //Add the selected volume to your library.
//    [self saveGoogleVolumeToLibrary:selectedVolume];
//    
//}
//
//-(void)saveGoogleVolumeToLibrary:(GTLBooksVolume*)volumeToSave {
//    
//}

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
