//
//  LBR_Bookcase_TableViewCell.h
//  Librarius
//
//  Created by Amitai Blickstein on 11/12/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//
/**
 Abstract: The cell that represents a bookcase. The intent is that
 you can pass it a bookcase object, and it will know what to do.
 */


#import <UIKit/UIKit.h>

@class Bookcase;
@interface LBR_Bookcase_TableViewCell : UITableViewCell

@property (nonatomic, strong) Bookcase *bookcase;
@property (nonatomic, strong) IBOutlet UITextField *editNameField;

@end
