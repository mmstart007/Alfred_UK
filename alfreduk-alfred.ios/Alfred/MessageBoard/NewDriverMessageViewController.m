//
//  NewDriverMessageViewController.m
//  Pods
//
//  Created by Miguel Angel Carvajal on 2/15/16.
//
//

#import <Parse/Parse.h>
#import <TWMessageBarManager/TWMessageBarManager.h>

#import "NewDriverMessageViewController.h"
#import "MessageBoardNewTableViewController.h"
#import "SWRevealViewController.h"
#import "AlfredMessage.h"
#import "ActionSheetPicker.h"
#import "HUD.h"


@interface NewDriverMessageViewController () <UITextViewDelegate> {

    NSDate *_travelDate;
    int _travelPrice;
    int _numberOfSeats;
    BOOL isItPick;
    BOOL _isPickupChecked;
    BOOL _isDropoffChecked;

}

@property (weak, nonatomic) IBOutlet UIView *cellContentView;
@property (weak, nonatomic) IBOutlet UILabel *pickupAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropoffAddressLabel;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UILabel *seatsLabel;
@property (weak, nonatomic) IBOutlet UISwitch *femaleOnlySwitch;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;
@property (weak, nonatomic) IBOutlet UIButton *incrementButton;
@property (weak, nonatomic) IBOutlet UIButton *decrementButton;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *priceDecrementButton;
@property (weak, nonatomic) IBOutlet UIButton *priceIncrementButton;

@end

@implementation NewDriverMessageViewController

@synthesize pickupAddress,dropoffAddress;
@synthesize pickLocationViewController;
@synthesize pickLat,pickLong,dropLat,dropLong,city;


- (void)hideNavigationController {
    [self.navigationController.navigationBar setTranslucent:YES];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isItPick = true;
    _travelPrice = 1.0;
    [self updatePriceLabel];

    NSDate *currDate = [NSDate date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MMM dd, HH:mm"];
    self.dateLabel.text = [formatter stringFromDate:currDate] ;
    _travelDate = [formatter dateFromString:self.dateLabel.text];
    
    _isPickupChecked = false;
    _isDropoffChecked = false;
    pickupAddress = nil;
    dropoffAddress = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForLocation:) name:@"didRequestForLocation" object:nil];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    
    UIBarButtonItem* leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(backView:)];
    UIBarButtonItem* rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(postMessage:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    self.title = @"New message";

    //self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIColor *borderColor = [UIColor colorWithRed:80.0f/255 green:180.0f/255 blue:190.0f/255 alpha:1.0f];
    self.notesTextView.layer.borderColor = borderColor.CGColor;
    self.notesTextView.layer.cornerRadius = 15;
    self.notesTextView.layer.masksToBounds = YES;
    self.notesTextView.layer.borderWidth = 1;
    self.cellContentView.layer.cornerRadius = 15;
    self.cellContentView.layer.masksToBounds = YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForLocation" object:nil];
}

-(void)didRequestForLocation:(NSNotification *)notification{
    NSMutableArray* locationArray = [notification object];
    
    if (isItPick) {
        pickLat = [locationArray[0] doubleValue];
        pickLong = [locationArray[1] doubleValue];
        city = locationArray[2];
        pickupAddress = locationArray[3];
        _isPickupChecked = YES;
        
        self.pickupAddressLabel.text =pickupAddress;
        
    } else {
        dropLat = [locationArray[0] doubleValue];
        dropLong = [locationArray[1] doubleValue];
        dropoffAddress = locationArray[3];
        _isDropoffChecked = YES;
        self.dropoffAddressLabel.text = dropoffAddress;
    }
}

/*!
 @abstract Dimiss the view controller
 */
-(void)backView:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil]
    ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*!
 @abstract Post a new message to the message board, called when clicken on the button, post a message
 */
-(void)postMessage:(id)sender{
    
    //TODO validate fields here
    
    if(pickupAddress == nil){

        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Error! "
                                                       description:@"Please enter a pickup location"
                                                              type:TWMessageBarMessageTypeError];
        return;

    }
    if(dropoffAddress==  nil){
        
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Error! "
                                                       description:@"Please enter a dropoff location"
                                                              type:TWMessageBarMessageTypeError];
        return;
        return;
    }
    if(!(self.titleTextField.text.length > 4)){
        
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Error! "
                                                       description:@"Please enter a title for your travel"
                                                              type:TWMessageBarMessageTypeError];
        return;
        return;
    }
    if(_travelDate == nil){
        
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Error! "
                                                       description:@"Please enter a travel date"
                                                              type:TWMessageBarMessageTypeError];
        return;
        return;
    }
    if(!(_notesTextView.text.length > 4)){
        
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Error! "
                                                       description:@"Please give some notes of your travel"
                                                              type:TWMessageBarMessageTypeError];
        return;
        return;
    }

    [HUD showUIBlockingIndicatorWithText:@"Please wait.."];
    
    [PFCloud callFunctionInBackground:@"CreateBoardMessage"
                       withParameters:@{@"driverMessage": @YES,
                                        @"status": @"",
                                        @"seats": [NSNumber numberWithInt:[ self.seatsLabel.text intValue]],
                                        @"pricePerSeat": [NSNumber numberWithDouble:_travelPrice],
                                        @"pickupLat": [NSNumber numberWithDouble:pickLat],
                                        @"pickupLong": [NSNumber numberWithDouble:pickLong],
                                        @"dropoffLat": [NSNumber numberWithDouble:dropLat],
                                        @"dropoffLong": [NSNumber numberWithDouble:dropLong],
                                        @"pickupAddress": pickupAddress,
                                        @"dropoffAddress": dropoffAddress,
                                        @"title": self.titleTextField.text,
                                        @"desc": self.notesTextView.text,
                                        @"city": city,
                                        @"date": _travelDate,
                                        @"femaleOnly": [NSNumber numberWithBool:self.femaleOnlySwitch.on]}
                                block:^(NSString *success, NSError *error) {
                                    [HUD hideUIBlockingIndicator];
                                    if (!error) {
                                        NSLog(@"Message posted sucessfully");
                                        [self backView:self];
                                    } else {
                                        NSLog(@"Failed to post new message");
                                        [[[UIAlertView alloc] initWithTitle:@"Message post failed" message:@"Check your network connection and try again." delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil] show];
                                    }
                                }];

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
    
}

