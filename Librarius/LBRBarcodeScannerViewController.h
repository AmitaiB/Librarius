//
//  LBRBarcodeScannerViewController.h
//  Librarius
//
//  Created by Amitai Blickstein on 8/23/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBRBarcodeScannerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *uniqueCodes;


@end

