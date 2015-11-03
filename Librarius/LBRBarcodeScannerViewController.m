//
//  LBRBarcodeScannerViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/23/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//
#define kSpinnerFrameRect CGRectMake(0, 0, 40, 40)
#define kAppIconSize 48

    //Frameworks
#import <AVFoundation/AVFoundation.h>
#import <iAd/iAd.h>

    //Network Monitoring
#import "Reachability.h"

    //Data
#import "LBRConstants.h"
#import "LBRGoogleGTLClient.h"
#import "LBRDataManager.h"

    //Models
#import "Library.h"
#import "Volume.h"
#import "LBRParsedVolume.h"
#import <LARSTorch.h>

    //Views
#import "UIView+ConfigureForAutoLayout.h"
#import <UIImageView+AFNetworking.h>
#import "LBRBatchScanScrollView.h"
#import <MTBBarcodeScanner.h>
#import "FlatUI+Categories.h"

    //Controllers
#import "LBRBarcodeScannerViewController.h"
#import "LBRAlertContent_TableViewController.h"
#import <NYAlertViewController.h>




@interface LBRBarcodeScannerViewController ()

- (IBAction)toggleScanningButtonTapped:(id)sender;
- (IBAction)lightToggleButtonTapped:(id)sender;
- (IBAction)saveScannedBooksToCoreDataButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *lightToggleButton;
@property (weak, nonatomic) IBOutlet UIButton *saveScannedBooksToCoreDataButton;

@property (weak, nonatomic) IBOutlet UIView *mainContentView;
@property (weak, nonatomic) IBOutlet UIView *scannerView;
@property (weak, nonatomic) IBOutlet UIButton *toggleScanningButton;
@property (nonatomic, strong) NSMutableArray *unsavedVolumes;
@property (nonatomic, strong) MTBBarcodeScanner *scanner;
@property (nonatomic, strong) LBRGoogleGTLClient *googleClient;

@property (nonatomic, strong) NSArray *booksArray;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic) BOOL isConfigured;

@property (nonatomic) BOOL isScanning;

@property (weak, nonatomic) IBOutlet LBRBatchScanScrollView *unsavedVolumesScrollView;




@end


@implementation LBRBarcodeScannerViewController


static NSString * const barcodeCellReuseID = @"barcodeCellReuseID";
static NSString * const volumeNib          = @"volumePresentationView";

#pragma mark - === Lifecycle ===

- (void)viewDidLoad {
    [super viewDidLoad];
    [self generateTestDataIfNeeded];

    if (!self.isConfigured) {
        [self configureProgrammaticProperties];}
    
    self.canDisplayBannerAds = YES;
    
}

-(void)configureProgrammaticProperties {
        // Initializations
    self.googleClient    = [LBRGoogleGTLClient sharedGoogleGTLClient];
    self.uniqueCodes     = [NSMutableArray  new];
    self.volumeToConfirm = [LBRParsedVolume new];
    [self initializeScannerView];
    [self configureUnsavedVolumesScrollView];
//    [self initializeSpinner];
    
        // Hidden Things
    self.lightToggleButton.hidden = YES;
    
        // UI Elements
    self.lightToggleButton.layer.cornerRadius                = 5.0f;
    self.lightToggleButton.backgroundColor                   = [UIColor sunflowerColor];
    self.toggleScanningButton.backgroundColor                = [UIColor belizeHoleColor];
    self.toggleScanningButton.tintColor                      = [UIColor turquoiseColor];
    self.toggleScanningButton.layer.cornerRadius             = 5.0f;
    self.saveScannedBooksToCoreDataButton.layer.cornerRadius = 5.0f;
    self.saveScannedBooksToCoreDataButton.clipsToBounds      = YES;
    self.saveScannedBooksToCoreDataButton.backgroundColor    = [UIColor wetAsphaltColor];
    
    [self.mainContentView bringSubviewToFront:self.unsavedVolumesScrollView];
    
        // So we don't repeat ourselves.
    self.isConfigured = YES;
}
-(void)configureUnsavedVolumesScrollView {
    self.unsavedVolumesScrollView.delegate                     = self;
    self.unsavedVolumesScrollView.pagingEnabled                = NO;
    self.unsavedVolumesScrollView.alwaysBounceVertical         = YES;
    self.unsavedVolumesScrollView.alwaysBounceHorizontal       = NO;
    self.unsavedVolumesScrollView.showsVerticalScrollIndicator = NO;
    self.unsavedVolumesScrollView.contentInset                 = UIEdgeInsetsMake(500, 0, 0, 0);
}


