//
//  LBRBarcodeScannerViewController.m
//  Librarius
//
//  Created by Amitai Blickstein on 8/23/15.
//  Copyright (c) 2015 Amitai Blickstein, LLC. All rights reserved.
//
#define DBLG NSLog(@"<%@:%@:line %d, reporting!>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
#define kSpinnerFrameRect CGRectMake(0, 0, 40, 40)

#import <LGSemiModalNavViewController.h>
#import <MTBBarcodeScanner.h>
#import <MMMaterialDesignSpinner.h>

#import "LBRBarcodeScannerViewController.h"
#import "LBRSelectVolumeTableViewController.h"
#import "LBRGoogleGTLClient.h"
#import "LBRConstants.h"

#import "LBRSingleCellConfirmViewController.h"
#import <NYAlertViewController.h>

#import "LBRDataManager.h"
#import "Library.h"
#import "Volume.h"
#import "LBRParsedVolume.h"


@interface LBRBarcodeScannerViewController ()
//- (IBAction)scanOneButtonTapped:(id)sender;
- (IBAction)toggleScanningButtonTapped:(id)sender;
- (IBAction)cameraButtonTapped:(id)sender;
- (IBAction)confirmChoicesButtonTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *confirmChoicesButton;
@property (weak, nonatomic) IBOutlet UIView *scannerView;
@property (weak, nonatomic) IBOutlet UIButton *startScanningButton;
@property (weak, nonatomic) IBOutlet UITableView *uniqueBarcodesTableView;
@property (nonatomic, strong) MTBBarcodeScanner *scanner;
@property (nonatomic, strong) LBRGoogleGTLClient *googleClient;
@property (nonatomic, strong) GTLBooksVolumes *responseCollectionOfPotentialVolumeMatches;
@property (nonatomic, strong) LBRSelectVolumeTableViewController *confirmVolumeTVC;
@property (nonatomic, strong) MMMaterialDesignSpinner *spinnerView;


@property (nonatomic) BOOL isScanning;
@property (nonatomic) BOOL isNotScanning;


@end

@implementation LBRBarcodeScannerViewController

#pragma mark - Constant Strings

static NSString * const barcodeCellReuseID = @"barcodeCellReuseID";
static NSString * const volumeNib          = @"volumePresentationView";


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self generateTestDataIfNeeded];
    [self initializeProgrammaticProperties];
    LBRDataManager *dataManager = [LBRDataManager sharedDataManager];
    NSLog(@"%@",[dataManager.currentLibrary.volumes description]);
}

-(void)initializeProgrammaticProperties {
    self.googleClient = [LBRGoogleGTLClient sharedGoogleGTLClient];
    /**
     *  CLEAN: May be implicitly NO, and can remove this line.
     */
    self.isScanning = NO;
    self.scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:self.scannerView];
    self.responseCollectionOfPotentialVolumeMatches = [GTLBooksVolumes new];
    self.uniqueCodes = [NSMutableArray new];
    
    [self initializeSpinner];
    
}

-(void)initializeSpinner {
    self.spinnerView = [[MMMaterialDesignSpinner alloc] initWithFrame:kSpinnerFrameRect];
    self.spinnerView.lineWidth = 1.5f;
    self.spinnerView.tintColor = [UIColor cyanColor];
        //    self.spinnerView.hidesWhenStopped = YES; ???Uncomment if this isn't the default.
    [self.view addSubview:self.spinnerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self.scanner stopScanning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.scanner stopScanning];
    [super viewWillDisappear:animated];
}

#pragma mark - buttons

- (IBAction)toggleScanningButtonTapped:(id)sender {
        // I like how it reads, don't you?
    self.isNotScanning = !self.isScanning;
    
    if (self.isScanning) {
        [self stopScanningOps];}
    if (self.isNotScanning) {
        [self startScanningOps];}
}

- (IBAction)cameraButtonTapped:(id)sender {
    [self.scanner flipCamera];
}
/**
 *  CLEAN: TODO: LOW. Once this happens automatically (that is,
 *  scanning hits the API, pushes a confirm button, and adds
 *  a volume to the local library, then continues scanning)
 *  then this whole flow will be obsolete.
 *
 *  @param IBAction <#IBAction description#>
 *
 *  @return <#return value description#>
 */
    //And then, Magic!
- (IBAction)confirmChoicesButtonTapped:(id)sender {
//    [self getVolumesFromBarcodeData];
    DBLG
}
    
#pragma mark - Scanning

