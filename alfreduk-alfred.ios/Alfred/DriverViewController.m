    //
//  DriverViewController.m
//  Alfred
//
//  Created by Arjun Busani on 25/02/15.
//  Modified by Miguel Carvajal on 23/08/2015
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "DriverViewController.h"
#import "SWRevealViewController.h"
#import "RiderViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Parse/Parse.h>
#import "RideSettingsViewController.h"
#import "DriverHeadViewController.h"
#import "CHDraggingCoordinator.h"
#import "CHDraggableView.h"
#import "CHDraggableView+Avatar.h"
#import "KLCPopup/KLCPopup.h"

const int RIDE_CANCEL_EXPIRATION_TIME = 5*60; // in seconds

@import MapKit;

@interface DriverViewController ()<SWRevealViewControllerDelegate>
{
    double myLatitude;
    double myLongitude;
    PFGeoPoint *destinationLocation;
    NSString *destinationAddress;
    PFGeoPoint *currentLocation;
    NSString *currentAddress;
    
    UIBarButtonItem *cancelButton;
    PFUser * passenger;
    PFObject *_lastRideInfo;
    PFObject *_currentDriverPath;
    CLLocationCoordinate2D destinationCoordinate;
    CLLocationCoordinate2D driverCoordinate;
    
    //handle the drawing of chat heads
    CHDraggingCoordinator *_draggingCoordinator;
    KLCPopup *popup;
    NSTimer *_mapCenterTimer ;
    UIBarButtonItem *_revealButtonItem;
    double ratingData;
    
}

@property (nonatomic) NSNumber *rideConfigured;
@property (nonatomic) NSNumber *destinationSetted;


@end

@implementation DriverViewController

@synthesize mapView,region;
@synthesize startRideButton;
@synthesize cancelButton,locationManager;
@synthesize cancelRideRequestTimer,driverLocationTimer,cancelRideTimer;
@synthesize dropOffAddress,dropOffAnnotation;
@synthesize userView,bottomLayoutConstrint;
@synthesize userProfilePic,userMobile,userName,ratingView;
@synthesize userPhone;
@synthesize endMessageBoardButton;
@synthesize messageBoardUsersBGView;
@synthesize routeDetails;
@synthesize requestRidePopupViewController, requestRideDecisionPopupViewController;
@synthesize rideID;

@synthesize cancelRideButton,callButton;


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // user status configuration
    self.rideConfigured = @NO;
    self.destinationSetted = @NO;
    
    _lastRideInfo = nil;
    _currentDriverPath = nil;

    // Add all Notifications
    [self watchForNotifications];
    [self configureView];
    [self checkExistingPathway];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
    
    if (authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
        authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        [self.locationManager startUpdatingLocation];
        mapView.showsUserLocation = YES;
        mapView.userTrackingMode=YES;
        
        CLLocationCoordinate2D coord = mapView.userLocation.location.coordinate;
        MKCoordinateRegion intialRegion = MKCoordinateRegionMakeWithDistance(coord, 1000.0, 1000.0);
        [mapView setRegion:intialRegion animated:YES];
        
    }
    
    currentAddress = @"Undeterminated";
    
}

-(void)setupChatHeads {
    _draggingCoordinator = [[CHDraggingCoordinator alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow] draggableViewBounds:self.view.bounds];
    _draggingCoordinator.snappingEdge = CHSnappingEdgeBoth;
}

#pragma mark - Register all Notifications

-(void)watchForNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForStoppingAllMappingServices:) name:@"didRequestForStoppingAllMappingServices" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForSearchResult:) name:@"didRequestForSearchResult" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConfigureRide:) name:@"didConfigureRide" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAcceptRide:) name:@"didAcceptRide" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForRideRequest:) name:@"didRequestForRideRequest" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForRideRequestCancel:) name:@"didRequestForRideRequestCancel" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForOpenRatingView:) name:@"didRequestForOpenRatingView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForRideAcceptedForDriver:) name:@"didRequestForRideAcceptedForDriver" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndedRating:) name:@"didEndedRating" object:nil];
    
}

#pragma mark - Local Notification

