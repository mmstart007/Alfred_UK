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
    BOOL isItRetrieval;
    BOOL isChooseOnMap;
    BOOL isDriverSelected;
    BOOL isActiveDriverChosen;
    BOOL ifTimerShootsCancel;
    NSString *tempRequestID;
}
@property (weak, nonatomic) IBOutlet UIView *driverView;
@property (weak, nonatomic) IBOutlet UIImageView *driverProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *driverName;
@property (weak, nonatomic) IBOutlet UILabel *driverMobile;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *requestRideButton;
@property (weak, nonatomic) IBOutlet UIImageView *pickUpImage;
@property (weak, nonatomic) IBOutlet UIButton *pickupOrDropoffButton;
@property (weak, nonatomic) IBOutlet UILabel *pickUpLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropOffLabel;
@property (weak, nonatomic) IBOutlet UIButton *dropoffSearchButton;
@property (weak, nonatomic) IBOutlet UIButton *pickupSearchButton;
@property (weak, nonatomic) IBOutlet UIButton *rideCancelButton;
@property (weak, nonatomic) IBOutlet UILabel *availabilityBar;
@property (weak, nonatomic) IBOutlet UIImageView *dropofffIcon;
@property (weak, nonatomic) IBOutlet UIImageView *requestImageView;
@property (weak, nonatomic) IBOutlet UILabel *requestLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dropOffBottomContraint;

- (IBAction)callDriver:(id)sender;
- (IBAction)requestRide:(id)sender;
- (IBAction)centerOnUsersLocation:(id)sender;
- (IBAction)pickupAction:(id)sender;

@property(strong,nonatomic) NSString* rideID;
@property(strong,nonatomic) NSString* driverID;

@property BOOL isRideAccepted;
@property NSNumber *balance;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property(nonatomic)MKCoordinateRegion region;

@property(nonatomic)CLLocationCoordinate2D bryantPark;
@property(strong,nonatomic)PickupAnnotation *bryantParkAnn;

@property(nonatomic)CLLocationCoordinate2D pickupCoord;
@property(strong,nonatomic)PickupAnnotation *pickupAnnotation;
@property(strong,nonatomic)NSString *pickupAddress;
@property(strong,nonatomic)NSString *pickupCity;

@property(nonatomic)CLLocationCoordinate2D pickupSearchCoord;
@property(strong,nonatomic)NSString *pickupSearchAddress;
@property(strong,nonatomic)NSDictionary *retrievedDict;

@property(nonatomic)CLLocationCoordinate2D dropOffCoord;
@property(strong,nonatomic)DropoffAnnotation *dropOffAnnotation;
@property(strong,nonatomic)NSString *dropOffAddress;

@property(nonatomic)CLLocationCoordinate2D dropOffSearchCoord;
@property(strong,nonatomic)NSString *dropOffSearchAddress;
@property(strong,nonatomic)NSString *routeDistance;

@property(strong,nonatomic)CLPlacemark *pickupPlacemark;
@property(strong,nonatomic)CLPlacemark *dropoffPlacemark;

@property(strong,nonatomic)MKRoute *routeDetails;
@property(strong,nonatomic)UIBarButtonItem *cancelButton;

@property(strong,nonatomic) NSTimer *queryDriverTimer;
@property(strong,nonatomic) NSTimer *updateLocationTimer;
@property(strong,nonatomic) NSTimer *cancelRideRequestTimer;
@property(strong,nonatomic) NSTimer *cancelRideTimer;

@property(strong,nonatomic) NSMutableArray *arrayOfDriverAnnotations;
@property(strong,nonatomic) NSArray* driversArray;
@property(strong,nonatomic) NSArray *selectedDriverArray;

@property(strong,nonatomic)RideRequestDecisionViewController *requestRideDecisionPopupViewController;

@end
