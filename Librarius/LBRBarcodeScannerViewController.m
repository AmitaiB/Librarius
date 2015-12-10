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
#import "NSString+dateValue.h"




@interface LBRBarcodeScannerViewController ()

- (IBAction)toggleScanningButtonTapped:(id)sender;
- (IBAction)lightToggleButtonTapped:(id)sender;
//- (IBAction)saveScannedBooksToCoreDataButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *lightToggleButton;
//@property (weak, nonatomic) IBOutlet UIButton *saveScannedBooksToCoreDataButton;

@property (weak, nonatomic) IBOutlet UIView *mainContentView;
@property (weak, nonatomic) IBOutlet UIView *scannerView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *toggleScanningButton;
@property (nonatomic, weak) IBOutlet UISearchBar *manualEntrySearchBar;

@property (nonatomic, strong) MTBBarcodeScanner *scanner;
@property (nonatomic, strong) LBRGoogleGTLClient *googleClient;

@property (nonatomic, strong) NSArray *booksArray;
@property (nonatomic, strong) NSFetchedResultsController *volumesFetchedResultsController;


@property (nonatomic) BOOL isConfigured;

@property (nonatomic) BOOL isScanning;


    //Optional: Overlay Views
@property (nonatomic, strong) NSMutableDictionary *overlayViews;


    //DEBUG:
- (IBAction)resetButtonTapped:(id)sender;
- (IBAction)logBooksButtonTapped:(id)sender;


@end


@implementation LBRBarcodeScannerViewController {
    LBRDataManager *dataManager;
}


static NSString * const barcodeCellReuseID = @"barcodeCellReuseID";
static NSString * const volumeNib          = @"volumePresentationView";

#pragma mark - === Lifecycle ===

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!self.isConfigured) {
        [self configureProgrammaticProperties];}
    
//    [dataManager generateTestDataIfNeeded];
    self.canDisplayBannerAds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self stopScanningOps];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self stopScanningOps];
    [super viewWillDisappear:animated];
}

#pragma mark Private LifeCycle methods

-(void)configureProgrammaticProperties {
        // Initializations
    self.googleClient    = [LBRGoogleGTLClient sharedGoogleGTLClient];
    dataManager          = [LBRDataManager sharedDataManager];
    self.uniqueCodes     = [NSMutableArray  new];
    [self initializeScannerView];
    
        // Hidden Things
    self.lightToggleButton.hidden = YES;
    
        // UI Elements
    self.lightToggleButton.layer.cornerRadius                = 5.0f;
    self.lightToggleButton.backgroundColor                   = [UIColor sunflowerColor];
    self.toggleScanningButton.backgroundColor                = [UIColor belizeHoleColor];
    self.toggleScanningButton.tintColor                      = [UIColor turquoiseColor];
    self.toggleScanningButton.layer.cornerRadius             = 5.0f;
    
    [self anchorBackgroundImage];
    
        // Manual Entry SearchBar
    self.manualEntrySearchBar.barTintColor = self.navigationController.navigationBar.tintColor;
    self.manualEntrySearchBar.delegate     = self;
    UITextField *searchBarTxField = [self.manualEntrySearchBar valueForKey:@"_searchField"];
    searchBarTxField.clearsOnBeginEditing = YES;
    searchBarTxField.clearsOnInsertion = YES;
    
        // So we don't repeat ourselves.
    self.isConfigured = YES;
}

-(void)anchorBackgroundImage
{
    UIImageView *imageView = self.backgroundImageView;
    [imageView removeConstraints:imageView.constraints];
    [self.mainContentView addSubview:imageView];
    UIView *superView = imageView.superview;
    [imageView.topAnchor constraintEqualToAnchor:superView.topAnchor constant:0].active    = YES;
    [imageView.bottomAnchor constraintEqualToAnchor:superView.bottomAnchor constant:0].active = YES;
    [imageView.leadingAnchor constraintEqualToAnchor:superView.leadingAnchor constant:0].active         = YES;
    [imageView.trailingAnchor constraintEqualToAnchor:superView.trailingAnchor constant:0].active       = YES;
}


