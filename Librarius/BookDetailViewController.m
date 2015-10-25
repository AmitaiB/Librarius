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

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.canDisplayBannerAds = YES;
    [self setTitleText];
    self.bookDetailsTypes = @[@"author", @"pub. date", @"genre"];
    if (self.displayVolume) {
        self.bookDetails = @[self.displayVolume.author,
                             self.displayVolume.published,
                             self.displayVolume.mainCategory];
        [self.imageView setImageWithURL:[NSURL URLWithString:self.displayVolume.cover_art_large] placeholderImage:[UIImage imageNamed:@"placeholder"]];

    }
    else
    {
        self.titleHeader.text = @"Error loading Volume!";
        self.canDisplayBannerAds = NO;
    }
    [self.detailsTableView sizeToFit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonTapped:(id)sender {
    [self dismissSelf];
}

-(void)dismissSelf
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

    //FIXME: Why doesn't this work?
-(void)addGestureDismissal
{
    UITapGestureRecognizer *tapToDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSelf)];
    [self.titleHeader addGestureRecognizer:tapToDismiss];
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
    NSString *string =  self.bookDetails[indexPath.row];
    if ([string class] == [NSString class]) {
        cell.textLabel.text       = string;
    }
    
    
    return cell;
}


#pragma mark - === UITableView Delegate ===


@end
