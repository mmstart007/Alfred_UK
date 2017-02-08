//
//  RequestRidePopupViewController.h
//  Alfred
//
//  Created by Arjun Busani on 01/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "HUD.h"
#import <Parse/Parse.h>

@interface RequestRidePopupViewController : UIViewController


@property(strong,nonatomic)NSString* pickupAddress;
@property(strong,nonatomic)NSString* dropoffAddress;
@property(strong,nonatomic)NSString* mobile;
@property(strong,nonatomic)NSNumber* rating;
@property(strong,nonatomic)NSString* userId;
@property(strong,nonatomic)NSString* requestId;
@property(strong,nonatomic)NSString* riderName;
@property(nonatomic)BOOL isActive;
@property(nonatomic,strong)NSString* requestRideId;
@property PFObject * rideRequest;
@property(nonatomic,strong)NSDictionary* rideRequestDict;
@property(strong,nonatomic)NSString *driverCity;
@property (nonatomic)int seats;
@property(strong,nonatomic)NSString* userPic;

@property (weak, nonatomic) IBOutlet UILabel *seatsLabel;


@property (weak, nonatomic) IBOutlet UILabel *totalPrice;

@property (weak, nonatomic) IBOutlet UIView *popUpView;

@property (weak, nonatomic) IBOutlet UILabel *pickupLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropoffLabel;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *mobileLabel;
@property double pricePerSeat;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
- (IBAction)declineRequest:(id)sender;
- (IBAction)acceptRequest:(id)sender;

@end
