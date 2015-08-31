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
- (IBAction)startScanningButtonTapped:(id)sender;
- (IBAction)cameraButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *scannerView;
@property (nonatomic) BOOL isScanning;
@property (weak, nonatomic) IBOutlet UIButton *startScanningButton;
@property (weak, nonatomic) IBOutlet UILabel *barcodeDisplayLabel;


@end

@implementation LBRBarcodeScannerViewController {
    MTBBarcodeScanner *scanner;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isScanning = NO;
    // Do any additional setup after loading the view, typically from a nib.
    scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:self.scannerView];
    self.barcodeDisplayLabel.text = @"";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

- (IBAction)startScanningButtonTapped:(id)sender {
    if (self.isScanning) {
        [scanner stopScanning];
        self.isScanning = NO;
        [self.startScanningButton setTitle:@"Start Scanning" forState:UIControlStateNormal];
        [self.startScanningButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        self.startScanningButton.backgroundColor = [UIColor cyanColor];
    } else {
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
}

- (IBAction)cameraButtonTapped:(id)sender {
    [scanner flipCamera];
}
    
-(void)displayBarcode:(NSString*)readout {
    self.barcodeDisplayLabel.text = readout;
}
    
@end
