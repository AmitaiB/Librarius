//
//  SecondViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/23/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//
#define DBLG NSLog(@"%@ reporting!", NSStringFromSelector(_cmd));
#define set() [NSSet setWithArray:@[__VA_ARGS__]]


#import <LGSemiModalNavViewController.h>
#import <MTBBarcodeScanner.h>
#import <SCLAlertView.h>

#import "LBRBarcodeScannerViewController.h"
#import "LBRSelectVolumeTableViewController.h"
#import "LBRGoogleGTLClient.h"

#import "LBRDataManager.h"
#import "Library.h"
#import "Volume.h"


@interface LBRBarcodeScannerViewController ()
//- (IBAction)scanOneButtonTapped:(id)sender;
- (IBAction)toggleScanningButtonTapped:(id)sender;
- (IBAction)cameraButtonTapped:(id)sender;
- (IBAction)confirmChoicesButtonTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *confirmChoicesButton;
@property (weak, nonatomic) IBOutlet UIView *scannerView;
@property (weak, nonatomic) IBOutlet UIButton *startScanningButton;
@property (weak, nonatomic) IBOutlet UITableView *uniqueBarcodesTableView;
@property (nonatomic, strong) MTBBarcodeScanner *scanner;
@property (nonatomic, strong) LBRDataManager *dataManager;
@property (nonatomic, strong) LBRGoogleGTLClient *googleClient;
@property (nonatomic, strong) GTLBooksVolumes *responseCollectionOfPotentialVolumeMatches;
@property (nonatomic, strong) LBRSelectVolumeTableViewController *confirmVolumeTVC;

@property (nonatomic) BOOL isScanning;
@property (nonatomic) BOOL isNotScanning;


@end

@implementation LBRBarcodeScannerViewController

#pragma mark - Constant Strings

static NSString * const barcodeCellReuseID = @"barcodeCellReuseID";
static NSString * const volumeNib          = @"volumePresentationView";


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeProgrammaticProperties];
    
    [self.dataManager generateTestDataIfNeeded];
    NSLog(@"%@",[self.dataManager.currentLibrary.volumes description]);
    
}

-(void)initializeProgrammaticProperties {
    self.dataManager = [LBRDataManager sharedDataManager];
    self.googleClient = [LBRGoogleGTLClient sharedGoogleGTLClient];
    /**
     *  CLEAN: May be implicitly NO, and can remove this line.
     */
    self.isScanning = NO;
    self.scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:self.scannerView];
    self.responseCollectionOfPotentialVolumeMatches = [GTLBooksVolumes new];
    
    if (!self.dataManager.uniqueCodes) {
        self.dataManager.uniqueCodes = [NSMutableArray new];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self.scanner stopScanning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.scanner stopScanning];
    [super viewWillDisappear:animated];
}

#pragma mark - buttons

- (IBAction)toggleScanningButtonTapped:(id)sender {
        // I like how it reads, don't you?
    self.isNotScanning = !self.isScanning;
    
    if (self.isScanning) {
        [self stopScanning];}
    if (self.isNotScanning) {
        [self startScanning];}
}

- (IBAction)cameraButtonTapped:(id)sender {
    [self.scanner flipCamera];
}

    //And then, Magic!
- (IBAction)confirmChoicesButtonTapped:(id)sender {
    [self getVolumesFromBarcodeData];
}
    
#pragma mark - Scanning

/**
 *  Stop scanning, flip the button.
 */
