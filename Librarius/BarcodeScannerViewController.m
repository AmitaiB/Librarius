//
//  SecondViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/23/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "BarcodeScannerViewController.h"
#import <MTBBarcodeScanner.h>

@interface BarcodeScannerViewController ()
- (IBAction)scanOneButtonTapped:(id)sender;
- (IBAction)scanContinuouslyButtonTapped:(id)sender;
- (IBAction)cameraButtonTapped:(id)sender;

@end

@implementation BarcodeScannerViewController {
    MTBBarcodeScanner *scanner;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:self.view];
    
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
                
                [scanner stopScanning];
            }];
        } else {
                //The user denied access to the camera
            NSLog(@"The user denied access to the camera...?");
        }
    }];
    
    
}

- (IBAction)scanContinuouslyButtonTapped:(id)sender {
    NSMutableArray *uniqueCodes = [NSMutableArray new];
    [scanner startScanningWithResultBlock:^(NSArray *codes) {
        for (AVMetadataMachineReadableCodeObject *code in codes) {
            if ([uniqueCodes indexOfObject:code.stringValue] == NSNotFound) {
                [uniqueCodes addObject:code.stringValue];
                NSLog(@"Found unique code: %@", code.stringValue);
            }
        }
    }];
}

- (IBAction)cameraButtonTapped:(id)sender {
    [scanner flipCamera];
}
@end