-(void)initializeScannerView
{
    self.scanner         = [[MTBBarcodeScanner alloc] initWithMetadataObjectTypes:@[AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeEAN13Code] previewView:self.scannerView];
        ///Alternative: self.scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:self.scannerView];

    self.scannerView.layer.cornerRadius = 5.0f;
}


#pragma mark - === Buttons IBActions & helpers ===

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
    [dataManager saveContext];
    [dataManager logCurrentLibrary];
}

  /**
   FIXME: Needs to check DataStore for duplicates - same book could be two different NSManagedObjects (diff. ID#s).
*/
-(BOOL)isNewUniqueObject:(Volume *)volumeToCheck
{
    NSArray *booksArray = self.volumesFetchedResultsController.fetchedObjects;
    
    NSUInteger indexOfMatchingISBN = [booksArray indexOfObjectPassingTest:^BOOL(Volume *book, NSUInteger idx, BOOL * _Nonnull stop) {
        return ([book.isbn isEqualToString:volumeToCheck.isbn]);
    }];
    BOOL isUniqueISBN = (indexOfMatchingISBN == NSNotFound);
    
    return isUniqueISBN;
}

-(NSFetchedResultsController *)volumesFetchedResultsController
{
    if (_volumesFetchedResultsController != nil) {
        return _volumesFetchedResultsController;
    }
    return [[LBRDataManager sharedDataManager]
            currentLibraryVolumesFetchedResultsController:self];
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

-(void)alertUserNoInternetConnection
{
    UIAlertController *noInternetAlertController = [UIAlertController alertControllerWithTitle:@"No Internet Detected" message:@"An internet connection is required to look up book data and images." preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:noInternetAlertController animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }];
}


#pragma mark - === Scanning ===
/**
 *  Stop scanning, flip the button.
 */
    //It's first because it's shorter.
-(void)stopScanningOps {
    self.isScanning = NO;
    [self flipScanButtonAppearance];
    [self.scanner stopScanning];
//    self.saveScannedBooksToCoreDataButton.hidden = NO;
    self.lightToggleButton.hidden                = YES;
    
    self.manualEntrySearchBar.hidden = NO;
    
        //New! Overlay Views
    for (NSString *code in self.overlayViews.allKeys) {
        [self.overlayViews[code] removeFromSuperview];
    }

}

/**
 *  Flip the button, start scanning, handle the completion.
 */
-(void)startScanningOps {
    self.isScanning = YES;
    [self flipScanButtonAppearance];
//    self.saveScannedBooksToCoreDataButton.hidden = YES;
    self.lightToggleButton.hidden                = NO;
    self.manualEntrySearchBar.hidden = YES;
    
        //New! Overlay Views
//    Optionally set a rectangle of interest to scan codes. Only codes within this rect will be scanned.
//    self.scanner.scanRect = self.viewOfInterest.frame;
    
    /**
     The success block will return YES if the user granted permission, has granted permission in 
     the past, or if the device is running iOS 7. The success block will return NO if the user 
     denied permission, is restricted from the camera, or if there is no camera present.
     */
    [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success) {
        if (!success) return;
    // -------------------------------------------------------------------------------
    //	*Scanning* Success Block: We have a barcode!
    // -------------------------------------------------------------------------------
        [self.scanner startScanningWithResultBlock:^(NSArray *codes) {
                //New! Overlay Views
            [self drawOverlaysOnCodes:codes];
            
            NSMutableArray<NSString*> *reportedBarcodes = [NSMutableArray new];
            for (AVMetadataMachineReadableCodeObject *code in codes) {

//                if ([self.uniqueCodes indexOfObject:code.stringValue] == NSNotFound) {
                    // If it's a new barcode, add it to the array for duplicate prevention.
                BOOL barcodeIsNew = ![self.uniqueCodes containsObject:code.stringValue];
                if (barcodeIsNew) {
                        //Add barcode to the record of other unique barcodes.
                    [self.uniqueCodes addObject:code.stringValue];

                        //Use the string to query Google.
                    [self queryGoogleBooksClientForString:code.stringValue];

                } else {
                    if (![reportedBarcodes containsObject:code.stringValue]) {
                        //DDLogVerbose(@"Barcode already in list/table.");
                        [reportedBarcodes addObject:code.stringValue];
                    }
                }
            }
        }];
    }];
}