-(void)stopScanning {
    self.isScanning = NO;
    [self.startScanningButton setTitle:@"Start Scanning" forState:UIControlStateNormal];
    [self.startScanningButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    self.startScanningButton.backgroundColor = [UIColor cyanColor];
    
    [self.scanner stopScanning];
}

/**
 *  Flip the button, start scanning, handle the completion.
 */
-(void)startScanning {
    self.isScanning = YES;
    [self.startScanningButton setTitle:@"Stop Scanning" forState:UIControlStateSelected];
    [self.startScanningButton setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
    self.startScanningButton.backgroundColor = [UIColor redColor];

//    [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success)
   
    [self.scanner startScanningWithResultBlock:^(NSArray *codes) {
        for (AVMetadataMachineReadableCodeObject *code in codes) {
                // If it's a new barcode, add it to the array.
            if ([self.dataManager.uniqueCodes indexOfObject:code.stringValue] == NSNotFound) {
                [self.dataManager.uniqueCodes addObject:code.stringValue];
                NSLog(@"Found unique code: %@", code.stringValue);
//                [self.scanner stopScanning];
//                Update the tableview
                [self.uniqueBarcodesTableView reloadData];
                [self scrollToBottomCell];
                /**
                 *  Start the spinner and pass the barcode string out and be done.
                 *
                 *  Pop-up: Add this book [thumbnail, title, author, date] to the batch? Yes: add it to the tableview, No: don't.
                 *  Then add the whole batch to CoreData.
                 */
            } else {
                    //If code is not unique/already in the tableView, then scroll the tableView to it.
                [self scrollToTargetISBNCell:[self.dataManager.uniqueCodes indexOfObject:code.stringValue]];
                NSLog(@"Barcode already in list/table.");
            }
        }
    }];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataManager.uniqueCodes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:barcodeCellReuseID forIndexPath:indexPath];
    cell.textLabel.text = self.dataManager.uniqueCodes[indexPath.row];
    return cell;
}

#pragma mark - Helper methods

-(void)scrollToBottomCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataManager.uniqueCodes.count - 1 inSection:0];
    [self.uniqueBarcodesTableView scrollToRowAtIndexPath:indexPath
                                        atScrollPosition:UITableViewScrollPositionTop
                                                animated:YES];
}

-(void)scrollToTargetISBNCell:(NSUInteger)idxOfTarget {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataManager.uniqueCodes.count - 1 inSection:0];
    [self.uniqueBarcodesTableView scrollToRowAtIndexPath:indexPath
                                        atScrollPosition:UITableViewScrollPositionTop
                                                animated:YES];
}


#pragma mark - GoogleClient

-(void)getVolumesFromBarcodeData {
    
    /**TODO: loop for all barcodes on the list. Loop, just increment the indexPath.row.
     *  First, we test one barcode...
     */
    
    /**
     *  TODO: This all needs to be in the GoogleGTLClient!!!
     */
        // Capture the ISBN for the [first] cell
        // TODO: any given cell.
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell  = [self.uniqueBarcodesTableView cellForRowAtIndexPath:indexPath];
    NSString *ISBNforCell  = cell.textLabel.text;

    /**
     *  CLEAN: Possibly refactor to not need the ticket...
     */
        // For the request for the googleClient:
    [self.googleClient queryForVolumeWithISBN:ISBNforCell returnTicket:YES];
//    GTLServiceTicket *responseTicket = self.googleClient.mostRecentTicket;

    /**
     *  Weak Point: will id-casting work? Only if it actually returns the right thing.
     */
    self.dataManager.responseCollectionOfPotentialVolumeMatches = self.googleClient.responseObject;
            //            UIPopoverController
        self.confirmVolumeTVC = [LBRSelectVolumeTableViewController new];
        [self presentVolumesSemiModally];
    
        //Google's example code had this line, not sure why...yet.
//    responseTicket = nil;
}

-(void)presentVolumesSemiModally {
    if (self.confirmVolumeTVC) {
            //This is the nav controller
        LGSemiModalNavViewController *semiModal = [[LGSemiModalNavViewController alloc]initWithRootViewController:self.confirmVolumeTVC];
            //Make sure to set a height on the view controller here.
        semiModal.view.frame = CGRectMake(0, 0, self.view.frame.size.width * 0.95, self.view.frame.size.height * 0.65);
        
            //Selected customization properties, see more in the header of the LGSemiModalNavViewController
        semiModal.backgroundShadeColor = [UIColor blackColor];
        semiModal.animationSpeed = 0.35f;
        semiModal.tapDismissEnabled = YES;
        semiModal.backgroundShadeAlpha = 0.4;
        semiModal.scaleTransform = CGAffineTransformMakeScale(.94, .94);
        
        [self presentViewController:semiModal animated:YES completion:nil];
    }
}


/* CLEAN
 * This snippet will scan once, then stop.
 
 - (IBAction)scanOneButtonTapped:(id)sender {
 [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success) {
 if (success) {
 [scanner startScanningWithResultBlock:^(NSArray *codes) {
 AVMetadataMachineReadableCodeObject *code = [codes firstObject];
 NSLog(@"Found barcode: %@", code.stringValue);
 [self displayBarcode:code.stringValue];
 [scanner stopScanning];
 }];
 } else {
 //The user denied access to the camera
 NSLog(@"The user denied access to the camera...?");
 }
 }];
 }
 */

@end
