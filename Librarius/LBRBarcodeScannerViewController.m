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

@interface LBRBarcodeScannerViewController ()
- (IBAction)scanOneButtonTapped:(id)sender;
- (IBAction)toggleScanningButtonTapped:(id)sender;
- (IBAction)cameraButtonTapped:(id)sender;
@property (nonatomic) BOOL isScanning;
@property (weak, nonatomic) IBOutlet UIView *scannerView;
@property (weak, nonatomic) IBOutlet UIButton *startScanningButton;
@property (weak, nonatomic) IBOutlet UITableView *uniqueBarcodesTableView;
@property (nonatomic, strong) NSMutableArray *uniqueCodes;
@property (nonatomic, strong) MTBBarcodeScanner *scanner;


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
    self.isScanning = NO;
    if (!self.scanner) {
        self.scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:self.scannerView];
    }
    if (!self.uniqueCodes) {
        self.uniqueCodes = [NSMutableArray new];
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

/*
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

- (IBAction)toggleScanningButtonTapped:(id)sender {
    if (self.isScanning) {[self stopScanning];}
    else                {[self startScanning];}
}

- (IBAction)cameraButtonTapped:(id)sender {
    [self.scanner flipCamera];
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
                [self.uniqueCodes addObject:code.stringValue];
                
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
    return self.uniqueCodes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:barcodeCellReuseID forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"#%lu⎞ %@", indexPath.row + 1, self.uniqueCodes[indexPath.row]];
    return cell;
}


-(void)scrollToBottomCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.uniqueCodes.count - 1 inSection:0];
    [self.uniqueBarcodesTableView scrollToRowAtIndexPath:indexPath
                                        atScrollPosition:UITableViewScrollPositionTop
                                                animated:YES];
}

@end
