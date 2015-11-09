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

#import "LBRDataManager.h"

@interface BookDetailViewController ()
@property (nonatomic, strong) NSArray *detailCategories;
@property (nonatomic, strong) NSArray *detailsArray;

@property (weak, nonatomic) IBOutlet UITableView *detailsTableView;
@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) AMRatingControl *ratingCtrl;

//- (IBAction)doneButtonTapped:(id)sender;

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
    
    [self.imageView setImageWithURL:[NSURL URLWithString:self.displayVolume.cover_art_large] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    [self.detailsTableView sizeToFit];
}


#pragma mark - == Constraints ==
    //CLEAN: Not called! Not finished!!
-(void)autolayoutSubviews
{
    [UIView configureViewsForAutolayout:@[self.imageView, self.detailsTableView, self.descriptionTextView]];
    
        //ImageView
    [self.imageView.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor constant:8].active = YES;
    
        //DetailsTableView
        //[...]
    
        //DescriptionTextView
        //[...]
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
        self.ratingCtrl  = [[AMRatingControl alloc] initWithLocation:CGPointMake(8, 8) emptyColor:[UIColor silverColor] solidColor:[UIColor sunflowerColor] andMaxRating:5];
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"New"];
        [UIView configureViewsForAutolayout:@[self.ratingCtrl, cell.detailTextLabel]];
        [cell.contentView addSubview:self.ratingCtrl];
        [cell.detailTextLabel removeAllConstraints];
        UILabel *dtlb = cell.detailTextLabel;
        AMRatingControl *ratingCtrl = self.ratingCtrl;
        ratingCtrl.rating = [self.displayVolume.rating integerValue];
        
            //Now both detail label and ratings are ready to be placed.

        /*
            //Horizontal
        [dtlb.leadingAnchor constraintEqualToAnchor:dtlb.superview.leadingAnchor constant:8];
        [dtlb.trailingAnchor constraintEqualToAnchor:ratingCtrl.leadingAnchor constant:8];
        [ratingCtrl.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:8];
        
        */

        NSDictionary *views = @{@"ratingControl" : self.ratingCtrl,
                                @"detailLabel"   : cell.detailTextLabel
                                };

        [dtlb.heightAnchor constraintEqualToAnchor:ratingCtrl.heightAnchor multiplier:1].active = YES;
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[detailLabel]-[ratingControl]-|" options:0 metrics:nil views:views]];
        
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[ratingControl]-|" options:0 metrics:nil views:views]];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[detailLabel]-|" options:0 metrics:nil views:views]];
        
//        cell.detailTextLabel.text = self.detailCategories[indexPath.row];
        cell.detailTextLabel.text = @"Rating";
//        [cell.textLabel removeFromSuperview];
        cell.textLabel.text = nil;
        [cell updateConstraints];
        
        ratingCtrl.editingDidEndBlock = ^(NSUInteger rating)
        {
            self.displayVolume.rating = @(rating);
            [[LBRDataManager sharedDataManager] saveContext];
        };
    }
    else
    {
        NSString *category        = self.detailCategories[indexPath.row];
        NSString *detail          = self.detailsArray[indexPath.row];
        cell.textLabel.text       = detail ? detail : nil;
        cell.detailTextLabel.text = category;
    }
    
        //    NSString *string =  self.bookDetails[indexPath.row];
//    if ([string class] == [NSString class]) {
//        cell.textLabel.text       = string;
//    }
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - === UITableView Delegate ===


@end