-(void)queryGoogleBooksClientForString:(NSString*)q
{
    if (!q || [q stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        return;
    }
    
    
    [self.googleClient queryForVolumeWithString:q withCallback:^(GTLBooksVolume *responseVolume) {
            // -------------------------------------------------------------------------------
            //	Scanning Block : Google Success Block
            // -------------------------------------------------------------------------------
        Volume *volume = [Volume insertNewObjectIntoContext:dataManager.managedObjectContext
                           initializedFromGoogleBooksObject:responseVolume
                                              withCovertArt:YES];
        
            //                        [[LBRDataManager sharedDataManager] logCurrentLibraryTitles:@"[Google Success Block]"];
        
            ///TODO: Alternative to confirmation, hmmm...? Perhaps put the view up in the scanning reticule...?
        NYAlertViewController *confirmationViewController = [self confirmSelectionViewController:volume];
        [self presentViewController:confirmationViewController animated:YES completion:nil];
    }];
}

    ///TODO: Implement: Check isbn validity.
//-(BOOL)checkISBNValidity:(NSString*)testString {
//    NSPredicate *isbn10Predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES '\\\\d{10}|\\\\d{9}[Xx]'"];
//    NSArray *isbn10Array = [@[testString] filteredArrayUsingPredicate:isbn10Predicate];
//    return 0;
//}

-(void)flipScanButtonAppearance {
    if (self.isScanning) {
        [self.toggleScanningButton setTitle:@"Stop" forState:UIControlStateNormal];
        [self.toggleScanningButton setTitleColor:[UIColor midnightBlueColor] forState:UIControlStateNormal];
        self.toggleScanningButton.backgroundColor = [UIColor pomegranateColor];
        [self.toggleScanningButton setTitleColor:[UIColor amethystColor] forState:UIControlStateNormal];
    } else {
        [self.toggleScanningButton setTitle:@"Scan" forState:UIControlStateNormal];
        [self.toggleScanningButton setTitleColor:[UIColor belizeHoleColor] forState:UIControlStateNormal];
        self.toggleScanningButton.backgroundColor = [UIColor greenSeaColor];
        [self.toggleScanningButton setTitleColor:[UIColor carrotColor] forState:UIControlStateNormal];
    }
}


#pragma mark - Scanning Code Overlays
    ///Credit goes to Mike Buss of MTBScanner - code borrowed from his example project.
- (NSMutableDictionary *)overlayViews {
    if (!_overlayViews) {
        _overlayViews = [[NSMutableDictionary alloc] init];
    }
    return _overlayViews;
}

- (void)drawOverlaysOnCodes:(NSArray *)codes {
        // Get all of the captured code strings
    NSMutableArray *codeStrings = [[NSMutableArray alloc] init];
    for (AVMetadataMachineReadableCodeObject *code in codes) {
        if (code.stringValue) {
            [codeStrings addObject:code.stringValue];
        }
    }
    
        // Remove any code overlays no longer on the screen
    for (NSString *code in self.overlayViews.allKeys) {
        if ([codeStrings indexOfObject:code] == NSNotFound) {
                // A code that was on the screen is no longer
                // in the list of captured codes, remove its overlay
            [self.overlayViews[code] removeFromSuperview];
            [self.overlayViews removeObjectForKey:code];
        }
    }
    
    for (AVMetadataMachineReadableCodeObject *code in codes) {
        UIView *view = nil;
        NSString *codeString = code.stringValue;
        
        if (codeString) {
            if (self.overlayViews[codeString]) {
                    // The overlay is already on the screen
                view = self.overlayViews[codeString];
                
                    // Move it to the new location
                view.frame = code.bounds;
                
            } else {
                    // First time seeing this code
                BOOL isValidCode = [self isValidCodeString:codeString];
                
                    // Create an overlay
                UIView *overlayView = [self overlayForCodeString:codeString
                                                          bounds:code.bounds
                                                           valid:isValidCode];
                self.overlayViews[codeString] = overlayView;
                
                    // Add the overlay to the preview view
                [self.scannerView addSubview:overlayView];
                
            }
        }
    }
}

- (BOOL)isValidCodeString:(NSString *)codeString {
    BOOL stringIsValid = ([codeString rangeOfString:@"Valid"].location != NSNotFound);
    return stringIsValid;
}

- (UIView *)overlayForCodeString:(NSString *)codeString bounds:(CGRect)bounds valid:(BOOL)valid {
    UIColor *viewColor     = valid ? [UIColor greenColor] : [UIColor redColor];
    UIView *view           = [[UIView alloc] initWithFrame:bounds];
    UILabel *label         = [[UILabel alloc] initWithFrame:view.bounds];

        // Configure the view
    view.layer.borderWidth = 5.0;
    view.backgroundColor   = [viewColor colorWithAlphaComponent:0.75];
    view.layer.borderColor = viewColor.CGColor;

        // Configure the label
    label.font             = [UIFont boldSystemFontOfSize:12];
    label.text             = codeString;
    label.textColor        = [UIColor blackColor];
    label.textAlignment    = NSTextAlignmentCenter;
    label.numberOfLines    = 0;
    
        // Add constraints to label to improve text size?
    
        // Add the label to the view
    [view addSubview:label];
    
    return view;
}

#pragma mark - == Confirmation Alert Controller (w/ Confirm/Cancel blocks) ==

/**
 I have kept this ill-understood (by me) pod because the standard options do not easily allow for an image,
 and I got this to work. Once "Make It Work" gives way to "Make It Right," this will be the first to go.
 */
-(NYAlertViewController*)confirmSelectionViewController:(Volume*)volumeToConfirm {
    NYAlertViewController *alertViewController = [[NYAlertViewController alloc] initWithNibName:nil bundle:nil];
    
        // Set a title and message
    alertViewController.title    = NSLocalizedString(@"Put this book on your coffee table?", nil);
    alertViewController.message  = NSLocalizedString(@"Chuck Norris ipsum. Word out.", nil);

    NYAlertAction *confirmAction = [NYAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(NYAlertAction *action) {
                                                              //DDLogInfo(@"Confirm tapped.");
                                                              [self dismissViewControllerAnimated:YES completion:^{
//                                                                  [dataManager logCurrentLibraryTitles:@"[BEFORE confirm action tapped]"];
//                                                                  self.manualEntrySearchBar.text = @""; COUPLING EXAMPLE
                                                                  [dataManager saveContext];
//                                                                  [dataManager logCurrentLibraryTitles:@"[AFTER confirm action tapped]"];
                                                                      //TODO: Add to a TableView.
                                                               }];
                                                           }];
    
     NYAlertAction *cancelAction = [NYAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(NYAlertAction *action) {
                                                              //DDLogInfo(@"Cancel tapped.");
                                                              [volumeToConfirm.managedObjectContext deleteObject:volumeToConfirm];
                                                              [self dismissViewControllerAnimated:YES completion:nil];
                                                          }];
    
    [alertViewController addAction: confirmAction];
    [alertViewController addAction: cancelAction];
    alertViewController.title = NSLocalizedString(@"Verify Book", nil);
    alertViewController.message = NSLocalizedString(@"Is this the book you scanned?", nil);
    
        // The content view that will contain our custom view.
        ///Working on this now...
    UITableViewCell *confirmationCell        = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@""];
    [confirmationCell configureForAutolayout];
    NSURL *url                               = [NSURL URLWithString:volumeToConfirm.cover_art_large];
    [confirmationCell.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder"]];
//    confirmationCell.textLabel.text          = @"";
//    confirmationCell.detailTextLabel.text    = @"";
    confirmationCell.textLabel.text          = volumeToConfirm.title;
    confirmationCell.detailTextLabel.text    = volumeToConfirm.byline; //    = [NSString stringWithFormat:@"by %@", volumeToConfirm.author];


    UIView *contentView                      = [[UIView alloc] init];
    alertViewController.alertViewContentView = contentView;
    
    [contentView addSubview:confirmationCell];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[confirmationCell(60)]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(confirmationCell)]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[confirmationCell]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(confirmationCell)]];
    [self configureAlertController:alertViewController andInvertColors:YES];
    
    return alertViewController;
}

    // Customize appearance as desired
