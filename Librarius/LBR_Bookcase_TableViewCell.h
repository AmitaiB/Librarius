//
//  LBR_Bookcase_TableViewCell.h
//  Librarius
//
//  Created by Amitai Blickstein on 11/12/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Bookcase;
@class LBR_BookcaseModel;
@interface LBR_Bookcase_TableViewCell : UITableViewCell

@property (nonatomic, strong) LBR_BookcaseModel *bookcaseModel;
@property (nonatomic, strong) Bookcase *bookcase;
@property (nonatomic, strong) IBOutlet UITextField *editNameField;

@end
