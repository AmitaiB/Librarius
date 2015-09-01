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
#import <SCLAlertView.h>


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
static NSString * const volumeNib = @"volumePresentationView";


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
    UITableViewCell *cell  = [self.uniqueBarcodesTableView cellForRowAtIndexPath:indexPath];
    NSString *scannedISBN  = [cell.textLabel.text stringByReplacingCharactersInRange:NSMakeRange(0, 4) withString:@""];
    
    GTLQueryBooks *barcodeQuery      = [GTLQueryBooks queryForVolumesListWithQ:scannedISBN];
        // The Books API currently requires that search queries not have an
        // authorization header (b/4445456)
    barcodeQuery.shouldSkipAuthorization = YES;
    
        //Experimental - the format was taken from the web docs: https://developers.google.com/books/docs/v1/reference/volumes/list?hl=en
        // BTW, this limits the response to the information we desire, saving on system resources.
    barcodeQuery.fields = @"items(id, volumeInfo)";
    LBRGoogleGTLClient *googleClient = [LBRGoogleGTLClient sharedGoogleGTLClient];
    GTLServiceTicket *ticket         = [googleClient.service executeQuery:barcodeQuery
                                                        completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        if (error) {
            NSLog(@"Error in barcodeQuery execution: %@", error.localizedDescription);
        } else {
            [self confirmBookSelection:object];
        }
    }];
    
}

/**
 * Given a collection of possible matches, which one matches the user's
 * desired volume?
 *
 *  @param volumesMatchingQuery GTLBooksVolumes collection object, such
 * as the one returned by a GTLQueryBooks fetch request.
 */
-(void)confirmBookSelection:(GTLBooksVolumes*)volumesMatchingQuery {
    DBLG

    /**
     *  !!!Experimental
     */
    UINib *displayVolumesNib = [UINib nibWithNibName:volumeNib bundle:nil];
    NSArray *topLevelObjects = [displayVolumesNib instantiateWithOwner:nil options:nil];
    
    for (UIView *view in topLevelObjects) {
        [self.view addSubview:view];
    }
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