// called when the driver search the address on the SearchViewController
- (void) didRequestForSearchResult:(NSNotification *)notification {
    
    self.navigationItem.rightBarButtonItem =  cancelButton;
    
    NSLog(@"Search finished");
    CLPlacemark *placemark =  [notification object];
    
    self.locationSearchButton.enabled = NO;
    
    startRideButton.hidden = NO;
    destinationCoordinate = placemark.location.coordinate;
    
    NSDictionary * addressDictionary = placemark.addressDictionary;
    NSMutableArray *formatedAddressLines = [addressDictionary valueForKey:@"FormattedAddressLines"];
    [formatedAddressLines removeLastObject];
    [formatedAddressLines removeLastObject];
    
    NSString *address = [formatedAddressLines componentsJoinedByString:@", "];

    self.rideConfigured = @NO;
    [self setDestinationOnMapWithCoordinate:destinationCoordinate andAddress:address];

}

// called when the driver saves the data properly on the settings view
-(void)didConfigureRide:(NSNotification *)notification {
    
    self.rideConfigured = @YES;
    startRideButton.enabled = NO;
    
    PFObject *object = notification.userInfo[@"driverPathwayObject"];
    _currentDriverPath = object;
    NSLog(@"Created Driver Path Object ======= %@", object);
}

// called when the driver accept the Ride on the RequestRidePopupView
-(void)didAcceptRide:(NSNotification *)notification {
    [cancelRideTimer invalidate];
    cancelRideTimer = nil;
    
    cancelRideTimer = [NSTimer scheduledTimerWithTimeInterval: RIDE_CANCEL_EXPIRATION_TIME
                                                              target: self
                                                            selector: @selector(didCancelRide:)
                                                            userInfo: nil
                                                             repeats: NO ];
    [UIView animateWithDuration:2.0 animations:^{
        userView.hidden = NO;
        startRideButton.enabled = YES;
        self.navigationItem.rightBarButtonItem = nil;
    }];
}

// called when the Driver did rated to the Passenger on the RideRatingView
-(void)didEndedRating:(NSNotification *)notification {
    cancelRideButton.enabled = YES;
    [self checkExistingPathway];
    
}

-(void)didCancelRide:(id)sender {
    cancelRideButton.enabled = NO;
}

// Ride End and Popup the RideRequestDecisionView
-(void)didRequestForRideEnd {
    NSString *rideCost = _lastRideInfo[@"price"];
    double rideCostDouble = [rideCost doubleValue];
    NSString* decisionStr = [NSString stringWithFormat:@"Ride Cost: £%.2f", rideCostDouble / 100];
    
    requestRideDecisionPopupViewController = [[RideRequestDecisionViewController alloc] initWithNibName:@"RideRequestDecisionViewController" bundle:nil];
    requestRideDecisionPopupViewController.decision = decisionStr;
    requestRideDecisionPopupViewController.isAccepted = NO;
    requestRideDecisionPopupViewController.openRatingView = YES;
    [requestRideDecisionPopupViewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:requestRideDecisionPopupViewController animated:YES completion:nil];
    
}

-(void)didRequestForStoppingAllMappingServices:(id)sender{
    [self.locationManager stopUpdatingLocation];
    
    [driverLocationTimer invalidate];
    driverLocationTimer = nil;
    [_mapCenterTimer invalidate];
    _mapCenterTimer = nil;
}

-(void)configureNavigationBar {
    
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationItem.title = @"Driver's Map";
    
}

#pragma mark - Push Notification Receiver

