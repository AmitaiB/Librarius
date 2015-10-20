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
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(30, 20, 200, 40)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:self.boldFontName size:20.0f];
    label.textColor = self.onColor;
    
    label.text = (section == 0) ? @"Account Settings" : @"User Information";
    
    [headerView addSubview:label];
    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingsCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell1" forIndexPath:indexPath];
    
    NSString *title = self.settingTitles[indexPath.row];
    NSString *element = self.settingsElements[indexPath.row];
    
    cell.settingTitle.text = title;
    
    if ([element isEqualToString:@"Switch"])
    {
        RCSwitchOnOff *cellSwitch = [self createSwitch];
        [cell addSubview:cellSwitch];
    }
    else if ([element isEqualToString:@"Segment"])
    {
        UISegmentedControl *control = [self createSegmentedControlWithItems:@[@"YES", @"NO", @"ALL"]];
        [cell addSubview:control];
    }
    return cell;
}

-(RCSwitchOnOff *)createSwitch
{
    FlatTheme *theme = [FlatTheme new];
    theme.switchOnBackground = [Utils drawImageOfSize:CGSizeMake(70, 30) andColor:self.onColor];
    theme.switchOffBackground = [Utils drawImageOfSize:CGSizeMake(70, 30) andColor:self.offColor];
    theme.switchThumb = [Utils drawImageOfSize:CGSizeMake(30, 29) andColor:[UIColor colorWithWhite:0.7f alpha:1.0f]];
    theme.switchTextOffColor = [UIColor whiteColor];
    theme.switchTextOnColor = [UIColor whiteColor];
    theme.switchFont = [UIFont fontWithName:self.boldFontName size:12.0f];
    
    RCSwitchOnOff *settingSwitch = [[RCSwitchOnOff alloc] initWithFrame:CGRectMake(230, 15, 70, 30) andTheme:theme];
    return settingSwitch;
}

-(UISegmentedControl *)createSegmentedControlWithItems:(NSArray *)items
{
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
    
    segmentedControl.frame = CGRectMake(150, 15, 150, 30);
    segmentedControl.selectedSegmentIndex = 0;
    return segmentedControl;
}

-(IBAction)dismissView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


    //TODO: implement this
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



@end
