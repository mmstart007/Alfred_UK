//
//  MessagePriceSubmitViewController.m
//  Alfred
//
//  Created by Piao on 4/26/17.
//  Copyright © 2017 A Ascendanet Sun. All rights reserved.
//

#import "MessagePriceSubmitViewController.h"

@interface MessagePriceSubmitViewController ()
{
    int _travelPrice;
    PFUser * user;
    NSString *firstName;
    NSDate *date;
    NSString* rideDate;
    NSString *rideTime;
    NSString* dropAddress;
    NSString* originAddress;
    int seats;
    
}

@end

@implementation MessagePriceSubmitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _travelPrice = 1.0;

    user= _selectedMessage[@"author"];
    firstName = user[@"FirstName"];
    date = _selectedMessage[@"date"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, yyyy"];
    rideDate = [formatter stringFromDate:date];
    [formatter setDateFormat:@"hh:mm"];
    rideTime = [formatter stringFromDate:date];
    dropAddress = _selectedMessage[@"dropoffAddress"];
    originAddress = _selectedMessage[@"pickupAddress"];
    seats = [_selectedMessage[@"seats"] intValue];

    self.titleLabel.text = [NSString stringWithFormat:@"You have observed the time, date and journey. Please enter a price you are willing to offer to take %@ at %@ from %@ till %@ at %@. \n You confirm that you are offering \"%d\" seats at a price\nof", firstName, rideDate, originAddress, dropAddress, rideTime, seats];
    self.navigationItem.title = @"Message Board";
    self.navigationController.navigationBar.topItem.title = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  mark - Price
-(void)updatePriceLabel{
    
    self.priceLabel.text = [NSString stringWithFormat:@"£%d", _travelPrice];
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

- (IBAction)submitMessageAction:(id)sender {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