-(void)configureAlertController:(NYAlertViewController*)alertViewController andInvertColors:(BOOL)invertColors {
    alertViewController.buttonCornerRadius = 20.0f;
    alertViewController.view.tintColor = self.view.tintColor;
    
    alertViewController.titleFont             = [UIFont fontWithName:@"AvenirNext-Bold"    size:19.0f];
    alertViewController.messageFont           = [UIFont fontWithName:@"AvenirNext-Medium"  size:16.0f];
    alertViewController.cancelButtonTitleFont = [UIFont fontWithName:@"AvenirNext-Medium"  size:alertViewController.cancelButtonTitleFont.pointSize];
    alertViewController.buttonTitleFont       = [UIFont fontWithName:@"AvenirNext-Regular" size:alertViewController.buttonTitleFont.pointSize];
    
    
    alertViewController.swipeDismissalGestureEnabled = YES;
    alertViewController.backgroundTapDismissalGestureEnabled = YES;
    
    if (invertColors) {
        alertViewController.alertViewBackgroundColor = [UIColor colorWithWhite:0.19f alpha:1.0f];
        alertViewController.alertViewCornerRadius    = 10.0f;

        alertViewController.titleColor               = [UIColor colorWithRed:0.42f green:0.78 blue:0.32f alpha:1.0f];
        alertViewController.messageColor             = [UIColor colorWithWhite:0.92f alpha:1.0f];

        alertViewController.buttonColor              = [UIColor colorWithRed:0.42f green:0.78 blue:0.32f alpha:1.0f];
        alertViewController.buttonTitleColor         = [UIColor colorWithWhite:0.19f alpha:1.0f];

        alertViewController.cancelButtonColor        = [UIColor colorWithRed:0.42f green:0.78 blue:0.32f alpha:1.0f];
        alertViewController.cancelButtonTitleColor   = [UIColor colorWithWhite:0.19f alpha:1.0f];
    }
}

    ///TODO: This whole section is Not Yet Implemented.
    ///The intention is to have a tableView displaying the inserted (not saved) book choices.
