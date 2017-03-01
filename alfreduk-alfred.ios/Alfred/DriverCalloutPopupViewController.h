//
//  DriverCalloutPopupViewController.h
//  Alfred
//
//  Created by Arjun Busani on 09/04/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "HCSStarRatingView.h"
#import <Parse/Parse.h>

@import MapKit;

@interface DriverCalloutPopupViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pricePerSeatLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *ladiesOnlyLabel;
@property (weak, nonatomic) IBOutlet UILabel *destinationAddressLabel;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *seatsSelectView;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;
@property (weak, nonatomic) IBOutlet UILabel *cellPhoneLabel;


- (IBAction)selectAlfred:(id)sender;
- (IBAction)rejectAlfred:(id)sender;


@property(nonatomic,strong)NSString* dropAddress;
@property(nonatomic,strong)NSString* requestRideId;
@property(nonatomic,strong)NSNumber* availbleSeats;
@property(nonatomic,strong)NSString* driverRating;
@property(nonatomic,strong)NSString* driverMobile;
@property(nonatomic,strong)NSString* driverProfilePic;
@property(strong,nonatomic)NSString *driverName;
@property(nonatomic,strong)NSString* messageBoardId;
@property(nonatomic,strong)PFObject* driverLocation;

@end
