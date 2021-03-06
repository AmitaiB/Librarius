//
//  FirstViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/23/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "API_TestViewController.h"
#import "LBRVolume.h"

@interface API_TestViewController ()

@end

@implementation API_TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self testVolumesQuery];
    
}

-(void)testVolumeRequest {
    LBRVolume *sherlockHolmes = [LBRVolume new];
    LBRGoogleAPIClient *googleApiClient = [LBRGoogleAPIClient new];
    [googleApiClient retrieveVolumeWithID:@"buc0AAAAMAAJ" withCompletion:^(NSDictionary * responseObject) {
        sherlockHolmes.volumeData = responseObject;
        NSLog([sherlockHolmes.volumeData description]);
    }];
}

-(void)testVolumesQuery {
    LBRVolume *dune = [LBRVolume new];
    LBRGoogleAPIClient *googleApiClient = [LBRGoogleAPIClient new];
    [googleApiClient retrieveVolumesWithQuery:@"1101658053" withCompletion:^(NSDictionary * responseObject) {
        NSArray *responseArray = responseObject[@"items"];
        dune.volumeData = [responseArray firstObject];
        NSLog(@"dune: %@", dune.title);
    }];
}

@end
