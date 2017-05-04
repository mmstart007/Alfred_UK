//
//  MessageBoardNewTableViewController.m
//  Alfred
//
//  Created by Arjun Busani on 26/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <Parse/Parse.h>
#import <TWMessageBarManager/TWMessageBarManager.h>


#import "MessageBoardNewTableViewController.h"
#import "SWRevealViewController.h"
#import "AlfredMessage.h"
#import "ActionSheetPicker.h"



@interface MessageBoardNewTableViewController () <UITextViewDelegate> {
    UILabel *priceLabel;
    NSDate *_travelDate;
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
@end

@implementation MessageBoardNewTableViewController

@synthesize pickupButton,dropoffButton,pickLocationViewController,pickupAddress,dropoffAddress;
@synthesize textFieldData;

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
    price = 1;
    _travelDate = nil;
    isPickupChecked = false;
    isDropoffChecked = false;
    pickupAddress = nil;
    dropoffAddress = nil;
    
    self.titleTextField.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForLocation:) name:@"didRequestForLocation" object:nil];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    UIBarButtonItem* leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(backView:)];
    UIBarButtonItem* rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(postMessage:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    self.title = @"New message";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    NSDate *currDate = [NSDate date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MMM dd, HH:mm"];
    self.dateLabel.text = [formatter stringFromDate:currDate] ;
    _travelDate = [formatter dateFromString:self.dateLabel.text];

    UIColor *borderColor = [UIColor colorWithRed:80.0f/255 green:180.0f/255 blue:190.0f/255 alpha:1.0f];
    self.notesTextView.layer.borderColor = borderColor.CGColor;
    self.notesTextView.layer.cornerRadius = 15;
    self.notesTextView.layer.masksToBounds = YES;
    self.notesTextView.layer.borderWidth = 1;
    self.cellContentView.layer.cornerRadius = 15;
    self.cellContentView.layer.masksToBounds = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForLocation" object:nil];
}

-(void)didRequestForLocation:(NSNotification *)notification{
    NSMutableArray* locationArray = [notification object];
    
    if (isItPick) {
        
        pickLat = [locationArray[0] doubleValue];
        pickLong = [locationArray[1] doubleValue];
        city = locationArray[2];
        pickupAddress = locationArray[3];
        isPickupChecked = YES;
        
        self.pickupAddressLabel.text =pickupAddress;
        
    } else {
        dropLat = [locationArray[0] doubleValue];
        dropLong = [locationArray[1] doubleValue];
        dropoffAddress = locationArray[3];
        isDropoffChecked = YES;
        self.dropoffAddressLabel.text = dropoffAddress;
    }
}

/*!
 @abstract Dimiss the view controller
 */
-(void)backView:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element {

    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MMM dd, HH:mm"];
    
    self.dateLabel.text = [formatter stringFromDate:selectedDate] ;
    
    _travelDate = selectedDate;
    
}

-(void)cancelDatePicker {

}

#pragma mark - UITextView Delegate.
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

#pragma mark - ui interactions

-(IBAction)dropoffButton:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    pickLocationViewController = [storyboard instantiateViewControllerWithIdentifier:@"PickLocationView"];
    pickLocationViewController.isPickup = NO;
    isItPick = NO;
    
    [self.navigationController pushViewController:pickLocationViewController animated:YES];
}

- (IBAction)pickupButton:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    pickLocationViewController = [storyboard instantiateViewControllerWithIdentifier:@"PickLocationView"];
    pickLocationViewController.isPickup = YES;
    isItPick = YES;
    
    [self.navigationController pushViewController:pickLocationViewController animated:YES];
}

- (IBAction)incrementSeats:(id)sender {
    
    int seats = [self.seatsLabel.text intValue];
    seats +=1;
    if(seats == 3) {
        self.incrementButton.enabled = FALSE;
        
        
    }
    self.decrementButton.enabled = TRUE;
    self.seatsLabel.text = [NSString stringWithFormat:@"%d",seats];
}

- (IBAction)decrementSeats:(id)sender {
    
    int seats = [self.seatsLabel.text intValue];
    seats -=1;
    if(seats == 1) {
        self.decrementButton.enabled = FALSE;
    }
    self.incrementButton.enabled = TRUE;
    self.seatsLabel.text = [NSString stringWithFormat:@"%d",seats];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    return YES;
}

- (IBAction)selectDate:(id)sender {
    
    [self.titleTextField resignFirstResponder];
    
    for (UIView * txt in self.view.subviews){
        if ([txt isKindOfClass:[UITextField class]] && [txt isFirstResponder]) {
            [txt resignFirstResponder];
        }
    }
    
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

    PFObject *boardMessage = [PFObject objectWithClassName:@"BoardMessage"];
    boardMessage[@"pickupAddress"] = pickupAddress;
    boardMessage[@"dropoffAddress"] = dropoffAddress;
    boardMessage[@"title"]   = self.titleTextField.text;
    boardMessage[@"desc"] = self.notesTextView.text;
    boardMessage[@"seats" ] =  [NSNumber numberWithInt:[ self.seatsLabel.text intValue]];
    
    boardMessage[@"femaleOnly"] = [NSNumber numberWithBool:self.femaleOnlySwitch.on];
    boardMessage[@"city"] = city;
    //TODO: adjust the message properly
    boardMessage[@"driverMessage"] = @NO;
    //boardMessage[@"pricePerSeat"] = [NSNumber numberWithDouble:[priceLabel.text doubleValue]];
    boardMessage [@"pickupLat"]  = [NSNumber numberWithDouble:pickLat] ;
    boardMessage[@"pickupLong"]  = [NSNumber numberWithDouble:pickLong] ;
    boardMessage[@"dropoffLat"]= [NSNumber numberWithDouble:dropLat] ;
    boardMessage[@"dropoffLong"]= [NSNumber numberWithDouble:dropLong] ;
    boardMessage[@"date"] = _travelDate;
    boardMessage[@"author"] = [PFUser currentUser];
    [boardMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError* error){
        if(error){
            NSLog(@"Failed to post new message");
            [[[UIAlertView alloc] initWithTitle:@"Message post failed" message:@"Check your network connection and try again." delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil] show];
        }else{
            
            NSLog(@"Message posted sucessfully");
            [self backView:self];
            
        }
        
        [HUD hideUIBlockingIndicator];
    }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
    
}

#pragma mark  - Table view delegate


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
