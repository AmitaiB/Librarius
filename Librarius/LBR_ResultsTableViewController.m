//
//  LBR_ResultsTableViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 10/27/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "LBR_ResultsTableViewController.h"
#import "Volume.h"
#import "UITableViewCell+FlatUI.h"
#import "UIColor+FlatUI.h"

@interface LBR_ResultsTableViewController ()

@property (nonatomic, strong) UITableViewCell *cellPrototype;

@end

@implementation LBR_ResultsTableViewController

static NSString * const resultsCellReuseID = @"resultsCellReuseID";

-(void)loadView
{
//    self.cellPrototype = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:resultsCellReuseID];
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:resultsCellReuseID];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"%@ resigning firstResponder to save memory.", NSStringFromClass([self class]));
    [self resignFirstResponder];
    
    // Dispose of any resources that can be recreated.
}

#pragma mark - === TableView DataSource ===

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredBooks.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:resultsCellReuseID forIndexPath:indexPath];
    
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}


#pragma mark private delegate helpers
-(void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath*)indexPath
{
    Volume *volume = self.filteredBooks[indexPath.row];
    NSString *title         = volume.title;
    NSString *subtitle      = volume.subtitle;
    [self makeTitleCase:title];
    [self makeTitleCase:subtitle];
    NSString *formattedSubtitle = [@": " stringByAppendingString:subtitle];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@%@", title, subtitle ?  formattedSubtitle : @""];

    NSUInteger lastRowInSection = [self.tableView numberOfRowsInSection:0] - offBy1;
    
    UIRectCorner cornersToRound = (indexPath.row == lastRowInSection) ? UIRectCornerBottomLeft | UIRectCornerBottomRight : 0;

    [cell configureFlatCellWithColor:[UIColor asbestosColor] selectedColor:[UIColor cloudsColor] roundingCorners:cornersToRound];
    
    if (indexPath.row == 0 || indexPath.row == lastRowInSection) {
        [cell setCornerRadius:5];
    }
    else{
        [cell setCornerRadius:0];
    }
}

- (void)makeTitleCase:(NSString*)string {
    NSArray *words = [string componentsSeparatedByString:@" "];
    for (NSString __strong *word in words) {
        if ([@[@"the", @"and", @"a", @"of"] containsObject:word]) {
                // Do nothing, leave uncapitalized.
        } else {
            word = word.capitalizedString;
        }
    }
    string = [words componentsJoinedByString:@" "];
}
    /**
     The main tableview is the delegate, since there should be no difference between selecting the desired object's cell in the [main] tableview or search results.
     */
#pragma mark - === UITableView Delegate ===

@end
