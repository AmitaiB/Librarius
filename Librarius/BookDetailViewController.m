//
//  BookDetailViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/25/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import "BookDetailViewController.h"
#import "Volume.h"
#import <iAd/iAd.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface BookDetailViewController ()
@property (nonatomic, strong) NSArray *bookDetailsTypes;
@property (nonatomic, strong) NSArray *bookDetails;
@property (weak, nonatomic) IBOutlet UILabel *titleHeader;
@property (weak, nonatomic) IBOutlet UITableView *detailsTableView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)doneButtonTapped:(id)sender;

@end

@implementation BookDetailViewController

static NSString * const bookDetailsCellID = @"bookDetailsCellID";

#pragma mark - Managing the detail item


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.canDisplayBannerAds = YES;
    [self setTitleText];
    self.bookDetailsTypes = @[@"author", @"pub. date", @"genre"];
    self.bookDetails = @[self.displayVolume.author,
                         self.displayVolume.published,
                         self.displayVolume.mainCategory];
[self.imageView setImageWithURL:[NSURL URLWithString:self.displayVolume.cover_art_large] placeholderImage:[UIImage imageNamed:@"placeholder"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonTapped:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark = Helper methods

-(void)setTitleText
{
    self.titleHeader.text = self.displayVolume.title;
    if (self.displayVolume.subtitle) {
        self.titleHeader.text = [NSString stringWithFormat:@"%@: %@", self.displayVolume.title, self.displayVolume.subtitle];
    }
}

#pragma mark - === UITableView DataSource ===

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.bookDetails.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bookDetailsCellID forIndexPath:indexPath];
    
    cell.detailTextLabel.text = self.bookDetailsTypes[indexPath.row];
    cell.textLabel.text       = self.bookDetails[indexPath.row];
    
    return cell;
}


#pragma mark - === UITableView Delegate ===

@end
