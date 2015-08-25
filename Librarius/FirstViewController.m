//
//  FirstViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/23/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "FirstViewController.h"
#import "LBRVolume.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    LBRVolume *sherlockHolmes = [LBRVolume new];
    LBRGoogleAPIClient *googleApiClient = [LBRGoogleAPIClient new];
    [googleApiClient retrieveVolumeWithID:@"buc0AAAAMAAJ" withCompletion:^(NSDictionary * responseObject) {
        sherlockHolmes.volumeData = responseObject;
        NSLog([sherlockHolmes.volumeData description]);
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
