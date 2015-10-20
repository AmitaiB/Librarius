//
//  LBRSettingsTableViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/24/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//
#define DBLG NSLog(@"<%@:%@:line %d, reporting!>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);


#import "LBRSettingsTableViewController.h"
#import <Google/SignIn.h>

#import "UIColor+ABBColors.h"

    //ADVFlatUI
#import "SettingsCell1.h"
#import "Utils.h"
#import "RCSwitchOnOff.h"
#import "FlatTheme.h"

@interface LBRSettingsTableViewController ()

@property (nonatomic, strong) NSArray *settingTitles;
@property (nonatomic, strong) NSArray *settingsElements;
@property (nonatomic, strong) NSString *boldFontName;
@property (nonatomic, strong) UIColor *onColor;
@property (nonatomic, strong) UIColor *offColor;
@property (nonatomic, strong) UIColor *dividerColor;
@end


@implementation LBRSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.boldFontName = @"Avenir-Black";
    
    self.onColor      = [UIColor bleuDeFranceColor];
    self.offColor     = [UIColor darkJungleGreenColor];
    self.dividerColor = [UIColor colorWithWhite:0.1 alpha:1.0f];

    [FlatTheme styleNavigationBar:self.navigationController.navigationBar withFontName:self.boldFontName andColor:[UIColor outerSpaceColor]];
    [FlatTheme styleSegmentedControlWithFontName:self.boldFontName andSelectedColor:self.onColor andUnselectedColor:self.offColor andDidviderColor:self.dividerColor];
    
    self.title = @"Settings";

    self.tableView.backgroundColor = [UIColor glitterColor];
    self.tableView.separatorColor = [UIColor clearColor];
    
    self.settingTitles = @[@"Bluetooth", @"Cloud backup", @"Show Offers", @"Streaming", @"Manage Accounts"];
    self.settingsElements = @[@"None", @"Switch", @"Segment", @"None", @"None"];
    
        //Clever technique!!!
    UIButton *menuButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 20)];
    [menuButton setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(dismissView:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    self.navigationItem.leftBarButtonItem = menuItem;
    
        //TODO: Switch to Autolayout
    UIImageView *searchView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search"]];
    searchView.frame = CGRectMake(0, 0, 20, 20);
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithCustomView:searchView];
    self.navigationItem.rightBarButtonItem = searchItem;
    

//==============
    [self.settingsGroups addObject:@"GoogleSignout from Librarius"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    headerView.backgroundColor = [UIColor darkLavalColor];
    

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    cell.textLabel.text = @"CONFIGURE CELLS";
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self disconnect];
        DBLG
    }
}

- (void)disconnect {
    [[GIDSignIn sharedInstance] signOut];
    DBLG
}

- (void)didDisconnectWithError:(NSError *)error {
    if (error) {
        NSLog(@"Received error %@", error);
    } else {
            // The user is signed out and disconnected.
            // Clean up user data as specified by the Google+ terms.
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