-(void)initializeScannerView {
    self.scanner         = [[MTBBarcodeScanner alloc] initWithMetadataObjectTypes:@[AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeEAN13Code] previewView:self.scannerView];
        ///Alternative: self.scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:self.scannerView];

    self.scannerView.layer.cornerRadius = 5.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self stopScanningOps];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self stopScanningOps];
    [super viewWillDisappear:animated];
}


#pragma mark - buttons

- (IBAction)toggleScanningButtonTapped:(id)sender {
    if (self.isScanning) {
        [self stopScanningOps];}
    else {
        if ([self deviceIsNetConnected])
            [self startScanningOps];
        else
            [self alertUserNoInternetConnection];
    }
}

-(void)alertUserNoInternetConnection
{
    UIAlertController *noInternetAlertController = [UIAlertController alertControllerWithTitle:@"No Internet Detected" message:@"An internet connection is required to look up book data and images." preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:noInternetAlertController animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }];
}

- (IBAction)lightToggleButtonTapped:(id)sender {
    LARSTorch *torch = [LARSTorch sharedTorch];
    if ([torch isTorchOn]) {
        [torch setTorchState:LARSTorchStateOff];
    } else {
        [torch setTorchState:LARSTorchStateOn];
    }
        DBLG
}

- (IBAction)saveScannedBooksToCoreDataButtonTapped:(id)sender
{
    LBRDataManager *dataManager = [LBRDataManager sharedDataManager];
    [dataManager saveParsedVolumesToEitherSaveOrDiscardToPersistentStore];
    [dataManager logCurrentLibrary];
}

    //Supposed to check the DataStore to see if this volume exists in storage yet, or not.
    //FIXME: Doesn't work.
-(BOOL)isNewUniqueObject:(LBRParsedVolume *)volumeToCheck
{
    NSArray *booksArray = self.fetchedResultsController.fetchedObjects;
    
    NSUInteger indexOfMatchingISBN = [booksArray indexOfObjectPassingTest:^BOOL(Volume *book, NSUInteger idx, BOOL * _Nonnull stop) {
        return ([book.isbn isEqualToString:volumeToCheck.isbn]);
    }];
    BOOL isUniqueISBN = (indexOfMatchingISBN == NSNotFound);
    
    return isUniqueISBN;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    return [[LBRDataManager sharedDataManager]
            preconfiguredLBRFetchedResultsController:self];
}

#pragma mark - === Network Connectivity ===

-(BOOL)deviceIsNetConnected
{
id internetReachability = [Reachability reachabilityForInternetConnection];
    [internetReachability startNotifier];
    NetworkStatus netStatus = [internetReachability currentReachabilityStatus];
    switch (netStatus) {
        case NotReachable:
            return NO;
            break;
        case ReachableViaWWAN:
            return YES;
            break;
        case ReachableViaWiFi:
            return YES;
            break;
        default:
            return NO;
            break;
    }
}

#pragma mark - === Scanning ===
/**
 *  Stop scanning, flip the button.
 */
-(void)stopScanningOps {
    self.isScanning = NO;
    [self flipScanButtonAppearance];
    [self.scanner stopScanning];
    self.saveScannedBooksToCoreDataButton.hidden = NO;
    self.lightToggleButton.hidden                = YES;
}

/**
 *  Flip the button, start scanning, handle the completion.
 */
