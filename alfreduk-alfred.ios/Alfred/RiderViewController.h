//
//  MainViewController.h
//  Alfred
//
//  Created by Arjun Busani on 24/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PickupAnnotation.h"
#import "DropoffAnnotation.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "HUD.h"
#import "DriverAnnotation.h"
#import "RideRequestDecisionViewController.h"
#import "RideRatingViewController.h"
#import "DriverCalloutPopupViewController.h"
#import "DriverCalloutNotActiveViewController.h"

@interface RiderViewController : UIViewController<UIGestureRecognizerDelegate,MKMapViewDelegate,CLLocationManagerDelegate, UIAlertViewDelegate>{
    BOOL mapChangedFromUserInteraction;
    BOOL ifDrop;
    BOOL routeFixed;
    BOOL withinCountry;
    BOOL isItDropSearch;
    BOOL isItSearchResult;
    BOOL inRequest;
    BOOL ifTimerShootsCancel;
    BOOL isItRetrieval;
    BOOL isDriverSelected;
    BOOL isActiveDriverChosen;
    NSString *tempRequestID;
}
@property (weak, nonatomic) IBOutlet UIView *driverView;
@property (weak, nonatomic) IBOutlet UIImageView *driverProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *driverName;
@property (weak, nonatomic) IBOutlet UILabel *driverMobile;
@property (weak, nonatomic) IBOutlet UILabel *driverRating;
@property NSInteger balance;
- (IBAction)moreInfo:(id)sender;
- (IBAction)callDriver:(id)sender;

@property(strong,nonatomic)NSArray *rideEndArray;



@property(strong,nonatomic)NSString* rideID;
@property(strong,nonatomic) NSString* driverPhone;

@property(strong,nonatomic)DriverCalloutPopupViewController *driverCalloutPopupViewController;
@property(strong,nonatomic)DriverCalloutNotActiveViewController *driverCalloutNotActiveViewController;

@property(strong,nonatomic)RideRatingViewController *rideRatingViewController;

@property(strong,nonatomic)RideRequestDecisionViewController *requestRideDecisionPopupViewController;
@property BOOL isRideAccepted;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dropOffBottomContraint;
- (IBAction)requestRide:(id)sender;

//this button will be visible when the route has been selected properly
@property (weak, nonatomic) IBOutlet UIButton *requestRideButton;

//the map view
@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@property (strong, nonatomic) CLLocationManager *locationManager;

//center map view on user location
- (IBAction)centerOnUsersLocation:(id)sender;



@property (weak, nonatomic) IBOutlet UIImageView *pickUpImage;
@property(nonatomic)MKCoordinateRegion region;

@property(nonatomic)CLLocationCoordinate2D bryantPark;
@property(strong,nonatomic)PickupAnnotation *bryantParkAnn;


//this two items represent the callout button and pin for setting pickup/dropoff location
@property (weak, nonatomic) IBOutlet UIButton *pickupOrDropoffButton;
@property (weak, nonatomic) IBOutlet UILabel *pickUpLabel;



- (IBAction)pickupAction:(id)sender;

@property(nonatomic)CLLocationCoordinate2D pickupCoord;
@property(strong,nonatomic)PickupAnnotation *pickupAnnotation;
@property(strong,nonatomic)NSString *pickupAddress;
@property(strong,nonatomic)NSString *pickupCity;


@property(nonatomic)CLLocationCoordinate2D pickupSearchCoord;
@property(strong,nonatomic)NSString *pickupSearchAddress;

@property (weak, nonatomic) IBOutlet UILabel *dropOffLabel;

@property(nonatomic)CLLocationCoordinate2D dropOffCoord;
@property(strong,nonatomic)DropoffAnnotation *dropOffAnnotation;
@property(strong,nonatomic)NSString *dropOffAddress;

@property(nonatomic)CLLocationCoordinate2D dropOffSearchCoord;
@property(strong,nonatomic)NSString *dropOffSearchAddress;

@property (weak, nonatomic) IBOutlet UILabel *dropoffLocationLabel;

@property (weak, nonatomic) IBOutlet UIButton *dropoffSearchButton;
@property (weak, nonatomic) IBOutlet UIButton *pickupSearchButton;

@property(strong,nonatomic)CLPlacemark *pickupPlacemark;
@property(strong,nonatomic)CLPlacemark *dropoffPlacemark;

@property(strong,nonatomic)MKRoute *routeDetails;

@property(strong,nonatomic)UIBarButtonItem *cancelButton;

@property (weak, nonatomic) IBOutlet UILabel *availabilityBar;

@property(strong,nonatomic) NSTimer *driverLocationTimer;
@property(strong,nonatomic) NSTimer *cancelRideRequestTimer;

@property(strong,nonatomic)NSArray* driversArray;
@property(strong,nonatomic)NSString *routeDistance;
@property(strong,nonatomic)NSMutableArray *driverIDArray;
@property(strong,nonatomic)NSArray *driverSelectedArray;
@property(strong,nonatomic)NSNumber *driverSelectedID;

@property(strong,nonatomic)NSMutableArray *arrayOfDriverAnnotations;
@property (weak, nonatomic) IBOutlet UIImageView *dropofffIcon;


@property (weak, nonatomic) IBOutlet UIImageView *requestImageView;
@property (weak, nonatomic) IBOutlet UILabel *requestLabel;
@property(strong,nonatomic)NSDictionary *retrievedDict;


@end
