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
#import <MTBBarcodeScanner.h>
#import <MMMaterialDesignSpinner.h>
#import "LBRBarcodeScannerViewController.h"
#import "LBRGoogleGTLClient.h"
#import <NYAlertViewController.h>
#import <UIImageView+AFNetworking.h>
#import "LBRDataManager.h"
#import "Library.h"
#import "Volume.h"
#import "LBRParsedVolume.h"
#import <AVFoundation/AVFoundation.h>
#import <LARSTorch.h>
#import "LBRConstants.h"
    //Testing out:


@interface LBRBarcodeScannerViewController ()

- (IBAction)toggleScanningButtonTapped:(id)sender;
- (IBAction)lightToggleButtonTapped:(id)sender;
- (IBAction)saveScannedVolumesToLibraryButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *lightToggleButton;
@property (weak, nonatomic) IBOutlet UIButton *saveScannedBooksToCoreDataButton;

@property (weak, nonatomic) IBOutlet UIView *mainContentView;
@property (weak, nonatomic) IBOutlet UIView *scannerView;
@property (weak, nonatomic) IBOutlet UIButton *toggleScanningButton;
@property (nonatomic, strong) UITableView *volumeDetailsTableView;
@property (nonatomic, strong) UITableView *unsavedVolumesTableView;
@property (nonatomic, strong) NSMutableArray *unsavedVolumes;
@property (nonatomic, strong) MTBBarcodeScanner *scanner;
@property (nonatomic, strong) LBRGoogleGTLClient *googleClient;

@property (nonatomic, strong) MMMaterialDesignSpinner *spinnerView;

@property (nonatomic) BOOL isScanning;
@end


@implementation LBRBarcodeScannerViewController

#pragma mark - Constant Strings

static NSString * const barcodeCellReuseID = @"barcodeCellReuseID";
static NSString * const volumeNib          = @"volumePresentationView";


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self generateTestDataIfNeeded];
        //TODO: only remake these if needed (performance)
    [self initializeProgrammaticProperties];
}

-(void)viewWillLayoutSubviews {
    self.unsavedVolumesTableView.frame = self.scannerView.bounds;
}

-(void)initializeProgrammaticProperties {
    self.googleClient             = [LBRGoogleGTLClient sharedGoogleGTLClient];
    self.uniqueCodes              = [NSMutableArray new];
    self.lightToggleButton.hidden = YES;
    self.unsavedVolumes           = [NSMutableArray new];
    [self initializeUnsavedVolumesTableView:self.unsavedVolumesTableView];
    [self initializeSpinner];
        //SETTINGS: Choose which objects the scanner reads. Keep this one, but if your book doesn't read, try accepting all metadaobjects...
    self.scanner = [[MTBBarcodeScanner alloc] initWithMetadataObjectTypes:@[AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeEAN13Code] previewView:self.scannerView];
        //self.scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:self.scannerView];
    
}

-(void)initializeSpinner {
    self.spinnerView = [[MMMaterialDesignSpinner alloc] initWithFrame:kSpinnerFrameRect];
    self.spinnerView.lineWidth = 1.5f;
    self.spinnerView.tintColor = [UIColor cyanColor];
    self.spinnerView.hidesWhenStopped = YES;
    [self.view addSubview:self.spinnerView];
}

