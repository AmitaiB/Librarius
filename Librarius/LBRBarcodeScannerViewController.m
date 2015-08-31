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


@end

@implementation LBRBarcodeScannerViewController {
    MTBBarcodeScanner *scanner;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isScanning = NO;
    // Do any additional setup after loading the view, typically from a nib.
    if (!scanner) {
        scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:self.scannerView];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [scanner stopScanning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated {
    [scanner stopScanning];
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
    [scanner flipCamera];
}
    
-(void)displayBarcode:(NSString*)readout {
    self.barcodeDisplayLabel.text = readout;
}

-(void)stopScanning {
    [scanner stopScanning];
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
    [scanner startScanningWithResultBlock:^(NSArray *codes) {
        for (AVMetadataMachineReadableCodeObject *code in codes) {
            if ([uniqueCodes indexOfObject:code.stringValue] == NSNotFound) {
                [uniqueCodes addObject:code.stringValue];
                NSLog(@"Found unique code: %@", code.stringValue);
                [self displayBarcode:code.stringValue];
            }
        }
    }];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return <#(NSInteger)#>;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return <#nil#>;
}

@end
