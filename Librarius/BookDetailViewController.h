//
//  BookDetailViewController.h
//  Librarius
//
//  Created by Amitai Blickstein on 8/25/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Volume;
@interface BookDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) Volume *displayVolume;

@end