-(void)initializeUnsavedVolumesTableView:(UITableView*)tableView {
    tableView               = [UITableView new];
    UINib *volumeDetailsNib = [UINib nibWithNibName:@"volumeDetailsCell" bundle:nil];
    [tableView registerNib:volumeDetailsNib forCellReuseIdentifier:@"volumeDetailsCellID"];
    tableView.delegate      = self;
    tableView.dataSource    = self;
    tableView.hidden        = NO;
    [self.mainContentView addSubview:tableView];
    [self.mainContentView bringSubviewToFront:tableView];
    
    
        //FIXME
//    [tableView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView]|"
//                                                                        options:0
//                                                                        metrics:nil
//                                                                          views:NSDictionaryOfVariableBindings(tableView)]];
//    
//    [tableView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[tableView]-|"
//                                                                        options:0
//                                                                        metrics:nil
//                                                                          views:NSDictionaryOfVariableBindings(tableView)]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self stopScanningOps];
    // Dispose of any resources that can be recreated.
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
    
#pragma mark - Scanning

/**
 *  Stop scanning, flip the button.
 */
-(void)stopScanningOps {
    self.isScanning = NO;
    [self flipScanButtonAppearance];
    [self.scanner stopScanning];
    self.saveScannedBooksToCoreDataButton.hidden = NO;
    self.unsavedVolumesTableView.hidden          = NO;
    self.lightToggleButton.hidden                = YES;
}

/**
 *  Flip the button, start scanning, handle the completion.
 */
-(void)startScanningOps {
    self.isScanning = YES;
    [self flipScanButtonAppearance];
    self.saveScannedBooksToCoreDataButton.hidden = YES;
    self.unsavedVolumesTableView.hidden          = YES;
    self.lightToggleButton.hidden                = NO;
    
// ???: Consider embedding the scanning in this: [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success)...?
    [self.scannerView bringSubviewToFront:self.lightToggleButton.imageView];
//    [self.view sendSubviewToBack:self.scannerView];
    [self.scanner startScanningWithResultBlock:^(NSArray *codes) {
    // -------------------------------------------------------------------------------
    //	Scanning Success Block: We have a barcode!
    // -------------------------------------------------------------------------------
        for (AVMetadataMachineReadableCodeObject *code in codes) {
                // If it's a new barcode, add it to the array.
            if ([self.uniqueCodes indexOfObject:code.stringValue] == NSNotFound) {
                [self.uniqueCodes addObject:code.stringValue];
                [self.spinnerView startAnimating];
                
                    //1st APPROACH: NYAlertViewController sub-class. Should have worked, but didn't.
                    //✅ 2nd APPROACH: NYAlertViewController (like #1), but in this controller. Works.
                NYAlertViewController *confirmSelectionViewController = [self confirmSelectionViewController];
                [self presentViewController:confirmSelectionViewController animated:YES completion:^{ DBLG }];

                [self.googleClient queryForVolumeWithString:code.stringValue withCallback:^(GTLBooksVolume *responseVolume) {
        // -------------------------------------------------------------------------------
        //	Scanning Block : Google Success Block
        // -------------------------------------------------------------------------------
                    [self.spinnerView stopAnimating];
                    self.volumeToConfirm = [[LBRParsedVolume alloc] initWithGoogleVolume:responseVolume];
                    [self.volumeDetailsTableView reloadData];
                }];
            } else {
                NSLog(@"Barcode already in list/table.");
            }
        }
    }];
}

    //TODO: Check isbn validity.
-(BOOL)checkISBNValidity:(NSString*)testString {
    NSPredicate *isbn10Predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES '\\\\d{10}|\\\\d{9}[Xx]'"];
    NSArray *isbn10Array = [@[testString] filteredArrayUsingPredicate:isbn10Predicate];
//    NSArray *isbn13Array = [@[testString] filteredArrayUsingPredicate:isbn13Predicate];
    
//    return (isbn10Array || isbn13Array);
    return isbn10Array;
}

    //FIXME: doesn't work properly.
    //TODO: impl SelectedButton changes.
-(void)flipScanButtonAppearance {
    if (self.isScanning) {
        [self.toggleScanningButton setTitle:@"Stop Scanning" forState:UIControlStateNormal];
        [self.toggleScanningButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        self.toggleScanningButton.backgroundColor = [UIColor redColor];
    } else {
        [self.toggleScanningButton setTitle:@"Start Scanning" forState:UIControlStateNormal];
        [self.toggleScanningButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        self.toggleScanningButton.backgroundColor = [UIColor cyanColor];
    }
}


-(NSString*)yearFromDate:(NSDate*)date {
    NSCalendar *calendar    = [NSCalendar currentCalendar];
    NSInteger yearComponent = [calendar component:NSCalendarUnitYear fromDate:date];
    return [@(yearComponent) stringValue];
}

#pragma mark - Confirmation Alert Controller (w/ Confirm/Cancel blocks)

-(NYAlertViewController*)confirmSelectionViewController {
    NYAlertViewController *alertViewController = [[NYAlertViewController alloc] initWithNibName:nil bundle:nil];
    
        // Set a title and message
    alertViewController.title = NSLocalizedString(@"Put this book on your coffee table?", nil);
    alertViewController.message = NSLocalizedString(@"Chuck Norris ipsum. Word out.", nil);
    
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
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    alertViewController.alertViewContentView = contentView;
    
        // The TableView that really should be simple!
    UITableView *singleCellTableView = [[UITableView alloc] initWithFrame:contentView.frame style:UITableViewStyleGrouped];
    self.volumeDetailsTableView = singleCellTableView; //gives the VController a reference to this tableview...
    singleCellTableView.dataSource = self;
    singleCellTableView.delegate = self;
    singleCellTableView.backgroundColor = [UIColor whiteColor];
    singleCellTableView.estimatedRowHeight = 65.0;
    singleCellTableView.rowHeight = UITableViewAutomaticDimension;
    [singleCellTableView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [singleCellTableView setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    
    UINib *volumeDetailsNib = [UINib nibWithNibName:@"volumeDetailsCell" bundle:nil];
    [singleCellTableView registerNib:volumeDetailsNib forCellReuseIdentifier:@"volumeDetailsCellID"];
    
    
    /**
     *  Magic happens here!
     */
    [contentView addSubview:singleCellTableView];
    
    [self prepareViewForAutolayout:singleCellTableView];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[singleCellTableView(100)]|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:NSDictionaryOfVariableBindings(singleCellTableView)]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[singleCellTableView]-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:NSDictionaryOfVariableBindings(singleCellTableView)]];
        // This was inspiring!, but I didn't need it in the end.
//    [singleCellTableView makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(singleCellTableView.superview).with.insets(UIEdgeInsetsMake(28, 0, 28, 0));
//    }];
    
    
        // Customize appearance as desired
    alertViewController.buttonCornerRadius = 20.0f;
    alertViewController.view.tintColor = self.view.tintColor;
    
    alertViewController.titleFont = [UIFont fontWithName:@"AvenirNext-Bold" size:19.0f];
    alertViewController.messageFont = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
    alertViewController.buttonTitleFont = [UIFont fontWithName:@"AvenirNext-Regular" size:alertViewController.buttonTitleFont.pointSize];
    alertViewController.cancelButtonTitleFont = [UIFont fontWithName:@"AvenirNext-Medium" size:alertViewController.cancelButtonTitleFont.pointSize];
    
//    Uncomment for some funky colors.
    [self invertAlertControllerColors:alertViewController];
    
    alertViewController.swipeDismissalGestureEnabled = YES;
    alertViewController.backgroundTapDismissalGestureEnabled = YES;
    
    return alertViewController;
}

-(void)invertAlertControllerColors:(NYAlertViewController*)alertViewController {
    alertViewController.alertViewBackgroundColor = [UIColor colorWithWhite:0.19f alpha:1.0f];
    alertViewController.alertViewCornerRadius = 10.0f;
    
    alertViewController.titleColor = [UIColor colorWithRed:0.42f green:0.78 blue:0.32f alpha:1.0f];
    alertViewController.messageColor = [UIColor colorWithWhite:0.92f alpha:1.0f];
    
    alertViewController.buttonColor = [UIColor colorWithRed:0.42f green:0.78 blue:0.32f alpha:1.0f];
    alertViewController.buttonTitleColor = [UIColor colorWithWhite:0.19f alpha:1.0f];
    
    alertViewController.cancelButtonColor = [UIColor colorWithRed:0.42f green:0.78 blue:0.32f alpha:1.0f];
    alertViewController.cancelButtonTitleColor = [UIColor colorWithWhite:0.19f alpha:1.0f];
}

-(void)prepareViewForAutolayout:(UIView *)view
{
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [view removeConstraints:self.view.constraints];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.volumeDetailsTableView) {
        return 1;
    }
    
    if (tableView == self.unsavedVolumesTableView) {
        return self.unsavedVolumes.count;
    }
// default value
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *volumeCellID = @"volumeCellID";
    
    UITableViewCell *cell;
    if (tableView == self.volumeDetailsTableView) {
        cell = [tableView dequeueReusableCellWithIdentifier:volumeCellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:volumeCellID];
        }

// -------------------------------------------------------------------------------
//	Lazy-Loading the thumbnail image here.
// -------------------------------------------------------------------------------
            // Weak pointer to our cell, for use inside the block, to prevent retain cycles.
        __weak UITableViewCell *blockCell = cell;

            // We prefer a higher quality image.
        NSURL *coverArtURL = [NSURL URLWithString:(self.volumeToConfirm.cover_art_large)?
                              self.volumeToConfirm.cover_art_large : self.volumeToConfirm.cover_art];
        [cell.imageView setImageWithURL:coverArtURL placeholderImage:[UIImage imageNamed:@"placeholder"]];
        
//        NSURLRequest *request = [NSURLRequest requestWithURL:coverArtURL];
//        
//            // Thank you, UIImageView+AFNetworking!
//        [cell.imageView setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"placeholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *responseObj, UIImage *coverArtImage) {
//            
//                // As per the docs, setImage: needs to be called by the success block.
//             [blockCell.imageView setImage:coverArtImage];
//            } failure:^(NSURLRequest * request, NSHTTPURLResponse * responseObj, NSError * error) {
//                NSLog(@"Failed to load thumbnail with error: %@", error.localizedDescription);
//            }];
            //TODO: add Stage 2: cell.textLabel.text = @"" at first...
        cell.textLabel.text = self.volumeToConfirm.title;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)", self.volumeToConfirm.author, [self yearFromDate:self.volumeToConfirm.published]];
    }
    if (tableView == self.unsavedVolumesTableView) {
        cell = self.unsavedVolumes[indexPath.row];
    }
    
    return cell;
}

#pragma mark - Helper methods

    //???
#pragma mark - GoogleClient


#pragma mark - Data Manager interface
//✅
-(void)generateTestDataIfNeeded {
    LBRDataManager *dataManager = [LBRDataManager sharedDataManager];
    [dataManager generateTestDataIfNeeded];
}

    // ✅ Part of new flow.
-(void)updateDataManagerWithNewTransientVolume:(LBRParsedVolume*)volumeToAdd {
        // Preliminaries
    LBRDataManager *dataManager = [LBRDataManager sharedDataManager];
    [dataManager updateWithNewTransientVolume:volumeToAdd];
}

@end