#pragma mark - UITextField Delegate.
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - UITextView Delegate.
- (void)textViewDidChangeSelection:(UITextView *)textView{
    if ([textView.text isEqualToString:@"Give some details"] && [textView.textColor isEqual:[UIColor lightGrayColor]])[textView setSelectedRange:NSMakeRange(0, 0)];
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    [textView setSelectedRange:NSMakeRange(0, 0)];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length != 0 && [[textView.text substringFromIndex:1] isEqualToString:@"Give some details"] && [textView.textColor isEqual:[UIColor lightGrayColor]]){
        textView.text = [textView.text substringToIndex:1];
        textView.textColor = [UIColor blackColor]; //optional
        
    } else if(textView.text.length == 0) {
        textView.text = @"Give some details";
        textView.textColor = [UIColor lightGrayColor];
        [textView setSelectedRange:NSMakeRange(0, 0)];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Give some details";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (textView.text.length > 1 && [textView.text isEqualToString:@"Give some details"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    
    return YES;
}

#pragma  mark - Price
-(void)updatePriceLabel {

    self.priceLabel.text = [ NSString stringWithFormat:@"£%d", _travelPrice];
}

#pragma mark - UIButton Action.
- (IBAction)incrementSeats:(id)sender {
    
    int seats = [self.seatsLabel.text intValue];
    seats +=1;
    if(seats == 3){
        self.incrementButton.enabled = FALSE;
    }
    self.decrementButton.enabled = TRUE;
    self.seatsLabel.text = [NSString stringWithFormat:@"%d",seats];
}

- (IBAction)decrementSeats:(id)sender {
    
    int seats = [self.seatsLabel.text intValue];
    seats -=1;
    if(seats == 1){
        self.decrementButton.enabled = FALSE;
    }
    self.incrementButton.enabled = TRUE;
    self.seatsLabel.text = [NSString stringWithFormat:@"%d",seats];
}

- (IBAction)decrementPrice:(id)sender {
    
    self.priceIncrementButton.enabled = YES;
    
    _travelPrice = _travelPrice - 1;
    if(_travelPrice == 1){
        self.priceDecrementButton.enabled = NO;
    }
    [self updatePriceLabel];
}

- (IBAction)incrementPrice:(id)sender {
    self.priceDecrementButton.enabled = YES;
    
    _travelPrice = _travelPrice + 1;
    if(_travelPrice == 50){
        self.priceIncrementButton.enabled = NO;
    }
    [self updatePriceLabel];
}

-(IBAction)dropoffButton:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    pickLocationViewController = [storyboard instantiateViewControllerWithIdentifier:@"PickLocationView"];
    pickLocationViewController.isPickup = NO;
    isItPick = NO;
    [self.navigationController pushViewController:pickLocationViewController animated:YES];
}

-(IBAction)pickupButton:(id)sender{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    pickLocationViewController = [storyboard instantiateViewControllerWithIdentifier:@"PickLocationView"];
    pickLocationViewController.isPickup = YES;
    isItPick = YES;
    
    [self.navigationController pushViewController:pickLocationViewController animated:YES];
}

- (IBAction)selectDate:(id)sender {
    
    //hide keyboard
    [self.titleTextField resignFirstResponder];
    
    int two_months = 30 * 24 *60 *60;
    NSDate *today = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDate *maxDate = [NSDate dateWithTimeIntervalSinceNow:two_months];
    
    
    //create a date picker alowing only 2 month from now
    ActionSheetDatePicker *picker = [[ActionSheetDatePicker alloc] initWithTitle:@"Travel date"
                                                                  datePickerMode:UIDatePickerModeDateAndTime
                                                                    selectedDate:today
                                                                     minimumDate:today
                                                                     maximumDate:maxDate
                                                                          target:self
                                                                          action:@selector(dateWasSelected:element:)
                                                                    cancelAction:@selector(cancelDatePicker)
                                                                          origin:sender];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:nil];
    [doneButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor blackColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [picker setDoneButton:doneButton];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:nil];
    [cancelButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor blackColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [picker setCancelButton:cancelButton];
    
    [picker showActionSheetPicker];
}

- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element {
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MMM dd, HH:mm"];
    
    self.dateLabel.text = [formatter stringFromDate:selectedDate] ;
    
    _travelDate = selectedDate;
    
}

-(void)cancelDatePicker {
    
}



@end