-(void)startScanningOps {
    self.isScanning = YES;
    [self flipScanButtonAppearance];
    self.saveScannedBooksToCoreDataButton.hidden = YES;
    self.lightToggleButton.hidden                = NO;
    
// ???: Consider embedding the scanning in this: [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success)...?
    [self.scannerView bringSubviewToFront:self.lightToggleButton.imageView];
    [self.scanner startScanningWithResultBlock:^(NSArray *codes) {
    // -------------------------------------------------------------------------------
    //	Scanning Success Block: We have a barcode!
    // -------------------------------------------------------------------------------
        for (AVMetadataMachineReadableCodeObject *code in codes) {
                // If it's a new barcode, add it to the array.
            if ([self.uniqueCodes indexOfObject:code.stringValue] == NSNotFound) {
                [self.uniqueCodes addObject:code.stringValue];
                
                    //1st APPROACH: NYAlertViewController sub-class. Should have worked, but didn't.
                    //✅ 2nd APPROACH: NYAlertViewController (like #1), but in this controller. Works.
//                NYAlertViewController *confirmSelectionViewController = [self confirmSelectionViewController];
//                [self presentViewController:confirmSelectionViewController animated:YES completion:^{ DBLG }];

                
                [self.googleClient queryForVolumeWithString:code.stringValue withCallback:^(GTLBooksVolume *responseVolume) {
        // -------------------------------------------------------------------------------
        //	Scanning Block : Google Success Block
        // -------------------------------------------------------------------------------
                    
                    self.volumeToConfirm = [[LBRParsedVolume alloc] initWithGoogleVolume:responseVolume];
                    NYAlertViewController *confirmationViewController = [self confirmSelectionViewController];
                    [self presentViewController:confirmationViewController animated:YES completion:nil];
                }];
            } else {
                NSLog(@"Barcode already in list/table.");
            }
        }
    }];
}

    ///TODO: Check isbn validity.
-(BOOL)checkISBNValidity:(NSString*)testString {
    NSPredicate *isbn10Predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES '\\\\d{10}|\\\\d{9}[Xx]'"];
    NSArray *isbn10Array = [@[testString] filteredArrayUsingPredicate:isbn10Predicate];
//    NSArray *isbn13Array = [@[testString] filteredArrayUsingPredicate:isbn13Predicate];
    
//    return (isbn10Array || isbn13Array);
//    return isbn10Array;
    return 0;
}

-(void)flipScanButtonAppearance {
    if (self.isScanning) {
        [self.toggleScanningButton setTitle:@"Stop Scanning" forState:UIControlStateNormal];
        [self.toggleScanningButton setTitleColor:[UIColor midnightBlueColor] forState:UIControlStateNormal];
        self.toggleScanningButton.backgroundColor = [UIColor pomegranateColor];
        [self.toggleScanningButton setTitleColor:[UIColor amethystColor] forState:UIControlStateNormal];
    } else {
        [self.toggleScanningButton setTitle:@"Start Scanning" forState:UIControlStateNormal];
        [self.toggleScanningButton setTitleColor:[UIColor belizeHoleColor] forState:UIControlStateNormal];
        self.toggleScanningButton.backgroundColor = [UIColor greenSeaColor];
        [self.toggleScanningButton setTitleColor:[UIColor carrotColor] forState:UIControlStateNormal];
    }
}


-(NSString*)yearFromDate:(NSDate*)date {
    NSCalendar *calendar    = [NSCalendar currentCalendar];
    NSInteger yearComponent = [calendar component:NSCalendarUnitYear fromDate:date];
    return [@(yearComponent) stringValue];
}


#pragma mark - == Confirmation Alert Controller (w/ Confirm/Cancel blocks) ==

-(NYAlertViewController*)confirmSelectionViewController {
    NYAlertViewController *alertViewController = [[NYAlertViewController alloc] initWithNibName:nil bundle:nil];
    
        // Set a title and message
    alertViewController.title    = NSLocalizedString(@"Put this book on your coffee table?", nil);
    alertViewController.message  = NSLocalizedString(@"Chuck Norris ipsum. Word out.", nil);

    NYAlertAction *confirmAction = [NYAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(NYAlertAction *action) {
                                                              [self dismissViewControllerAnimated:YES completion:^{
                                                                      //Add to TableView and its datasource.
                                                                   [self updateDataManagerWithNewTransientVolume:self.volumeToConfirm];
                                                               }];
                                                           }];
    
     NYAlertAction *cancelAction = [NYAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(NYAlertAction *action) {
                                                              [self dismissViewControllerAnimated:YES completion:nil];
                                                          }];
    
    [alertViewController addAction: confirmAction];
    [alertViewController addAction: cancelAction];
    alertViewController.title = NSLocalizedString(@"Verify Book", nil);
    alertViewController.message = NSLocalizedString(@"Is this the book you scanned?", nil);
    
        // The content view that will contain our custom view.
        ///Working on this now...
    UITableViewCell *confirmationCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@""];
    [confirmationCell configureForAutolayout];
    NSURL *url = [NSURL URLWithString:self.volumeToConfirm.cover_art_large];
    [confirmationCell.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder"]];
    confirmationCell.textLabel.text = @"";
    confirmationCell.detailTextLabel.text = @"";
    confirmationCell.textLabel.text = self.volumeToConfirm.title;
    confirmationCell.detailTextLabel.text = [NSString stringWithFormat:@"by %@", self.volumeToConfirm.author];
    
    
    UIView *contentView = [[UIView alloc] init];
    alertViewController.alertViewContentView = contentView;
    
    [contentView addSubview:confirmationCell];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[confirmationCell(60)]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(confirmationCell)]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[confirmationCell]-|"options:0 metrics:nil views:NSDictionaryOfVariableBindings(confirmationCell)]];
    [self configureAlertController:alertViewController andInvertColors:YES];
    
    return alertViewController;
}

    // Customize appearance as desired