-(void)didRequestForRideRequest:(NSNotification *)notification
{
    NSLog(@"Ride Request Notification ========== %@", notification);
    
    //isDriverAccepted
    NSString* rideId  = [notification object];
    
    //the driver should be active and enabled, not sure
    [PFCloud callFunctionInBackground:@"GetRide"
                       withParameters:@{@"rideId": rideId}
                                block:^(PFObject *object, NSError *error) {
                                    if (!error) {
                                        NSLog(@"Get Ride request success when the Driver received Riede request from Passenger !!!!");
                                        [self processRideRequest:object];
                                    } else {
                                        NSLog(@"Get Ride request Failed !!!!");
                                        [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Accept" otherButtonTitles:nil] show];
                                    }
                                }];
}

#pragma mark - Ride Mode
#pragma mark - Ride Request

/*
 * Called when a new ride request arrive, to handle it and take the pertinent
 * actions
 */

-(void)processRideRequest:(PFObject *) rideRequest{
    
    NSLog(@"RideRequest Object ==================\n %@", rideRequest);
    
    rideID = rideRequest.objectId;
    _lastRideInfo = rideRequest;
    passenger = rideRequest[@"passenger"]; // user
    ratingData = [passenger[@"passengerRating"] doubleValue];
    userPhone = passenger[@"Phone"];
    NSString* riderName = passenger[@"FullName"];
    NSString* userPic =passenger[@"ProfilePicUrl"];
    int seats =[rideRequest[@"seats"] intValue];

    requestRidePopupViewController = [[RequestRidePopupViewController alloc] initWithNibName:@"RequestRidePopupViewController" bundle:nil];
    requestRidePopupViewController.rideRequest = rideRequest;
    requestRidePopupViewController.pricePerSeat = [_currentDriverPath[@"pricePerSeat"] doubleValue] / 100;
    requestRidePopupViewController.pickupAddress = rideRequest[@"pickupAddress"];
    requestRidePopupViewController.dropoffAddress = rideRequest[@"dropoffAddress"];
    requestRidePopupViewController.rating = ratingData;
    requestRidePopupViewController.requestId = rideRequest.objectId;
    requestRidePopupViewController.userId = passenger.objectId;
    requestRidePopupViewController.requestRideId = rideID;
    requestRidePopupViewController.riderName = riderName;
    requestRidePopupViewController.mobile = userPhone;
    requestRidePopupViewController.userPic = userPic;
    requestRidePopupViewController.seats = seats;
    
    // Set all info to the UserView
    userName.text = riderName;
    userMobile.text = userPhone;
    ratingView.value = ratingData;
    if (![userPic isKindOfClass:[NSNull class]]) {
        [userProfilePic sd_setImageWithURL:[NSURL URLWithString:userPic] placeholderImage:[UIImage imageNamed:@"blank profile"]];
        userProfilePic.layer.cornerRadius = userProfilePic.frame.size.height / 2;
        userProfilePic.layer.masksToBounds = YES;
        userProfilePic.layer.borderWidth = 0;
    }
    [requestRidePopupViewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:requestRidePopupViewController animated:YES completion:nil];

}

#pragma mark - Ride Accepted or Rejected and Others(Not in use)

-(void)didRequestForRideAcceptedForDriver:(NSNotification *)notification
{
    requestRideDecisionPopupViewController = [[RideRequestDecisionViewController alloc] initWithNibName:@"RideRequestDecisionViewController" bundle:nil];
    requestRideDecisionPopupViewController.decision = @"You have been accepted as the driver";
    requestRideDecisionPopupViewController.isAccepted = YES;
    [requestRideDecisionPopupViewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:requestRideDecisionPopupViewController animated:YES completion:nil];
}

#pragma mark - Ride Cancel Notification

-(void)didRequestForRideRequestCancel:(NSNotification *)notification
{
    // Back to the Destination select status
    self.rideConfigured= @YES;
    userView.hidden = YES;
    startRideButton.enabled = NO;
    //[self setDestinationTouchedUpInside:nil];
    
    NSString *currentRideId = [notification object];
    if ([currentRideId isEqualToString:rideID]) {
        requestRideDecisionPopupViewController = [[RideRequestDecisionViewController alloc] initWithNibName:@"RideRequestDecisionViewController" bundle:nil];
        NSString *decision = @"Passenger has cancelled ride.";
        requestRideDecisionPopupViewController.decision = decision;
        requestRideDecisionPopupViewController.isAccepted = NO;
        [requestRideDecisionPopupViewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:requestRideDecisionPopupViewController animated:YES completion:^{
            
        }];
    } else {
        NSLog(@"Invalid RideID ============ ");
    }
}

#pragma mark - Start of Ride (Not in use)

-(void)startRide:(id)sender{
    
    [self.mapView removeOverlay:routeDetails.polyline];
    [mapView removeAnnotation:dropOffAnnotation];
    
    [self requestRouteToUser];
    
    [startRideButton setTitle:@"NAVIGATE TO DESTINATION" forState:UIControlStateNormal];
    [startRideButton removeTarget:self action:@selector(startRide:) forControlEvents:UIControlEventTouchUpInside];
    [startRideButton addTarget:self action:@selector(navigateToDestination:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Ride cancell

- (IBAction)rejectRideForUser:(id)sender {
    
    [HUD showUIBlockingIndicatorWithText:@"Canceling ..."];
    [PFCloud callFunctionInBackground:@"DeleteRide"
                       withParameters:@{@"rideId": rideID,
                                        @"reason": @"DRIVER_CANCELED_RIDE"}
                                block:^(NSString *success, NSError *error) {
                                    [HUD hideUIBlockingIndicator];
                                    if (!error) {
                                        [UIView animateWithDuration:2.0 animations:^{
                                            self.rideConfigured= @YES;
                                            userView.hidden = YES;
                                            startRideButton.enabled = NO;
                                        }];
                                        NSLog(@"Cancel Ride success !!!!!");
                                    } else {
                                        NSLog(@"Driver cancel the Ride Failed !!!!");
                                    }
                                }];
}

#pragma mark - Ending of Ride (Not in use)

-(void)endRide:(id)sender{
    
    [mapView removeOverlay:routeDetails.polyline];
    [mapView removeAnnotation:dropOffAnnotation];
    [startRideButton removeTarget:self action:@selector(endRide:) forControlEvents:UIControlEventTouchUpInside];
    [startRideButton setHidden:YES];
    bottomLayoutConstrint.constant = 80;
    [userView setHidden:YES];
    self.navigationItem.leftBarButtonItem = _revealButtonItem;
    self.destinationSetted = @NO;
    self.rideConfigured = @NO;
    
    [HUD showUIBlockingIndicatorWithText:@"Ending ..."];
    [PFCloud callFunctionInBackground:@"DeleteRide"
                       withParameters:@{@"rideId": rideID,
                                        @"reason": @"DRIVER_ENDED_RIDE"}
                                block:^(NSString *success, NSError *error) {
                                    [HUD hideUIBlockingIndicator];
                                    if (!error) {

                                        [NSTimer scheduledTimerWithTimeInterval: 0.5 target: self
                                                                       selector: @selector(didRequestForRideEnd) userInfo: nil repeats: NO];
                                        NSLog(@"End Ride success !!!!");
                                        NSLog(@"Delete Pathway request Success !!!!");
                                    } else {
                                        NSLog(@"End Ride request Failed !!!!");
                                    }
                                }];
}

-(void)requestRouteToUser {
    
    [startRideButton setTitle:@"NAVIGATE TO USER" forState:UIControlStateNormal];
    [startRideButton removeTarget:self action:@selector(startRide:) forControlEvents:UIControlEventTouchUpInside];
    [startRideButton addTarget:self action:@selector(navigateToUser:) forControlEvents:UIControlEventTouchUpInside];
    startRideButton.hidden = NO;
    self.userView.hidden = NO;
    self.bottomLayoutConstrint.constant = 80;
}

-(void)navigateToUser:(id)sender{
    
    [startRideButton setTitle:@"NAVIGATE TO DESTINATION" forState:UIControlStateNormal];
    [startRideButton removeTarget:self action:@selector(navigateToUser:) forControlEvents:UIControlEventTouchUpInside];
    [startRideButton addTarget:self action:@selector(navigateToDestination:) forControlEvents:UIControlEventTouchUpInside];
    
    NSLog(@"User started navigation to user");
}

#pragma mark - Rating to the Passenger

-(void)didRequestForOpenRatingView:(NSNotification *)notification {
    [NSTimer scheduledTimerWithTimeInterval: 0.5 target: self
                                   selector: @selector(openRatingView:) userInfo: nil repeats: NO];
}

-(void)openRatingView:(id)sender {
    
    [self performSegueWithIdentifier:@"rateUser" sender:nil];
}

#pragma mark - Check  Existing Pathway

-(void)checkExistingPathway {
    
    [PFCloud callFunctionInBackground: @"CheckExistingPathway"
                       withParameters: nil
                                block: ^(PFObject *object, NSError *error) {
                                    if (!error) {
                                        NSLog(@"CheckExistingPathway request Success !!!! ");
                                        if (object != nil) {
                                            _currentDriverPath = object;
                                            
                                            NSLog(@"Created Driver Path Object ======= %@", _currentDriverPath);
                                            
                                            destinationAddress = object[@"destinationAddress"];
                                            destinationLocation = object[@"destination"];
                                            destinationCoordinate = CLLocationCoordinate2DMake(destinationLocation.latitude, destinationLocation.longitude);
                                            self.rideConfigured= @YES;
                                            startRideButton.enabled = NO;
                                            
                                            [self setDestinationOnMapWithCoordinate:destinationCoordinate andAddress:destinationAddress];
                                        }
                                    } else {
                                        NSLog(@"CheckExistingPathway request Failed !!!! ");
                                    }
                                }];
}

-(void)setDestinationOnMapWithCoordinate:(CLLocationCoordinate2D)destinationCoord andAddress:(NSString*)address {
    
    _destinationSetted = @YES;
    self.navigationItem.rightBarButtonItem =  cancelButton;
    
    startRideButton.hidden = NO;
    [startRideButton setTitle:@"ADVERTISE YOUR JOURNEY" forState:UIControlStateNormal];
    [startRideButton removeTarget:self action:@selector(endRide:) forControlEvents:UIControlEventAllEvents];
    [startRideButton removeTarget:self action:@selector(navigateToDestination:) forControlEvents:UIControlEventAllEvents];
    [startRideButton addTarget:self action:@selector(startRideButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    self.locationSearchButton.enabled = NO;
    
    dropOffAnnotation = [[DropoffAnnotation alloc] initiWithTitle:@"Your Destination" Location:destinationCoord];
    
    [mapView addAnnotation:dropOffAnnotation];
    [_dropOffButton setHidden:YES];
    [_dropOffPinImage setHidden:YES];
    
    // get driver origin
    driverCoordinate = [[mapView userLocation] coordinate];
    
    // trace route from origin to destination
    destinationLocation = [PFGeoPoint geoPointWithLatitude:destinationCoord.latitude longitude:destinationCoord.longitude];
    destinationAddress = address;
    _locationLabel.text = destinationAddress;
    [self traceRouteWithStartingCoordinates:driverCoordinate end:destinationCoord];
}

-(void)traceRouteWithStartingCoordinates: (CLLocationCoordinate2D)startCoordinate end:(CLLocationCoordinate2D) endCoordinate {
    
    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
    MKPlacemark *dropPlacemark = [[MKPlacemark alloc] initWithCoordinate: startCoordinate addressDictionary:nil];
    MKPlacemark *pickPlacemark = [[MKPlacemark alloc] initWithCoordinate: endCoordinate addressDictionary:nil];
    
    [directionsRequest setSource:[[MKMapItem alloc] initWithPlacemark:pickPlacemark]];
    [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:dropPlacemark]];
    directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    
    [HUD showUIBlockingIndicatorWithText:@"Routing ..."];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        NSLog(@"Calculating directions completed");
        
        [HUD hideUIBlockingIndicator];
        if (error) {
            
            [[[UIAlertView alloc]initWithTitle:@"Error!" message:@"Route services is not available right now" delegate:nil cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil] show ];
        } else {
            assert(response);
            if(routeDetails){
                [self.mapView removeOverlay:routeDetails.polyline];
            }
            routeDetails = response.routes.lastObject;
            [self.mapView addOverlay:routeDetails.polyline];
            
            self.dropOffButton.hidden = YES;
            [self showRouteOnMap];
            if ([self.rideConfigured boolValue]) {
                [self navigateToUser:nil];
            }
        }
    }];
}

#pragma mark - Initial Views

-(void)configureView {
    
    self.locationLabel.text = @"Updating Location..";

    // set drawer button
    UIImage *menuImage = [[UIImage imageNamed:@"menu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _revealButtonItem = [[UIBarButtonItem alloc] initWithImage:menuImage style:UIBarButtonItemStylePlain target:self action:@selector(revealToggle:)];

    // Navigation RightBarButton
    cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelDropoff:)];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = _revealButtonItem;
    //hidden at the begining
    self.navigationItem.rightBarButtonItem = nil;

    [messageBoardUsersBGView setHidden:YES];
    [endMessageBoardButton setHidden:YES];
    [startRideButton setHidden:YES];
    
    ratingView.userInteractionEnabled = NO;
    [userView setHidden:YES];

    mapView.delegate = self;
    [mapView setRotateEnabled:NO];

    SWRevealViewController *revealViewController = self.revealViewController;
    
    [self configureNavigationBar];
    [self setupChatHeads];

    if ( revealViewController ){
        [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
        [self.navigationItem.leftBarButtonItem setTarget:self.revealViewController];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    driverLocationTimer=  [NSTimer scheduledTimerWithTimeInterval:5.0
                                                           target:self
                                                         selector:@selector(updateDriverLocation:)
                                                         userInfo:nil
                                                          repeats:YES];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    if (!driverLocationTimer) {
        driverLocationTimer=  [NSTimer scheduledTimerWithTimeInterval:5.0
                                                               target:self
                                                             selector:@selector(updateDriverLocation:)
                                                             userInfo:nil
                                                              repeats:YES];
    }
}

-(void)showRouteOnMap {
    
    CLLocationCoordinate2D southWest = driverCoordinate  ;
    CLLocationCoordinate2D northEast = destinationCoordinate;
    
    southWest.latitude = MIN(southWest.latitude, driverCoordinate.latitude);
    southWest.longitude = MIN(southWest.longitude, driverCoordinate.longitude);
    
    northEast.latitude = MAX(northEast.latitude, destinationCoordinate.latitude);
    northEast.longitude = MAX(northEast.longitude, destinationCoordinate.longitude);
    
    CLLocation *locSouthWest = [[CLLocation alloc] initWithLatitude:southWest.latitude longitude:southWest.longitude];
    CLLocation *locNorthEast = [[CLLocation alloc] initWithLatitude:northEast.latitude longitude:northEast.longitude];
    
    // This is a diag distance (if you wanted tighter you could do NE-NW or NE-SE)
    CLLocationDistance meters = [locSouthWest distanceFromLocation:locNorthEast];
    
    MKCoordinateRegion regionRoute;
    regionRoute.center.latitude = (southWest.latitude + northEast.latitude) / 2.0;
    regionRoute.center.longitude = (southWest.longitude + northEast.longitude) / 2.0;
    regionRoute.span.latitudeDelta = meters / 81319.5;
    regionRoute.span.longitudeDelta = 0.0;
    
    [mapView setRegion:regionRoute animated:YES];
    
}

#pragma mark - Driver Location Update

/*!
 @abstract Save the driver location on server
 */
-(void)updateDriverLocation:(id)sender {

    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        
        if (!error) {
            CLGeocoder *locator = [[CLGeocoder alloc]init];
            CLLocation *location = [[CLLocation alloc]initWithLatitude: geoPoint.latitude longitude: geoPoint.longitude];
            driverCoordinate  =  CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
            [locator reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                if(!error){
                    
                    CLPlacemark *placemark = [placemarks objectAtIndex:0];
                    NSDictionary * addressDictionary = placemark.addressDictionary;
                    NSMutableArray *formatedAddressLines = [addressDictionary valueForKey:@"FormattedAddressLines"];
                    currentAddress = [formatedAddressLines componentsJoinedByString:@", "];
                    if (currentAddress.length == 0) {
                        currentAddress = @"Undetermined";
                    }
                    
                    NSLog(@"Current Driver Address is ========== %@ ===== %@", currentAddress, geoPoint);
                    
                    [PFCloud callFunctionInBackground:@"UpdateUserLocation"
                                       withParameters:@{@"location": geoPoint,
                                                        @"locationAddress": currentAddress}
                                                block:^(NSString *success, NSError *error) {
                                                    if (!error) {
                                                        NSLog(@"UpdateDriverLocation request Success !!!!");
                                                    } else {
                                                        NSLog(@"UpdateDriverLocation request Failed !!!!");
                                                    }
                                                }];
                }else{
                    NSLog(@"%@", error.localizedDescription);
                }
            }];
        } else {
            NSLog(@"Failed get Driver current location ======= ");
        }
    }];
}

#pragma mark - UIButton Action

- (IBAction)setDestinationTouchedUpInside:(id)sender {
    
    destinationCoordinate =  [mapView centerCoordinate] ;
    _destinationSetted = @YES;
    [self setDestinationOnMapWithCoordinate: destinationCoordinate andAddress:destinationAddress];
    destinationLocation = [PFGeoPoint geoPointWithLatitude:myLatitude longitude:myLongitude];
    NSLog(@"Set Destination Button Clicked MyLatitude ======= %@ ", destinationLocation);
}

- (IBAction)startRideButtonTouchUpInside:(id)sender {
    
    if(![[PFUser currentUser][@"PhoneVerified"] boolValue]){
        [[[UIAlertView alloc]initWithTitle:nil message:@"Please verify your phone number before advertising a ride" delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil] show];
        return;
    }
    
    NSLog(@"Start ride button clicked");
    
    if(![self.rideConfigured boolValue]){
        [self performSegueWithIdentifier:@"RideSettingsSegue" sender:nil];
    }
}

-(void)cancelDropoff:(id)sender{
    
    self.rideConfigured = @NO;
    self.destinationSetted = @NO;
    
    startRideButton.hidden = YES;
    startRideButton.enabled = YES;
    [_dropOffButton setHidden:NO];
    [_dropOffPinImage setHidden:NO];
    
    //remove anotation
    self.locationSearchButton.enabled = YES;
    
    //remove route
    [self.mapView removeOverlay:routeDetails.polyline];
    
    //remove all annotations
    [self.mapView removeAnnotations: self.mapView.annotations];
    
    self.navigationItem.rightBarButtonItem = nil;
    
    self.startRideButton.hidden = YES;
    [self.startRideButton removeTarget:self action:@selector(startRideButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.startRideButton removeTarget:self action:@selector(navigateToDestination:) forControlEvents:UIControlEventTouchUpInside];
    [self.startRideButton removeTarget:self action:@selector(endRide:) forControlEvents:UIControlEventTouchUpInside];
    
    [PFCloud callFunctionInBackground: @"DeletePathway"
                       withParameters: nil
                                block: ^(NSString *success, NSError *error) {
                                    if (!error) {
                                        NSLog(@"Delete Pathway request Success !!!!");
                                    } else {
                                        NSLog(@"Delete Pathway request Failed !!!!");
                                    }
                                }];
}

- (IBAction)searchAddress:(id)sender {
    
    NSLog(@"Search Address");
    [self performSegueWithIdentifier:@"SearchViewPush" sender:self];
}

- (IBAction)callUser:(id)sender {
    
    NSString *phoneNumber = [@"telprompt://" stringByAppendingString:userPhone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (IBAction)messageBoardUsers:(id)sender {
    
}

// center the map view into the user location
- (IBAction)centerOnUsersLocation:(id)sender {
    
    [self updateLocationBarOnUserLocation];
    
    [mapView setRegion:region animated:YES];
    
}

#pragma mark - Location Manager and Map Delegate

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    MKPolylineRenderer  * routeLineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:routeDetails.polyline];
    
    routeLineRenderer.strokeColor = [UIColor redColor];
    routeLineRenderer.lineWidth = 5;
    NSLog(@"renderer for oberlay ===== %@", routeLineRenderer);
    return routeLineRenderer;
}

#pragma mark - Annotation Views

-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[DropoffAnnotation class]]){
        DropoffAnnotation *dropoffAnnotation = (DropoffAnnotation*)annotation;
        MKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"DropoffAnnotation"];
        if (annotationView==nil) {
            annotationView = dropoffAnnotation.annotationView;
            
        }
        else
            annotationView.annotation = annotation;
        return annotationView;
    }
    
    if ([annotation isKindOfClass:[UserAnnotation class]]){
        UserAnnotation *dropoffAnnotation = (UserAnnotation*)annotation;
        MKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"UserAnnotation"];
        if (annotationView==nil) {
            annotationView = dropoffAnnotation.annotationView;
            
        }
        else
            annotationView.annotation = annotation;
        return annotationView;
    }
    
    else
        return nil;
    
}