/**
 *  Stop scanning, flip the button.
 */
-(void)stopScanningOps {
    self.isScanning = NO;
    [self flipScanButtonAppearance];
    [self.scanner stopScanning];
}

/**
 *  Flip the button, start scanning, handle the completion.
 */
-(void)startScanningOps {
    
    LBRDataManager *dataManager = [LBRDataManager sharedDataManager];
    self.isScanning = YES;
    [self flipScanButtonAppearance];
// ???: Consider embedding the scanning in this: [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success)...?
   
    
    [self.scanner startScanningWithResultBlock:^(NSArray *codes) {
        for (AVMetadataMachineReadableCodeObject *code in codes) {
                // If it's a new barcode, add it to the array.
            if ([self.uniqueCodes indexOfObject:code.stringValue] == NSNotFound) {
                [self.uniqueCodes addObject:code.stringValue];
                NSLog(@"Found unique code: %@", code.stringValue);
                
                [self.spinnerView startAnimating];
                /**
                 *  TODO: pop-up confirmation with lazy loading part 1 (Empty cell)
                 */
                __block LBRSingleCellConfirmViewController *confirmSelectionViewController = [LBRSingleCellConfirmViewController new];
//                NYAlertViewController *confirmSelectionViewController = [self confirmSelectionViewController];
                    // Present the alert view controller
                [self presentViewController:confirmSelectionViewController animated:YES completion:^{
                    DBLG
                }];

                [self.googleClient queryForVolumeWithString:code.stringValue withCallback:^(GTLBooksVolume *responseVolume) {
                    [self.spinnerView stopAnimating];
                    LBRParsedVolume *volumeToConfirm = [[LBRParsedVolume alloc] initWithGoogleVolume:responseVolume];
                    confirmSelectionViewController.sourceVolume = volumeToConfirm;
                    [confirmSelectionViewController.singleCellTableView reloadData];
                    
                    /**
                     9/6 2:55pm
                     *  TODO: pop-up confirmation with text (part 2) and finally, lazy loading image (part 3). Text we have, lazy image loading is AFNetworking.
                     
                     ++If confirmed, interface with DataManager. No notifications are needed!
                     */
                }];
                
                
//                [self updateDataManagerWithNewBarcode];
//                [self.scanner stopScanning];
                /**
                 *  These next lines were for when the TableView had barcodes. No longer.
                 */
//                Update the tableview
//                [self.uniqueBarcodesTableView reloadData];
//                [self scrollToBottomCell];
               
            } else {
                    //If code is not unique/already in the tableView, then scroll the tableView to it.
                [self scrollToTargetISBNCell:[self.uniqueCodes indexOfObject:code.stringValue]];
                NSLog(@"Barcode already in list/table.");
            }
        }
    }];
}

-(void)flipScanButtonAppearance {
    if (self.isNotScanning) {
        [self.startScanningButton setTitle:@"Start Scanning" forState:UIControlStateNormal];
        [self.startScanningButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        self.startScanningButton.backgroundColor = [UIColor cyanColor];
    }
    if (self.isScanning) {
        [self.startScanningButton setTitle:@"Stop Scanning" forState:UIControlStateNormal];
        [self.startScanningButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        self.startScanningButton.backgroundColor = [UIColor redColor];
    }
}

-(NYAlertViewController*)confirmSelectionViewController {
    
    NYAlertViewController *alertViewController = [[NYAlertViewController alloc] initWithNibName:nil bundle:nil];
    
        // Set a title and message
    alertViewController.title = NSLocalizedString(@"Put this book on your coffee table?", nil);
    alertViewController.message = NSLocalizedString(@"Chuck Norris ipsum. Word out.", nil);
    
    [alertViewController addAction:[NYAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil)
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(NYAlertAction *action) {
                                                              [self dismissViewControllerAnimated:YES completion:^{
                                                                      //Add to TableView and its datasource.
                                                              }];
                                                          }]];
    
    [alertViewController addAction:[NYAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(NYAlertAction *action) {
                                                              [self dismissViewControllerAnimated:YES completion:nil];
                                                          }]];
    
    alertViewController.title = NSLocalizedString(@"Content View", nil);
    alertViewController.message = NSLocalizedString(@"Set the alertViewContentView property to add custom views to the alert view", nil);
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    UITableView *singleCellTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [contentView addSubview:singleCellTableView];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[singleCellTableView(160)]|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:NSDictionaryOfVariableBindings(singleCellTableView)]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[singleCellTableView]-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:NSDictionaryOfVariableBindings(singleCellTableView)]];
    

    
    
        // Customize appearance as desired
    alertViewController.buttonCornerRadius = 20.0f;
    alertViewController.view.tintColor = self.view.tintColor;
    
    alertViewController.titleFont = [UIFont fontWithName:@"AvenirNext-Bold" size:19.0f];
    alertViewController.messageFont = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
    alertViewController.buttonTitleFont = [UIFont fontWithName:@"AvenirNext-Regular" size:alertViewController.buttonTitleFont.pointSize];
    alertViewController.cancelButtonTitleFont = [UIFont fontWithName:@"AvenirNext-Medium" size:alertViewController.cancelButtonTitleFont.pointSize];
    
    alertViewController.swipeDismissalGestureEnabled = YES;
    alertViewController.backgroundTapDismissalGestureEnabled = YES;
    
        // Add alert actions
    [alertViewController addAction:[NYAlertAction actionWithTitle:NSLocalizedString(@"Done", nil)
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(NYAlertAction *action) {
                                                              [self dismissViewControllerAnimated:YES completion:nil];
                                                          }]];
    return alertViewController;
}

