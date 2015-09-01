//
//  SecondViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/23/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//
#define DBLG NSLog(@"%@ reporting!", NSStringFromSelector(_cmd));

#import "LBRBarcodeScannerViewController.h"
#import <MTBBarcodeScanner.h>
#import "LBRDataManager.h"
#import "LBRGoogleGTLClient.h"

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

@property (nonatomic) BOOL isScanning;
@property (nonatomic) BOOL isNotScanning;


@end

@implementation LBRBarcodeScannerViewController

#pragma mark - Constant Strings

static NSString * const barcodeCellReuseID = @"barcodeCellReuseID";


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeProgrammaticProperties];
    
}

-(void)initializeProgrammaticProperties {
    self.dataManager = [LBRDataManager sharedDataManager];
    self.isScanning = NO;
    if (!self.scanner) {
        self.scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:self.scannerView];
    }
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

- (IBAction)confirmChoicesButtonTapped:(id)sender {
    [self getVolumesFromBarcodeData];
}
    
#pragma mark - Scanning

-(void)stopScanning {
    [self.scanner stopScanning];
    self.isScanning = NO;
    [self.startScanningButton setTitle:@"Start Scanning" forState:UIControlStateNormal];
    [self.startScanningButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    self.startScanningButton.backgroundColor = [UIColor cyanColor];
}

-(void)startScanning {
    self.isScanning = YES;
    [self.startScanningButton setTitle:@"Stop Scanning" forState:UIControlStateSelected];
    [self.startScanningButton setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
    self.startScanningButton.backgroundColor = [UIColor redColor];
    NSMutableArray *uniqueCodes = [NSMutableArray new];
    [self.scanner startScanningWithResultBlock:^(NSArray *codes) {
        for (AVMetadataMachineReadableCodeObject *code in codes) {
            if ([uniqueCodes indexOfObject:code.stringValue] == NSNotFound) {
                [uniqueCodes addObject:code.stringValue];
                NSLog(@"Found unique code: %@", code.stringValue);
                [self.dataManager.uniqueCodes addObject:code.stringValue];
                
//                Update the tableview
                [self.uniqueBarcodesTableView reloadData];
                [self scrollToBottomCell];
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
    cell.textLabel.text = [NSString stringWithFormat:@"#%lu⎞ %@", indexPath.row + 1, self.dataManager.uniqueCodes[indexPath.row]];
    return cell;
}

#pragma mark - Helper methods

-(void)scrollToBottomCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataManager.uniqueCodes.count - 1 inSection:0];
    [self.uniqueBarcodesTableView scrollToRowAtIndexPath:indexPath
                                        atScrollPosition:UITableViewScrollPositionTop
                                                animated:YES];
}

#pragma mark - GoogleClient

-(void)getVolumesFromBarcodeData {
    
    /**
     *  First, we test one barcode...
     */
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [self.uniqueBarcodesTableView cellForRowAtIndexPath:indexPath];
    NSString *scannedISBN = cell.textLabel.text;
    
    LBRGoogleGTLClient *googleClient = [LBRGoogleGTLClient sharedGoogleGTLClient];
    GTLQueryBooks *barcodeQuery = [GTLQueryBooks queryForVolumesListWithQ:scannedISBN];
    GTLServiceTicket *ticket = [googleClient.service executeQuery:barcodeQuery completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        if (error) {
            NSLog(@"Error in barcodeQuery execution: %@", error.localizedDescription);
        } else {
                //success!
        }
    }];
    
}


/*
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
