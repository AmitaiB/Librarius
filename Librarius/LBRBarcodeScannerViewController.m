//
//  SecondViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/23/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//
#define DBLG NSLog(@"%@ reporting!", NSStringFromSelector(_cmd));
#define kSpinnerFrameRect CGRectMake(0, 0, 40, 40)

#import <LGSemiModalNavViewController.h>
#import <MTBBarcodeScanner.h>
#import <MMMaterialDesignSpinner.h>

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
@property (nonatomic, strong) LBRGoogleGTLClient *googleClient;
@property (nonatomic, strong) GTLBooksVolumes *responseCollectionOfPotentialVolumeMatches;
@property (nonatomic, strong) LBRSelectVolumeTableViewController *confirmVolumeTVC;
@property (nonatomic, strong) MMMaterialDesignSpinner *spinnerView;


@property (nonatomic) BOOL isScanning;
@property (nonatomic) BOOL isNotScanning;


@end

@implementation LBRBarcodeScannerViewController

NSString * const barcodeAddedNotification = @"barcodeAddedNotification";

#pragma mark - Constant Strings

static NSString * const barcodeCellReuseID = @"barcodeCellReuseID";
static NSString * const volumeNib          = @"volumePresentationView";


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeProgrammaticProperties];
    
    [self generateTestDataIfNeeded];
    LBRDataManager *dataManager = [LBRDataManager sharedDataManager];
    NSLog(@"%@",[dataManager.currentLibrary.volumes description]);
    
}

-(void)initializeProgrammaticProperties {
    self.googleClient = [LBRGoogleGTLClient sharedGoogleGTLClient];
    /**
     *  CLEAN: May be implicitly NO, and can remove this line.
     */
    self.isScanning = NO;
    self.scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:self.scannerView];
    self.responseCollectionOfPotentialVolumeMatches = [GTLBooksVolumes new];
    self.uniqueCodes = [NSMutableArray new];
    
    /**
     The Material Design Spinnerview inits
    */
    self.spinnerView = [[MMMaterialDesignSpinner alloc] initWithFrame:kSpinnerFrameRect];
    self.spinnerView.lineWidth = 1.5f;
    self.spinnerView.tintColor = [UIColor cyanColor];
//    self.spinnerView.hidesWhenStopped = YES; ???Uncomment if this isn't the default.
    [self.view addSubview:self.spinnerView];
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
    LBRDataManager *dataManager = [LBRDataManager sharedDataManager];
    self.isScanning = YES;
    [self.startScanningButton setTitle:@"Stop Scanning" forState:UIControlStateSelected];
    [self.startScanningButton setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
    self.startScanningButton.backgroundColor = [UIColor redColor];

//Put everything in this, maybe?  [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success)...?
   
    [self.scanner startScanningWithResultBlock:^(NSArray *codes) {
        for (AVMetadataMachineReadableCodeObject *code in codes) {
                // If it's a new barcode, add it to the array.
            if ([self.uniqueCodes indexOfObject:code.stringValue] == NSNotFound) {
                [self.uniqueCodes addObject:code.stringValue];
                [self updateDataManagerWithNewBarcode];
                NSLog(@"Found unique code: %@", code.stringValue);
//                [self.scanner stopScanning];
                /**
                 *  These next lines were for when the TableView had barcodes. No longer.
                 */
//                Update the tableview
//                [self.uniqueBarcodesTableView reloadData];
//                [self scrollToBottomCell];
               
            } else {
                    //If code is not unique/already in the tableView, then scroll the tableView to it.
                [self scrollToTargetISBNCell:[self.uniqueCodes indexOfObject:code.stringValue]];
                NSLog(@"Barcode already in list/table.");
            }
        }
    }];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.uniqueCodes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:barcodeCellReuseID forIndexPath:indexPath];
    cell.textLabel.text = self.uniqueCodes[indexPath.row];
    return cell;
}

#pragma mark - Helper methods

-(void)scrollToBottomCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.uniqueCodes.count - 1 inSection:0];
    [self.uniqueBarcodesTableView scrollToRowAtIndexPath:indexPath
                                        atScrollPosition:UITableViewScrollPositionTop
                                                animated:YES];
}

-(void)scrollToTargetISBNCell:(NSUInteger)idxOfTarget {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.uniqueCodes.count - 1 inSection:0];
    [self.uniqueBarcodesTableView scrollToRowAtIndexPath:indexPath
                                        atScrollPosition:UITableViewScrollPositionTop
                                                animated:YES];
}


#pragma mark - GoogleClient


/**
 *  CLEAN: This should be DEPRECATED - Google Client gets the barcode from NSNotification!
 */
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
    LBRDataManager *dataManager = [LBRDataManager sharedDataManager];
    dataManager.responseCollectionOfPotentialVolumeMatches = self.googleClient.responseObject;
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

#pragma mark - Data Manager interface

-(void)generateTestDataIfNeeded {
    LBRDataManager *dataManager = [LBRDataManager sharedDataManager];
    [dataManager generateTestDataIfNeeded];
}

-(void)updateDataManagerWithNewBarcode {
    LBRDataManager *dataManager = [LBRDataManager sharedDataManager];
    if (!dataManager.uniqueCodes) {
        dataManager.uniqueCodes = [NSMutableArray new];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:barcodeAddedNotification object:dataManager.uniqueCodes];
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