#pragma mark - Location Bar Update (Must be removed)

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{

    NSLog(@"Changing map region");
    self.dropOffButton.hidden = YES;

}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{

    [self updateLocationBarOnCenterLocation];

}

-(void)updateLocationBarOnUserLocation{
    
    CLGeocoder *locator = [[CLGeocoder alloc]init];
    CLLocationCoordinate2D centerCoordinate = mapView.userLocation.coordinate;
    myLatitude = centerCoordinate.latitude;
    myLongitude = centerCoordinate.longitude;
    
    CLLocation *location = [[CLLocation alloc]initWithLatitude:myLatitude longitude:myLongitude];
    self.dropOffButton.hidden = YES;
    [locator reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if(!error){
            
            self.dropOffButton.hidden = NO;
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSDictionary * addressDictionary = placemark.addressDictionary;
            NSMutableArray *formatedAddressLines = [addressDictionary valueForKey:@"FormattedAddressLines"];
            [formatedAddressLines removeLastObject];
            [formatedAddressLines removeLastObject];
            
            destinationAddress = [formatedAddressLines componentsJoinedByString:@", "];
            NSLog(@"Finished updateLocationBarOnUserLocation ============ %@", destinationAddress);
            
            if(destinationAddress.length !=0){
                self.locationLabel.text = destinationAddress;
            }else{
                self.locationLabel.text = @"Updating location..";
            }
            
        }else{
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

-(void)updateLocationBarOnCenterLocation{
    
    //this should be done in the background
    if(![_destinationSetted boolValue]) {
        
        CLGeocoder *locator = [[CLGeocoder alloc]init];
        
        CLLocationCoordinate2D centerCoordinate = [mapView centerCoordinate];
        
        myLatitude = centerCoordinate.latitude;
        myLongitude = centerCoordinate.longitude;
        CLLocation *location = [[CLLocation alloc]initWithLatitude:myLatitude longitude:myLongitude];
        self.dropOffButton.hidden = YES;
        self.locationLabel.text = @"Updating location..";
        [locator reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            
            if(!error){
                
                NSLog(@"Location updated sucessfully");
                self.dropOffButton.hidden = NO;
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                
                NSDictionary * addressDictionary = placemark.addressDictionary;
                NSMutableArray *formatedAddressLines = [addressDictionary valueForKey:@"FormattedAddressLines"];
                [formatedAddressLines removeLastObject];
                [formatedAddressLines removeLastObject];
                
                destinationAddress = [formatedAddressLines componentsJoinedByString:@", "];
                NSLog(@"Finished updating address bar with center map location %@", destinationAddress);

                if(destinationAddress.length !=0){
                    self.locationLabel.text = destinationAddress;
                }else{
                    self.locationLabel.text = @"Updating location..";
                }
                
            }else{
                NSLog(@"Can't get address for center coordinate on map");
                NSLog(@"%@", error.localizedDescription);
                
                // Delay execution for 1 sec and call again
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self updateLocationBarOnCenterLocation];
                });
            }
        }];
    }
}