-(void)configureAlertController:(NYAlertViewController*)alertViewController andInvertColors:(BOOL)invertColors {
    alertViewController.buttonCornerRadius = 20.0f;
    alertViewController.view.tintColor = self.view.tintColor;
    
    alertViewController.titleFont             = [UIFont fontWithName:@"AvenirNext-Bold" size:19.0f];
    alertViewController.messageFont           = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
    alertViewController.cancelButtonTitleFont = [UIFont fontWithName:@"AvenirNext-Medium" size:alertViewController.cancelButtonTitleFont.pointSize];
    alertViewController.buttonTitleFont       = [UIFont fontWithName:@"AvenirNext-Regular" size:alertViewController.buttonTitleFont.pointSize];
    
    
    alertViewController.swipeDismissalGestureEnabled = YES;
    alertViewController.backgroundTapDismissalGestureEnabled = YES;
    
    if (invertColors) {
        alertViewController.alertViewBackgroundColor = [UIColor colorWithWhite:0.19f alpha:1.0f];
        alertViewController.alertViewCornerRadius = 10.0f;
        
        alertViewController.titleColor = [UIColor colorWithRed:0.42f green:0.78 blue:0.32f alpha:1.0f];
        alertViewController.messageColor = [UIColor colorWithWhite:0.92f alpha:1.0f];
        
        alertViewController.buttonColor = [UIColor colorWithRed:0.42f green:0.78 blue:0.32f alpha:1.0f];
        alertViewController.buttonTitleColor = [UIColor colorWithWhite:0.19f alpha:1.0f];
        
        alertViewController.cancelButtonColor = [UIColor colorWithRed:0.42f green:0.78 blue:0.32f alpha:1.0f];
        alertViewController.cancelButtonTitleColor = [UIColor colorWithWhite:0.19f alpha:1.0f];
    }
}

#pragma mark - === UITableViewDataSource methods ===

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        return self.unsavedVolumes.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:barcodeCellReuseID forIndexPath:indexPath];
    cell = self.unsavedVolumes[indexPath.row];
    return cell;
}

-(void)configureCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    
}

#pragma mark - Data Manager interface

-(void)generateTestDataIfNeeded {
    LBRDataManager *dataManager = [LBRDataManager sharedDataManager];
    [dataManager generateTestDataIfNeeded];
}

-(void)updateDataManagerWithNewTransientVolume:(LBRParsedVolume*)volumeToAdd {
        // Preliminaries
    LBRDataManager *dataManager = [LBRDataManager sharedDataManager];
    if ([self isNewUniqueObject:volumeToAdd])
    {
        [dataManager updateWithNewTransientVolume:volumeToAdd];
    }
}

- (void)showMapViewAlertView {
DBLG
    NYAlertViewController *alertViewController = [[NYAlertViewController alloc] initWithNibName:nil bundle:nil];
    
    [alertViewController addAction:[NYAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(NYAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [alertViewController addAction:[NYAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(NYAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];

    alertViewController.title = @"Content View";
    alertViewController.message = @"YOUR AD HERE";
    
    UIView *contentView = [[UIView alloc] init];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@""];
    [contentView addSubview:cell];
    [cell.imageView setImage:[UIImage imageNamed:@"placeholder"]];
    cell.textLabel.text = (self.volumeToConfirm)? self.volumeToConfirm.title : @"Title Here";
    cell.detailTextLabel.text = @"byline here";

    alertViewController.alertViewContentView = contentView;
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[cell(160)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cell)]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[cell]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cell)]];

    [self presentViewController:alertViewController animated:YES completion:nil];
}


#pragma mark - === UIScrollViewDelegate ===



@end
