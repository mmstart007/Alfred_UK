//
//  DriverHeadViewController.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 10/15/15.
//  Copyright © 2015 A Ascendanet Sun. All rights reserved.
//

#import "DriverHeadViewController.h"

@interface DriverHeadViewController (){

    PFObject *_rideRequest;
    NSString *_userPhone;
}

@property (weak, nonatomic) IBOutlet UILabel *riderNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickupAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropoffAddressLabel;
- (IBAction)routeToDropoff:(id)sender;
- (IBAction)routeToPickup:(id)sender;
- (IBAction)centerOnPickupLocation:(id)sender;
- (IBAction)centerOnDropoffLocation:(id)sender;

- (IBAction)call:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *riderNameLabel;
@end

@implementation DriverHeadViewController
@synthesize  delegate;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)setRideRequest:(PFObject *)rideRequest{
    _rideRequest = rideRequest;
    [self updateView];
}

-(void)updateView{
    //UIView *view = self.view;
    PFUser *user = _rideRequest[@"requestedBy"];
    [self.riderNameLabel setText:user[@"FullName"] ];
    [self.riderNumberLabel setText:user[@"Phone"]];
    [self.pickupAddressLabel setText:_rideRequest[@"pickupAddress"]];
    [self.dropoffAddressLabel setText:_rideRequest[@"dropoffAddress"]];
    _userPhone = user[@"Phone"];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)routeToDropoff:(id)sender {
    [delegate didRequestForRouteToDropoff:_rideRequest];
    
}

- (IBAction)routeToPickup:(id)sender {
    [delegate didRequestForRouteToPickup:_rideRequest];
}

- (IBAction)centerOnPickupLocation:(id)sender {
    [delegate didRequestForShowPickupOnMap:_rideRequest];
    
}

- (IBAction)centerOnDropoffLocation:(id)sender {
    
    [delegate didRequestForShowDropoffOnMap:_rideRequest];
    
}
- (IBAction)call:(id)sender {
    
    
    NSString *phoneNumber = [@"telprompt://" stringByAppendingString:_userPhone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    //TODO: call user
}
@end