-(void)navigateToDestination:(id)sender{
    
    [CMMapLauncher launchMapApp:CMMapAppAppleMaps
                    forDirectionsTo:[CMMapPoint mapPointWithName:@"Destination"
                                                      coordinate:destinationCoordinate]];
        
    NSLog(@"Driver is navigating to destination");
    
    cancelRideButton.enabled = NO;
    [startRideButton setTitle:@"END RIDE" forState:UIControlStateNormal];
    [startRideButton removeTarget:self action:@selector(navigateToDestination:) forControlEvents:UIControlEventTouchUpInside];
    [startRideButton addTarget:self action:@selector(endRide:) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark - Adjust Image Size

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - Deallocation

-(void)viewDidDisappear:(BOOL)animated{
    [self.locationManager stopUpdatingLocation];
    
    [driverLocationTimer invalidate];
    driverLocationTimer = nil;
    [super viewDidDisappear:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark DRIVER HEAD DELEGATE METHODS

-(void)didRequestForShowDropoffOnMap:(PFObject *)rideRequest{
    
    double dropoffLat  = [rideRequest[@"dropoffLat"] doubleValue];
    double dropoffLong  = [rideRequest[@"dropoffLong"] doubleValue];
    CLLocationCoordinate2D dropoffCoordinate = CLLocationCoordinate2DMake(dropoffLat, dropoffLong);
    self.mapView.centerCoordinate = dropoffCoordinate;

}

-(void)didRequestForShowPickupOnMap:(PFObject *)rideRequest{
    
    double pickupLat  = [rideRequest[@"pickupLat"] doubleValue];
    double pickupLong  = [rideRequest[@"pickupLong"] doubleValue];
    CLLocationCoordinate2D pickupCoordinate = CLLocationCoordinate2DMake(pickupLat, pickupLong);
    self.mapView.centerCoordinate = pickupCoordinate;
    
}

-(void)disableNavigation {
    
    self.navigationItem.leftBarButtonItem = nil;

}

-(void)enableNavigation {
    
    self.navigationItem.leftBarButtonItem = _revealButtonItem;
    
}

#pragma mark - Setters

-(void)setRideConfigured:(NSNumber *)rideConfigured {

    _rideConfigured = rideConfigured;
    if([rideConfigured boolValue]){
        //disable out navigation
        [self disableNavigation];
        
        [self.startRideButton removeTarget:self action:@selector(startRideButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self.startRideButton setTitle:@"NAVIGATE TO DESTINATION" forState: UIControlStateNormal];
        [self.startRideButton addTarget:self action:@selector(navigateToDestination:) forControlEvents:UIControlEventTouchUpInside];
        
    }else{
        //enable out navigation
        [self enableNavigation];
    }
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString: @"RideSettingsSegue"]){
        RideSettingsViewController *vc =(RideSettingsViewController*)[segue destinationViewController];
        vc.destination = destinationLocation;
        if(destinationAddress.length !=0) {
            NSLog(@"Driver Destination Address is ========== %@", destinationAddress);
            NSLog(@"Driver Current Address is ========== %@", currentAddress);
            vc.destinationAddress = destinationAddress;
        } else {
            NSLog(@" =============== Getting Driver Destination Address Faild");
            vc.destinationAddress = @"Undetermined";
        }
    }
    if([segue.identifier isEqualToString: @"rateUser"]){
        
        RideRatingViewController *vc =(RideRatingViewController*)[segue destinationViewController];
        
        //rate only last user, this is wrong
        NSLog(@"Rate to the Passenger =================== /n %@ /n ======================= %@", _lastRideInfo, passenger);
        vc.rideRequest = _lastRideInfo;
    }
    
}



@end
