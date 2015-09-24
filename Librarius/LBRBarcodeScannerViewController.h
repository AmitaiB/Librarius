//
//  LBRBarcodeScannerViewController.h
//  Librarius
//
//  Created by Amitai Blickstein on 8/23/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LBRParsedVolume;
@interface LBRBarcodeScannerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *uniqueCodes;
@property (nonatomic, strong) LBRParsedVolume *volumeToConfirm;

@end

