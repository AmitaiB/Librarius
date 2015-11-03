//
//  BookDetailViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/25/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

    //Models
#import "Volume.h"

    //Controllers
#import "BookDetailViewController.h"

    //Frameworks
#import <iAd/iAd.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIView+ConfigureForAutoLayout.h"

    //Pods
#import <AMRatingControl.h>
#import "UIColor+FlatUI.h"
#import "UIColor+ABBColors.h"

@interface BookDetailViewController ()
@property (nonatomic, strong) NSArray *detailCategories;
@property (nonatomic, strong) NSArray *detailsArray;

@property (weak, nonatomic) IBOutlet UITableView *detailsTableView;
@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) AMRatingControl *simpleRatingControl;

- (IBAction)doneButtonTapped:(id)sender;

@end

@implementation BookDetailViewController

static NSString * const bookDetailsCellID = @"bookDetailsCellID";

#pragma mark - Managing the detail item


-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.canDisplayBannerAds = YES;
    
    
        //???: Why doesn't this display the title?
    self.title =[NSString stringWithFormat:@"%@ - Details", self.displayVolume.title];
//    UINavigationItem *titleItem = [[UINavigationItem alloc] initWithTitle:
    
//    UINavigationBar *navBar = [UINavigationBar new];
//    [navBar pushNavigationItem:titleItem animated:NO];
//    UINavigationController *navController = [UINavigationController alloc] initWithNavigationBarClass:<#(nullable Class)#> toolbarClass:<#(nullable Class)#>
    
    
//    [self.navigationController.navigationBar pushNavigationItem:titleItem animated:NO];
//    
//    self.navigationItem.titleView.backgroundColor = [UIColor blackColor];
    self.detailCategories = @[@"Author", @"Publication Date", @"Genre", @"Rating"];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    NSString *dateString = [dateFormatter stringFromDate:self.displayVolume.published];
    
    self.detailsArray = @[self.displayVolume.author ? self.displayVolume.author : @"No Title Found",
                          dateString ? dateString : @"No Date Found",
                          self.displayVolume.mainCategory ? self.displayVolume.mainCategory : @"No Genre Found",
                          [self.displayVolume.rating stringValue] ? [self.displayVolume.rating stringValue] : @"N/A",
                          self.displayVolume.publDescription ? self.displayVolume.publDescription : @"No Description Found"
                          ];
    
    self.descriptionTextView.text = [self.detailsArray lastObject];
//    author      = self.detailsArray[0];
//    date        = self.detailsArray[1];
//    genre       = self.detailsArray[2];
//    rating      = self.detailsArray[3];
//    description = self.detailsArray[4];
//    
//    self.detailsDictionary = @{self.detailsDictionary[0] : author,
//                               self.detailsDictionary[1] : date,
//                               self.detailsDictionary[2] : genre,
//                               self.detailsDictionary[3] : rating,
//                               @"description"            : description
//                               };
    
    [self.imageView setImageWithURL:[NSURL URLWithString:self.displayVolume.cover_art_large] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    [self.detailsTableView sizeToFit];
//    [self.detailsTableView sizeToFit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - == Constraints ==
-(void)autolayoutSubviews
{
    [UIView configureViewsForAutolayout:@[self.imageView, self.detailsTableView, self.descriptionTextView]];
    
        //ImageView
    [self.imageView.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor constant:8].active = YES;
    
    
}

#pragma mark - === IBActions ===
    //???: Isn't this now an unwind segue via storyboard??
- (IBAction)doneButtonTapped:(id)sender {
    [self dismissSelf];
}

#pragma mark - Helper methods

-(void)dismissSelf
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - === UITableView DataSource ===

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.detailCategories.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bookDetailsCellID forIndexPath:indexPath];

    if ([self.detailCategories[indexPath.row] isEqualToString:@"Rating"])
    {
        self.simpleRatingControl = [[AMRatingControl alloc] initWithLocation:CGPointMake(8, 8) emptyColor:[UIColor asbestosColor] solidColor:[UIColor sunflowerColor] andMaxRating:5];
        [cell.contentView addSubview:self.simpleRatingControl];
        cell.detailTextLabel.text = nil;
        cell.textLabel.text = nil;
    }
    else
    {
        NSString *category = self.detailCategories[indexPath.row];
        NSString *detail = self.detailsArray[indexPath.row];
        cell.detailTextLabel.text = category;
        cell.textLabel.text = detail ? detail : nil;
    }
    
        //    NSString *string =  self.bookDetails[indexPath.row];
//    if ([string class] == [NSString class]) {
//        cell.textLabel.text       = string;
//    }
    
    
    return cell;
}


#pragma mark - === UITableView Delegate ===


@end
