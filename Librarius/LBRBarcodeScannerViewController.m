//
//  LBRBarcodeScannerViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/23/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//
#define DBLG NSLog(@"<%@:%@:line %d, reporting!>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
#define kSpinnerFrameRect CGRectMake(0, 0, 40, 40)
#define kAppIconSize 48

    //Definitely Used:
#import <AVFoundation/AVFoundation.h>
#import <UIImageView+AFNetworking.h>
//#import <MMMaterialDesignSpinner.h>
#import <NYAlertViewController.h>
#import <MTBBarcodeScanner.h>
#import <LARSTorch.h>
#import "LBRConstants.h"
#import "LBRBarcodeScannerViewController.h"
#import "LBRGoogleGTLClient.h"
#import "LBRDataManager.h"
#import "Library.h"
#import "Volume.h"
#import "LBRParsedVolume.h"
#import "FlatUI+Categories.h"
    //Testing out:
#import "UIView+ConfigureForAutoLayout.h"
#import "LBRAlertContent_TableViewController.h"
#import "LBRBatchScanScrollView.h"

@interface LBRBarcodeScannerViewController ()

- (IBAction)toggleScanningButtonTapped:(id)sender;
- (IBAction)lightToggleButtonTapped:(id)sender;
- (IBAction)saveScannedVolumesToLibraryButtonTapped:(id)sender;

    //Button outlets
@property (weak, nonatomic) IBOutlet UIButton *lightToggleButton;
@property (weak, nonatomic) IBOutlet UIButton *saveScannedBooksToCoreDataButton;
@property (weak, nonatomic) IBOutlet UIButton *toggleScanningButton;

    //UIViews
@property (weak, nonatomic) IBOutlet UIView *mainContentView;
@property (weak, nonatomic) IBOutlet UIView *scannerView;
@property (weak, nonatomic) IBOutlet LBRBatchScanScrollView *unsavedVolumesScrollView;
@property (nonatomic, strong) IBOutlet UITableView *unsavedVolumesTableView;


@property (nonatomic, strong) NSMutableArray *unsavedVolumes;
@property (nonatomic, strong) MTBBarcodeScanner *scanner;
@property (nonatomic, strong) LBRGoogleGTLClient *googleClient;

//@property (nonatomic, strong) MMMaterialDesignSpinner *spinnerView;

@property (nonatomic) BOOL isConfigured;

@property (nonatomic) BOOL isScanning;






@end


@implementation LBRBarcodeScannerViewController

#pragma mark - Constant Strings

static NSString * const barcodeCellReuseID = @"barcodeCellReuseID";
static NSString * const volumeNib          = @"volumePresentationView";

#pragma mark -
#pragma mark - === Lifecycle ===
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    [self generateTestDataIfNeeded];

    if (!self.isConfigured) {
        [self configureProgrammaticProperties];}
    
}

-(void)configureProgrammaticProperties {
        // Initializations
    self.googleClient    = [LBRGoogleGTLClient sharedGoogleGTLClient];
    self.uniqueCodes     = [NSMutableArray  new];
    self.volumeToConfirm = [LBRParsedVolume new];
    [self initializeScannerView];
    self.unsavedVolumesTableView.delegate = self;
    self.unsavedVolumesTableView.dataSource = self;
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
    [self.unsavedVolumesScrollView bringSubviewToFront:self.unsavedVolumesTableView];
    
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
    self.unsavedVolumesScrollView.hidden = NO;
}


-(void)initializeScannerView {
    self.scanner         = [[MTBBarcodeScanner alloc] initWithMetadataObjectTypes:@[AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeEAN13Code] previewView:self.scannerView];
        ///Alternative: self.scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:self.scannerView];

    self.scannerView.layer.cornerRadius = 5.0f;
}

//-(void)initializeSpinner {
//        //TODO: place this view somewhere, and give it a size somehow.
//    self.spinnerView                  = [MMMaterialDesignSpinner new];
//    self.spinnerView.lineWidth        = 1.5f;
//    self.spinnerView.tintColor        = [UIColor cyanColor];
//    self.spinnerView.hidesWhenStopped = YES;
//    [self.view addSubview:self.spinnerView];
//}


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
        [self startScanningOps];}
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

- (IBAction)saveScannedVolumesToLibraryButtonTapped:(id)sender {
    LBRDataManager *dataManager = [LBRDataManager sharedDataManager];
    [dataManager saveParsedVolumesToEitherSaveOrDiscardToPersistentStore];
    [dataManager logCurrentLibrary];
}

#pragma mark -
#pragma mark - === Scanning ===
#pragma mark -

/**
 *  Stop scanning, flip the button.
 */
-(void)stopScanningOps {
    self.isScanning                              = NO;
    [self flipScanButtonAppearance];
    [self.scanner stopScanning];
    self.saveScannedBooksToCoreDataButton.hidden = NO;
    self.unsavedVolumesScrollView.hidden         = NO;
    self.lightToggleButton.hidden                = YES;
}

/**
 *  Flip the button, start scanning, handle the completion.
 */
-(void)startScanningOps {
    self.isScanning                              = YES;
    [self flipScanButtonAppearance];
    self.saveScannedBooksToCoreDataButton.hidden = YES;
    self.unsavedVolumesScrollView.hidden         = YES;
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

#pragma mark -
#pragma mark - == Confirmation Alert Controller (w/ Confirm/Cancel blocks) ==
#pragma mark -

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
    alertViewController.title = NSLocalizedString(@"Content View", nil);
    alertViewController.message = NSLocalizedString(@"Set the alertViewContentView property to add custom views to the alert view", nil);
    
        // The content view that will contain our custom view.
        ///Working on this now...
    UITableViewCell *confirmationCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@""];
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

#pragma mark -
#pragma mark - === UITableViewDataSource methods ===
#pragma mark -

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

#pragma mark -
#pragma mark - Data Manager interface

-(void)generateTestDataIfNeeded {
    LBRDataManager *dataManager = [LBRDataManager sharedDataManager];
    [dataManager generateTestDataIfNeeded];
}

-(void)updateDataManagerWithNewTransientVolume:(LBRParsedVolume*)volumeToAdd {
        // Preliminaries
    LBRDataManager *dataManager = [LBRDataManager sharedDataManager];
    [dataManager updateWithNewTransientVolume:volumeToAdd];
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


#pragma mark -
#pragma mark - === UIScrollViewDelegate ===



@end