/**
 *  Presents an alert asking the user to confirm her choice.
 */
-(void)confirmSVolumeSelection {
        //"Add <#book title#> to 'CoffeeTable'?
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.uniqueCodes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:barcodeCellReuseID forIndexPath:indexPath];
    cell.textLabel.text = self.uniqueCodes[indexPath.row];
    return cell;
}

#pragma mark - Helper methods

-(void)scrollToBottomCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.uniqueCodes.count - 1 inSection:0];
    [self.uniqueBarcodesTableView scrollToRowAtIndexPath:indexPath
                                        atScrollPosition:UITableViewScrollPositionTop
                                                animated:YES];
}

-(void)scrollToTargetISBNCell:(NSUInteger)idxOfTarget {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.uniqueCodes.count - 1 inSection:0];
//    [self.uniqueBarcodesTableView scrollToRowAtIndexPath:indexPath
//                                        atScrollPosition:UITableViewScrollPositionTop
//                                                animated:YES];
}

    //???
#pragma mark - GoogleClient



-(void)presentVolumesSemiModally {
    if (self.confirmVolumeTVC) {
            //This is the nav controller
        LGSemiModalNavViewController *semiModal = [[LGSemiModalNavViewController alloc]initWithRootViewController:self.confirmVolumeTVC];
            //Make sure to set a height on the view controller here.
        semiModal.view.frame = CGRectMake(0, 0, self.view.frame.size.width * 0.95, self.view.frame.size.height * 0.65);
        
            //Selected customization properties, see more in the header of the LGSemiModalNavViewController
        semiModal.backgroundShadeColor = [UIColor blackColor];
        semiModal.animationSpeed = 0.35f;
        semiModal.tapDismissEnabled = YES;
        semiModal.backgroundShadeAlpha = 0.4;
        semiModal.scaleTransform = CGAffineTransformMakeScale(.94, .94);
        
        [self presentViewController:semiModal animated:YES completion:nil];
    }
}

#pragma mark - Data Manager interface

-(void)generateTestDataIfNeeded {
    LBRDataManager *dataManager = [LBRDataManager sharedDataManager];
    [dataManager generateTestDataIfNeeded];
}

/**
 *  Updates dataManager's copy of the barcodes, then posts notification (for googleClient, basically).
 */
-(void)updateDataManagerWithNewBarcode {
    LBRDataManager *dataManager = [LBRDataManager sharedDataManager];
    if (!dataManager.uniqueCodes) {
        dataManager.uniqueCodes = [NSMutableArray new];
    }
    
    [dataManager.uniqueCodes addObject:[self.uniqueCodes lastObject]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:barcodeAddedNotification object:dataManager.uniqueCodes];
}

/* CLEAN
 * This snippet will scan once, then stop.
 
 - (IBAction)scanOneButtonTapped:(id)sender {
 [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success) {
 if (success) {
 [scanner startScanningWithResultBlock:^(NSArray *codes) {
 AVMetadataMachineReadableCodeObject *code = [codes firstObject];
 NSLog(@"Found barcode: %@", code.stringValue);
 [self displayBarcode:code.stringValue];
 [scanner stopScanning];
 }];
 } else {
 //The user denied access to the camera
 NSLog(@"The user denied access to the camera...?");
 }
 }];
 }
 */

@end