#pragma mark - === UITableViewDataSource methods ===

    //The only tableView WILL BE the unsaved volumes one.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        return dataManager.managedObjectContext.insertedObjects.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:barcodeCellReuseID forIndexPath:indexPath];
//    Volume *volume = [dataManager.managedObjectContext.insertedObjects sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]][indexPath.row];
    return cell;
}

-(void)configureCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    
}

- (IBAction)resetButtonTapped:(id)sender {
    LBRDataManager *dataManger = [LBRDataManager sharedDataManager];
//    [dataManger logCurrentLibraryTitles:@"[TOP of resetButtonTapped]"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:[RootCollection entityName]];
    [defaults synchronize];
    dataManger.userRootCollection = nil;
    dataManger.currentLibrary = nil;
    [dataManger deleteAllObjectsOfEntityName:[Volume entityName]];
    [dataManger deleteAllObjectsOfEntityName:@"Bookcase"];
    [dataManger deleteAllObjectsOfEntityName:[Library entityName]];
    [dataManger deleteAllObjectsOfEntityName:[RootCollection entityName]];
    [self.uniqueCodes removeAllObjects];
//    [dataManger logCurrentLibraryTitles:@"[BOTTOM of resetButtonTapped]"];
//    [dataManger.managedObjectContext reset];
//    [dataManger saveContext];
//    [dataManger logCurrentLibrary];
}

- (IBAction)logBooksButtonTapped:(id)sender
{
    [dataManager logCurrentLibraryTitles:@"[logBooksButtonTapped]"];
}

#pragma mark - === UISearchBar Delegate ===

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self queryGoogleBooksClientForString:searchBar.text];
}


@end
