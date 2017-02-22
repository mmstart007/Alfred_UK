//
//  MainViewController.m
//  Alfred
//
//  Created by Arjun Busani on 24/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "RiderViewController.h"
#import "SWRevealViewController.h"
#import "PickupAnnotation.h"
#import "DriverViewController.h"
#import "WalletViewController.h"

#import "MessageBoardStartRideViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DriverListViewController.h"
#import <Parse/Parse.h>
#import "PushUtils.h"


#import "DriverHeadViewController.h"

#import "CHDraggingCoordinator.h"
#import "CHDraggableView.h"
#import "CHDraggableView+Avatar.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import <TWMessageBarManager/TWMessageBarManager.h>


const int CHOOSE_ALFRED_ALERT_TAG = 1;
const int PHONE_VERIFY_ALERT_TAG = 3;
const int RIDE_REQUEST_EXPIRATION_TIME = 4*60; // in seconds

@interface RiderViewController ()<SWRevealViewControllerDelegate, CHDraggingCoordinatorDelegate>{
    
    BOOL _pickupCoordinatesSetted;
    BOOL _dropoffCoordinatesSetted;
    
    BOOL settingPickupLocation, settingDropoffLocation;
    double _myLatitude, _myLongitude;
    PFUser *_selectedDriver;
    PFObject *_rideRequest;
    PFObject *_selectedDriverLocation;
    
    NSNumber *_seatsRequested;
    CHDraggingCoordinator *_draggingCoordinator;
    double _ridePrice;
    bool _annotationInteract;
    BOOL _canRefund;
    UIBarButtonItem *_revealButtonItem;
    
    //this variable holds the state when the rider got the acceptation push form the driver and he process the request
    
    BOOL _processingRequest;
}
@property NSNumber* onRide;
@end

@implementation RiderViewController

@synthesize mapView,locationManager,region, pickUpImage,bryantPark,bryantParkAnn;

@synthesize pickupOrDropoffButton,pickUpLabel,pickupAnnotation,pickupCoord,pickupAddress,pickupPlacemark;
@synthesize dropOffLabel,dropOffAnnotation,dropOffCoord,dropOffAddress,dropoffPlacemark,arrayOfDriverAnnotations;
@synthesize dropoffLocationLabel,dropoffSearchButton;
@synthesize routeDetails;
@synthesize cancelButton;
@synthesize pickupSearchButton,availabilityBar;
@synthesize pickupSearchAddress,pickupSearchCoord,dropOffSearchAddress,dropOffSearchCoord,requestRideButton,dropOffBottomContraint;
@synthesize driverLocationTimer,pickupCity,driversArray,routeDistance,driverIDArray;
@synthesize requestImageView,requestLabel,cancelRideRequestTimer,requestRideDecisionPopupViewController,isRideAccepted;
@synthesize driverView,rideID,driverPhone,driverSelectedArray;
@synthesize rideRatingViewController,balance,retrievedDict,driverCalloutPopupViewController,driverCalloutNotActiveViewController;
@synthesize driverSelectedID,rideEndArray;


//this is not hidding anymore, just changing visual appareance
- (void)hideNavigationController {
    
    //      self.navigationController.navigationBar.tintColor = [UIColor whiteColor]];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:NULL action:NULL];
    
    //self.navigationController.navigationBar.shadowImage = [UIImage new];
    //[self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    //    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    //  self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
}


/*!
 * @summary Register class to watch for different notifications
 */


- (void)watchForNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForStoppingAllMappingServices:) name:@"didRequestForStoppingAllMappingServices" object:nil];
    
    // sent when the ride is accepted by the requested driver
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForRideAcceptedForDriver:) name:@"didRequestForRideAcceptedForDriver" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForRideDecisionCloseView:) name:@"didRequestForRideDecisionCloseView" object:nil];
    // sent by the driver when the ride is ended
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForRideEnd:) name:@"didRequestForRideEnd" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForRideCancelByDriver:) name:@"didRequestForRideCancelByDriver" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForOpenRatingView:) name:@"didRequestForOpenRatinView" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForMessageBoardRideStarted:) name:@"didRequestForMessageBoardRideStarted" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForMessageBoardRidePickedUp:) name:@"didRequestForMessageBoardRidePickedUp" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForActiveDriverChosenForRide:) name:@"didRequestForActiveDriverChosenForRide" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForInactiveDriverChosenForRide:) name:@"didRequestForInactiveDriverChosenForRide" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForMessageBoardRideRejected:) name:@"didRequestForMessageBoardRideRejected" object:nil];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    _annotationInteract = NO;
    
    //[self addChatHeads];
    _onRide = [NSNumber numberWithBool:FALSE];
    
    
    _selectedDriver = nil;
    _rideRequest = nil;
    
    
    _pickupCoordinatesSetted = NO;
    _dropoffCoordinatesSetted = NO;
    _processingRequest = NO;
    
    settingPickupLocation = YES;
    settingDropoffLocation = NO;
    
    isDriverSelected = false;
    isItRetrieval = NO;
    isActiveDriverChosen = NO;
    
    //configure driver view and make it hidden
    self.driverView.layer.cornerRadius = 0.5;
    self.driverView.layer.shadowOpacity = 0.8;
    self.driverView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
    [driverView setHidden:YES];
    //register for notifications
    
    [self watchForNotifications];
    
    
    requestImageView.hidden = YES;
    requestLabel.hidden = YES;
    
    requestRideButton.hidden=YES;
    inRequest  = NO;
    ifDrop = NO;
    mapChangedFromUserInteraction = NO;
    routeFixed = NO;
    
    //check is location is within country
    withinCountry = NO;
    
    
    arrayOfDriverAnnotations = [[NSMutableArray alloc]init];
    
    [availabilityBar setHidden:YES];
    
    isItDropSearch = NO;
    isItSearchResult = NO;
    ifTimerShootsCancel = NO;
    
    UIImage *drawerImage = [[UIImage imageNamed:@"menu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    _revealButtonItem = [[UIBarButtonItem alloc] initWithImage:drawerImage
                                                         style:UIBarButtonItemStylePlain target:self action:@selector(revealToggle:)];
    
    cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelPickup:)];
    
    
    
    //    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    
    SWRevealViewController *revealViewController = self.revealViewController;
    self.navigationItem.leftBarButtonItem = _revealButtonItem;
    
    self.navigationItem.rightBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem.title = @"";
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    
    
    [self hideNavigationController];
    
    
    
    if ( revealViewController ){
        
        
        
        [self.navigationItem.leftBarButtonItem setTarget:self.revealViewController];
        
    }
    
    
    //search pickup address
    [pickupSearchButton addTarget:self action:@selector(searchPopupForPickupView:) forControlEvents:UIControlEventTouchUpInside];
    [dropoffSearchButton addTarget:self action:@selector(searchPopupForDropoffView:) forControlEvents:UIControlEventTouchUpInside];
    
    [dropoffSearchButton setHidden:YES];
    [dropoffLocationLabel setHidden:YES];
    [dropOffLabel setHidden:YES];
    
    mapView.delegate = self;
    [mapView setRotateEnabled:NO];
    //array with available drivers
    
    driverIDArray = [[NSMutableArray alloc] init];
    
    CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
    //check is location services are enabled
    
    if (authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
        authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        [self.locationManager startUpdatingLocation];
        mapView.showsUserLocation = YES;
        mapView.userTrackingMode=YES;
        
        CLLocationCoordinate2D coord = mapView.userLocation.location.coordinate;
        MKCoordinateRegion intialRegion = MKCoordinateRegionMakeWithDistance(coord, 1000.0, 1000.0);
        [mapView setRegion:intialRegion animated:YES];
        
    }
    
    //[self manualDriverAnnotation];
    
    pickUpLabel.text = @"Updating Location..";
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForSearchResult:) name:@"didRequestForSearchResult" object:nil];
    
    
    //[NSTimer scheduledTimerWithTimeInterval: 10.0 target: self
    //                             selector: @selector(updateAnnotation:) userInfo: nil repeats: YES];
    
    //[self updateDriversLocation:self];
    
    [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self
                                   selector: @selector(updateLocationBarOnUserLocation) userInfo: nil repeats: NO];
    
    
    //update the drivers location every 2 seconds
    
    driverLocationTimer =  [NSTimer scheduledTimerWithTimeInterval:2.0
                                                            target:self
                                                          selector:@selector(updateDriversLocation:)
                                                          userInfo:nil
                                                           repeats:NO];
    
    
    [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self
                                   selector: @selector(checkForUserStatus) userInfo: nil repeats: NO];

    [NSTimer scheduledTimerWithTimeInterval: 20.0
                                     target:self
                                   selector:@selector(updateUserLocationOnServer:)
                                   userInfo:nil
                                    repeats:YES];

    if([[PFUser currentUser][@"UserMode"] boolValue] == NO){
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        DriverViewController *frontViewController = (DriverViewController *)[storyboard instantiateViewControllerWithIdentifier:@"DriverMainID"];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
        [revealViewController pushFrontViewController:navigationController animated:YES];
        
        
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)appDidBecomeActive:(NSNotification*)notification{
    NSLog(@"RiderViewController: App did become active");
    
    [self checkForUserStatus];
    
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self hideNavigationController];
    if(!driverLocationTimer){
        
        driverLocationTimer =  [NSTimer scheduledTimerWithTimeInterval:2.0
                                                                target:self
                                                              selector:@selector(updateDriversLocation:)
                                                              userInfo:nil
                                                               repeats:NO];
    }
    [super viewDidAppear: animated];
    //check if the user has any peending rating ride
    
    [HUD showUIBlockingIndicatorWithText:@"Loading.."];
    
    PFQuery *query1 = [PFQuery  queryWithClassName:@"RideRequest"];
    [query1 whereKey:@"rated" notEqualTo:@YES];
    [query1 whereKey:@"requestedBy" equalTo:[PFUser currentUser]];
    [query1 whereKey:@"finished" equalTo:@YES];
    [query1 whereKey:@"canceled" notEqualTo:@YES];
    [query1 whereKey:@"canceledByDriver" notEqualTo:@YES];
    [query1 whereKey:@"accepted" equalTo:@YES];
    [query1 includeKey:@"driver"];
    [query1 includeKey:@"driver.driverRating"];
    [query1 includeKey:@"requestedBy"];
    [query1 getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        [HUD hideUIBlockingIndicator];
        if(error==nil && object){
            _rideRequest = object;
            //[self openRatingView:nil];
            
        }
    }];
    
}

-(void)viewDidAppear:(BOOL)animated{

    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.locationManager stopUpdatingLocation];
    
    [driverLocationTimer invalidate];
    driverLocationTimer = nil;
}

#pragma mark - Activate Ride Mode

-(void)activateUserInRideMode{
    
    self.onRide = @YES;
    
    [pickUpImage setHidden:YES];
    [pickupOrDropoffButton setHidden:YES];
    dropoffSearchButton.enabled = NO;
    [dropoffSearchButton setHidden:YES];
    
    [dropoffLocationLabel setHidden:NO];
    [dropoffSearchButton setHidden:NO];
    [dropOffLabel setHidden:NO];
    self.dropofffIcon.hidden = NO;
    pickupSearchButton.enabled = NO;
    
    
    
    dropoffSearchButton.enabled = NO;
    
    routeFixed = YES;
    _pickupCoordinatesSetted = YES;
    _dropoffCoordinatesSetted = YES;
    //    [UIView animateWithDuration:2.0 animations:^{
    //        dropOffBottomContraint.constant = 10;
    //        requestRideButton.hidden= NO;
    //
    //
    //    }];
    
    
    
}


-(void)didRequestForRideDecisionCloseView:(NSNotification *)notification
{
    
    NSArray *boolDecision = [notification object];
    isRideAccepted = [[boolDecision objectAtIndex:0] boolValue];
    
    
}



-(void)openTheDriverView:(PFUser*)driver{
    
    
    self.driverName.text = driver[@"FullName"];
    self.driverMobile.text = driver[@"Phone"];
    
    
    PFObject *ratingData = driver[@"driverRating"];
    
    //self.driverRating.text = [NSString stringWithFormat:@"Rating: %.2lf", [(NSNumber*)ratingData[@"Rating"] doubleValue]];
    
    
    
    NSString *driverProfilePic = driver[@"ProfilePicUrl"];
    
    if (![driverProfilePic isKindOfClass:[NSNull class]]) {
        
        
        [self.driverProfilePic sd_setImageWithURL:[NSURL URLWithString:driverProfilePic] placeholderImage:[UIImage imageNamed:@"blank profile"]];
    }
    
    self.driverProfilePic.layer.cornerRadius = self.driverProfilePic.frame.size.height /2;
    self.driverProfilePic.layer.masksToBounds = YES;
    self.driverProfilePic.layer.borderWidth = 0;
    
    
    
    if (isRideAccepted) {
        
        requestLabel.hidden = YES;
        requestImageView.hidden = YES;
        //move the dropoff to the botom
        dropOffBottomContraint.constant = -50;
        dropoffLocationLabel.hidden = NO;
        dropOffLabel.hidden = NO;
        dropoffSearchButton.hidden = NO;
        dropoffSearchButton.enabled = NO;
        
        //hide the request button at the bottom
        requestRideButton.hidden=YES;
        
        [driverView setHidden:NO];
        
        
        
        if (isItRetrieval) {
            
            [self retrieveTheAnnotationsAndRoute:retrievedDict];
            
        }
        
    }
    
}


-(void)rideRequestDecisionMade:(NSString*)message{
    
    
    requestRideDecisionPopupViewController = [[RideRequestDecisionViewController alloc] initWithNibName:@"RideRequestDecisionViewController" bundle:nil];
    
    requestRideDecisionPopupViewController.decision = message;
    requestRideDecisionPopupViewController.isAccepted = YES;
    [requestRideDecisionPopupViewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:requestRideDecisionPopupViewController animated:YES completion:nil];
    
    
    
}



#pragma mark - Remove Ride Mode


- (void)allowSetPickup {
    
    _pickupCoordinatesSetted = NO;
    settingPickupLocation = YES;
    
    [mapView removeAnnotation:pickupAnnotation];
    
    
    //hide drop off settings
    [dropoffLocationLabel setHidden:YES];
    [dropoffSearchButton setHidden:YES];
    [dropOffLabel setHidden:YES];
    [self.dropofffIcon setHidden:YES];
    
    
    [pickUpImage setImage:[UIImage imageNamed:@"pickup"]];
    pickUpImage.hidden = NO;
    ifDrop = NO;
    [pickupOrDropoffButton setTitle:@"Set Pickup Point" forState:UIControlStateNormal];
    pickupOrDropoffButton.enabled = YES;
    self.navigationItem.rightBarButtonItem.title = @"";
    self.navigationItem.rightBarButtonItem.enabled = NO;
    pickupSearchButton.enabled = YES;
}

-(void)cancelPickup:(id)sender{
    
    //the user must select a driver again
    isDriverSelected = NO;
    
    if (!routeFixed ) {
        
        
        
        [self allowSetPickup];
        
    }
    
    
    if (routeFixed) {
        [self clearRoute];
        routeFixed = NO;
        [self allowSetDropOff];
        
        
        [pickUpImage setHidden:NO];
        [pickupOrDropoffButton setHidden:NO];
        
        
        [UIView animateWithDuration:2.0 animations:^{
            dropOffBottomContraint.constant = -50;
            requestRideButton.hidden = YES;
            
        }];
        
    }
    
}




#pragma mark - Messsage Board Ride Started and Picked up

-(void)didRequestForMessageBoardRideStarted:(NSNotification *)notification
{
    [cancelRideRequestTimer invalidate];
    cancelRideRequestTimer = nil;
    
    
    
    NSArray*  rideRequestArray = [notification object];
    rideID = rideRequestArray[0];
    
    
    
    [self getMessageBoardData:rideID message:@"Your message board ride has started"];
    
    [pickUpImage setHidden:YES];
    [pickupOrDropoffButton setHidden:YES];
    dropoffSearchButton.enabled = NO;
    [dropoffSearchButton setHidden:YES];
    
    [dropoffLocationLabel setHidden:NO];
    [dropoffSearchButton setHidden:NO];
    [dropOffLabel setHidden:NO];
    pickupSearchButton.enabled = NO;
    
    
    
    dropoffSearchButton.enabled = NO;
    
    routeFixed = YES;
    
    [UIView animateWithDuration:2.0 animations:^{
        dropOffBottomContraint.constant = 10;
        requestRideButton.hidden=NO;
        
        
        
    }];
    
    
    
    
}


-(void)didRequestForMessageBoardRidePickedUp:(NSNotification *)notification
{
    [self clearRoute];
    [self checkForUserStatus];
    [self pickupPopView];
    
}

-(void)pickupPopView{
    
    requestRideDecisionPopupViewController = [[RideRequestDecisionViewController alloc] initWithNibName:@"RideRequestDecisionViewController" bundle:nil];
    
    requestRideDecisionPopupViewController.decision = @"You have been picked up";
    requestRideDecisionPopupViewController.isAccepted = YES;
    [requestRideDecisionPopupViewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:requestRideDecisionPopupViewController animated:YES completion:nil];
    
    
}

-(void)refundExpired{
    
    _canRefund = NO;
}

#pragma mark - Ride Accepted by Driver

/*
 * Called when the ride request sent to the driver is accepted by him
 */


-(void)didRequestForRideAcceptedForDriver:(NSNotification *)notification
{
    
    if(!_processingRequest){
        _processingRequest = YES;
        
        _canRefund = YES;
        //set a timer, when the timer is done, the ride cant be refunded anymore
        [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(refundExpired) userInfo:nil repeats:NO];
        
        //hide it to load the new data
        [driverView setHidden:YES];
        
        [requestRideButton setTitle:@"CANCEL REQUEST" forState:UIControlStateNormal];
        inRequest = NO;
        
        
        requestRideDecisionPopupViewController = [[RideRequestDecisionViewController alloc] initWithNibName:@"RideRequestDecisionViewController" bundle:nil];
        
        
        requestRideDecisionPopupViewController.decision = @"Your ride was accepted by driver";
        
        requestRideDecisionPopupViewController.isAccepted = YES;
        
        [requestRideDecisionPopupViewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
        
        [self presentViewController:requestRideDecisionPopupViewController animated:YES completion:^(){
            
            [cancelRideRequestTimer invalidate];
            cancelRideRequestTimer = nil;
            
            
            PFObject *driverStatus = _selectedDriver[@"driverStatus"];
            [driverStatus fetchIfNeeded];
            double pricePerSeat = [driverStatus[@"pricePerSeat"] doubleValue];
            double price = pricePerSeat * [_seatsRequested intValue];
            
            double currentAmount  =[[ PFUser currentUser][@"Balance"] doubleValue] ;
            currentAmount  = currentAmount - _ridePrice;
            
            [PFUser currentUser][@"Balance"] = [NSNumber numberWithDouble:currentAmount];
            [[PFUser currentUser] saveInBackground];
            
            if (!isRideAccepted) {
                
                isRideAccepted = YES;
                
                NSArray*  rideRequestArray = [notification object];
                
                //this is the notification object when a new ride request
                // is accepted by the driver
                // the notification contains the objectId of the request
                // and the push is sent from CloudCode
                // so the first object is the ride id
                assert(rideRequestArray.count > 0);
                
                rideID = [rideRequestArray firstObject];
                
                //the ride id should be equal to the ride request made by the user
                // so lets assert that
                assert([rideID isEqualToString:_rideRequest.objectId]);
                
                
                NSLog(@"Ride id: %@", rideID);
                //retrieve driver data
                //maybe this query is not needed as i alrady know the driver and ride request
                //should optimize it later
                [HUD showUIBlockingIndicatorWithText:@"Loading driver..."];
                
                [_rideRequest fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                    
                    if(error == nil){
                        PFUser *driver = (PFUser*) _rideRequest[@"driver"];
                        [driver fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                            _processingRequest = NO;
                            
                            if(error!= nil){
                                assert(0);
                            }else{
                                
                                [HUD hideUIBlockingIndicator];
                                self.onRide  = @YES;
                                [self openTheDriverView:driver];
                            }
                        }];
                    }else{
                        assert(0);
                    }
                }];
            }
            
        }];
    }
}

#pragma mark - Ride End and Rating View

-(void)didRequestForRideEnd:(NSNotification *)notification
{
    NSLog(@"Request for ride ended");
    
    isRideAccepted = NO;
    ifDrop = true;
    [driverView setHidden:YES];
    
    inRequest = false;
    [self.mapView removeAnnotations:[mapView annotations]];
    [self clearRoute];
    routeFixed = NO;
    [self allowSetPickup];
    _dropoffCoordinatesSetted = NO;
    _pickupCoordinatesSetted = NO;
    self.driverView.hidden = YES;
    
    // [self cancelPickup:self];
    
    [requestRideButton setTitle:@"LOOK FOR AN ALFRED" forState:UIControlStateNormal];
    
    self.onRide = @NO;
    
    rideEndArray = [notification object];
    
    requestRideDecisionPopupViewController = [[RideRequestDecisionViewController alloc] initWithNibName:@"RideRequestDecisionViewController" bundle:nil];
    
    NSString* decisionStr = [NSString stringWithFormat:@"Ride Cost: $%.2f", _ridePrice/100];
    
    requestRideDecisionPopupViewController.decision = decisionStr;
    requestRideDecisionPopupViewController.isAccepted = NO;
    requestRideDecisionPopupViewController.openRatingView = YES;
    
    [requestRideDecisionPopupViewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:requestRideDecisionPopupViewController animated:YES completion:nil];
    
}


-(void)didRequestForOpenRatingView:(NSNotification *)notification
{
    [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self
                                   selector: @selector(openRatingView:) userInfo: nil repeats: NO];
    
    
}


-(void)openRatingView:(id)sender{
    
    [self performSegueWithIdentifier:@"rateDriver" sender:nil];
    
}


#pragma mark - Drawing of the route, Clearing and the overlay render

-(void)routeRequested{
    
    
    //called when pick up and drop off points where set properly
    //draw route on map
    [HUD showUIBlockingIndicatorWithText:@"Routing.."];
    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
    
    MKPlacemark *dropPlacemark = [[MKPlacemark alloc] initWithCoordinate:dropOffCoord addressDictionary:nil];
    MKPlacemark *pickPlacemark = [[MKPlacemark alloc] initWithCoordinate:pickupCoord addressDictionary:nil];
    
    [directionsRequest setSource:[[MKMapItem alloc] initWithPlacemark:dropPlacemark]];
    [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:pickPlacemark]];
    directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        NSLog(@"Calculating directions completed");
        [HUD hideUIBlockingIndicator];
        if (error) {
            
            NSLog(@"Failed to calculate directions for route");
            NSLog( error.localizedDescription);
        }
        else{
            
            assert(response);
            routeDetails = response.routes.lastObject;
            
            
            [self.mapView addOverlay:routeDetails.polyline];
            
            float dist = routeDetails.distance/1000; //get distance in meters
            
            routeDistance =  [NSString stringWithFormat:@"%f", dist];
            
            NSLog(@"Total Distance (in Meters) :%f", dist);
            
            CLLocationCoordinate2D southWest = pickupCoord;
            CLLocationCoordinate2D northEast = dropOffCoord;
            
            southWest.latitude = MIN(southWest.latitude, pickupAnnotation.coordinate.latitude) - 0.01;
            southWest.longitude = MIN(southWest.longitude, pickupAnnotation.coordinate.longitude) - 0.01 ;
            
            northEast.latitude = MAX(northEast.latitude, dropOffAnnotation.coordinate.latitude) + 0.01;
            northEast.longitude = MAX(northEast.longitude, dropOffAnnotation.coordinate.longitude) + 0.01;
            
            CLLocation *locSouthWest = [[CLLocation alloc] initWithLatitude:southWest.latitude longitude:southWest.longitude];
            CLLocation *locNorthEast = [[CLLocation alloc] initWithLatitude:northEast.latitude longitude:northEast.longitude];
            
            // This is a diag distance (if you wanted tighter you could do NE-NW or NE-SE)
            CLLocationDistance meters = [locSouthWest distanceFromLocation:locNorthEast];
            
            MKCoordinateRegion regionRoute;
            regionRoute.center.latitude = (southWest.latitude + northEast.latitude) / 2.0;
            regionRoute.center.longitude = (southWest.longitude + northEast.longitude) / 2.0;
            regionRoute.span.latitudeDelta = meters / 81319.5;
            regionRoute.span.longitudeDelta = 0.0;
            //focus on route
            [mapView setRegion:regionRoute animated:YES];
            
        }
    }];
    
}


-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    
    MKPolylineRenderer  * routeLineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:routeDetails.polyline];
    routeLineRenderer.strokeColor = [UIColor redColor];
    routeLineRenderer.lineWidth = 5;
    
    
    return routeLineRenderer;
    
    
}


-(void)clearRoute{
    
    [self.mapView removeOverlay:routeDetails.polyline];
}

#pragma mark - Adding the annotations for Message Board Ride (Automatically)



//set drivers in the map


-(void)addDriverAnnotations{
    
    if(driverLocationTimer){
        
        [driverLocationTimer invalidate];
        driverLocationTimer = nil;
        
        
        DriverAnnotation *driverAnnotation;
        
        CLLocationCoordinate2D driverCoordinates;
        CLLocationDegrees latDeg;
        CLLocationDegrees longDeg;
        double latDouble;
        double longDouble;
        
        NSString* dropAddress=@"";
        NSString* dropLatitude=@"";
        NSString* dropLongitude=@"";
        NSString* requestRideId=@"";
        
        NSString* driverName=@"";
        NSString* driverRating=@"";
        NSString* driverMobile=@"";
        NSString* driverProfilePic=@"";
        NSString* messageBoardId=@"";
        
        
        [self.mapView removeAnnotations:arrayOfDriverAnnotations];
        
        
        [arrayOfDriverAnnotations removeAllObjects];
        
        NSMutableArray *locationsArray = [[ NSMutableArray alloc] init];
        int i=0;
        
        for (PFObject* driverData in driversArray) {
            
            PFGeoPoint *loc = driverData[@"location"];
            PFUser *userData = driverData[@"user"];
            
            latDouble = loc.latitude;
            longDouble = loc.longitude;
            
            
            latDeg = latDouble;
            longDeg =longDouble;
            
            
            
            driverCoordinates = CLLocationCoordinate2DMake(latDouble, longDouble);
            
            
            
            driverName = userData[@"FullName"];
            PFObject *driverStatus = userData[@"driverStatus"];
            
            driverMobile = userData[@"Phone"];
            PFObject *ratingObject = userData[@"driverRating"];
            
            driverRating =[NSString stringWithFormat:@"Rating: %3.2lf", [ratingObject[@"rating"] doubleValue]];
            
            NSString* usermobile = [NSString stringWithFormat:@"Cell: %@",driverMobile];
            
            
            driverProfilePic = userData[@"ProfilePicUrl"];
            //        PFQuery *statusQuery = [PFQuery queryWithClassName:@"DriverStatus"];
            //        [statusQuery whereKey:@"user" equalTo:userData];
            
            //        [statusQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError * succeed){
            
            
            driverAnnotation = [[DriverAnnotation alloc] initWithTitle: driverName Location:driverCoordinates];
            driverAnnotation.activeRide = YES; // now only active rides, but setting this just in case
            
            //            BOOL inRide = [object[@"inride"] boolValue];
            
            [driverAnnotation setActiveRide:NO]; //check from user data, maybe change driver info
            
            
            [driverAnnotation setDriverMobile:usermobile];
            [driverAnnotation setDriverProfilePic:driverProfilePic];
            [driverAnnotation setDriverRating:driverRating];
            
            
            
            [driverAnnotation setDriverID: userData.objectId];
            [driverAnnotation setDropAddress:dropAddress];
            [driverAnnotation setDropLatitude:dropLatitude];
            [driverAnnotation setDropLongitude:dropLongitude];
            [driverAnnotation setRequestRideId:requestRideId];
            NSLog(@"Number of seats");
            NSNumber *numOfSeats = driverStatus[@"numberOfSeats"];
            
            [driverAnnotation setAvailbleSeats: driverStatus[@"numberOfSeats"]];
            // [driverAnnotation setAvailbleSeats:[NSString stringWithFormat:@"%d", [object[@"numberOfSeats"] intValue]]];
            
            
            
            
            [arrayOfDriverAnnotations addObject:driverAnnotation];
            
            [mapView addAnnotation:driverAnnotation];
            
        }
        
        //launch again the location timer to request the drivers locations
        
        driverLocationTimer =  [NSTimer scheduledTimerWithTimeInterval:2.0
                                                                target:self
                                                              selector:@selector(updateDriversLocation:)
                                                              userInfo:nil
                                                               repeats:NO];
        
    }
}



//show driver details for active driver

-(void)driverAnnotationCallout:(DriverAnnotation*)driverAnnot{
    
    long  selectedDriverIndex  =  [arrayOfDriverAnnotations indexOfObject:driverAnnot];
    
    _selectedDriverLocation = driversArray[selectedDriverIndex];
    //get the user for the selected driver
    _selectedDriver = _selectedDriverLocation[@"user"];
    
    
    [self performSegueWithIdentifier:@"DriverDetailsSegue" sender:self];
    
    
    
}

////show driver details for non active driver
//-(void)driverAnnotationNotActiveCallout:(DriverAnnotation*)driverAnnot{
//
//
//    driverCalloutNotActiveViewController = [[DriverCalloutNotActiveViewController alloc] initWithNibName:@"DriverCalloutNotActiveViewController" bundle:nil];
//
//
//    [driverCalloutNotActiveViewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
//    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
//
//    [driverCalloutNotActiveViewController setRequestRideId:driverAnnot.requestRideId];
//    [driverCalloutNotActiveViewController setDriverID:driverAnnot.driverID];
//
//    [driverCalloutNotActiveViewController setAvailbleSeats:driverAnnot.availbleSeats];
//    [driverCalloutNotActiveViewController setDriverName:driverAnnot.title];
//    [driverCalloutNotActiveViewController setDriverProfilePic:driverAnnot.driverProfilePic];
//    [driverCalloutNotActiveViewController setDriverRating:driverAnnot.driverRating];
//    [driverCalloutNotActiveViewController setDriverMobile:driverAnnot.driverMobile];
//    [self presentViewController:driverCalloutNotActiveViewController animated:YES completion:nil];
//
//
//
//}



-(void)retrieveTheAnnotationsAndRoute:(NSDictionary*)messageDict{
    
    NSString* originLatitude;
    NSString* originLongitude;
    NSString* destinationLatitude;
    NSString* destinationLongitude;
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *token = [prefs stringForKey:@"token"];
    
    NSArray* driverMessageRequests = messageDict[@"driverMessageRequests"];
    
    for (id userDict in driverMessageRequests) {
        NSString *userIdToCheck = userDict[@"userId"];
        
        if ([token isEqualToString:userIdToCheck]) {
            
            originLatitude =userDict[@"originLatitude"];
            originLongitude =userDict[@"originLongitude"];
            
            destinationLatitude =userDict[@"destinationLatitude"];
            destinationLongitude =userDict[@"destinationLongitude"];
            
            
        }
    }
    
    
    CLGeocoder *locator = [[CLGeocoder alloc]init];
    
    double myLatitude =[originLatitude doubleValue];
    double myLongitude = [originLongitude doubleValue];
    
    double userLat =[destinationLatitude doubleValue];
    double userLong = [destinationLongitude doubleValue];
    
    pickupCoord.latitude =myLatitude;
    pickupCoord.longitude =myLongitude;
    
    dropOffCoord.latitude = userLat;
    dropOffCoord.longitude =   userLong;
    
    
    
    CLLocation *location = [[CLLocation alloc]initWithLatitude:myLatitude longitude:myLongitude];
    [locator reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if(error){
            
            NSLog(@"Failed to get location");
            NSLog([error description]);
        }
        
        
        pickupPlacemark = [placemarks objectAtIndex:0];
        
        pickupAddress = [[pickupPlacemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
        
        if (!pickupAnnotation) {
            pickupAnnotation = [[PickupAnnotation alloc] initiWithTitle:pickupAddress Location:pickupCoord];
            
        }
        else{
            pickupAnnotation.coordinate = pickupCoord;
            pickupAnnotation.title = pickupAddress;
            
        }
        [mapView addAnnotation:pickupAnnotation];
        
        
        CLGeocoder *locatorDrop = [[CLGeocoder alloc]init];
        
        CLLocation *locationDrop = [[CLLocation alloc]initWithLatitude:userLat longitude:userLong];
        
        [locatorDrop reverseGeocodeLocation:locationDrop completionHandler:^(NSArray *placemarks, NSError *error) {
            dropoffPlacemark = [placemarks objectAtIndex:0];
            
            dropOffAddress = [[dropoffPlacemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
            
            
            
            if (!dropOffAnnotation) {
                dropOffAnnotation = [[DropoffAnnotation alloc] initiWithTitle:dropOffAddress Location:dropOffCoord];
                
            }
            else{
                dropOffAnnotation.coordinate = dropOffCoord;
                dropOffAnnotation.title = dropOffAddress;
                
            }
            
            pickUpLabel.text = pickupAddress;
            dropOffLabel.text = dropOffAddress;
            
            [mapView addAnnotation:dropOffAnnotation];
            [self routeRequested];
            
            
        }];
    }];
    
    
}





#pragma mark - Adding the Annotations manually for Pickup and Dropoff


-(void) addDropoffAnnotation{
    
    if(dropOffAnnotation){
        
        //remove pickup annotation from map
        [mapView removeAnnotation:dropOffAnnotation];
        
    }
    if(isItSearchResult){
        dropOffCoord   = dropOffSearchCoord;
        dropOffAddress = dropOffSearchAddress;
    }else{
        //get from pin
        dropOffCoord = [mapView centerCoordinate];
        
    }
    
    dropOffAnnotation = [[DropoffAnnotation alloc] initiWithTitle:dropOffAddress   Location:dropOffCoord];
    dropOffLabel.text = dropOffAddress;
    //add anottation to the map
    [mapView addAnnotation:dropOffAnnotation];
    
    _dropoffCoordinatesSetted = YES;
    
    //hidde UI
    pickUpImage.hidden = YES;
    pickupOrDropoffButton.hidden =  YES;
    pickupOrDropoffButton.enabled = NO;
    dropoffSearchButton.enabled = NO;
    
    
    
    
    
}

-(void)disableNavigation{
    
    self.navigationItem.leftBarButtonItem = nil;
    
    
}
-(void)enableNavigation{
    
    self.navigationItem.leftBarButtonItem = _revealButtonItem;
    
}
-(void)setOnRide:(NSNumber *)onRide{
    _onRide = onRide;
    if([onRide boolValue] == YES){
        //disable naviation out
        [self disableNavigation];
        
    }else{
        //enable navigatin out
        [self enableNavigation];
    }
    
}

-(void)addPickupAnnotation{
    
    
    
    
    if(pickupAnnotation){
        
        //remove pickup annotation from map
        [mapView removeAnnotation:pickupAnnotation];
        
    }
    if(isItSearchResult){
        pickupCoord = pickupSearchCoord;
        pickupAddress = pickupSearchAddress;
    }else{
        
        pickupCoord = [mapView centerCoordinate];
        
    }
    
    pickupAnnotation = [[PickupAnnotation alloc] initiWithTitle:pickupAddress Location:pickupCoord];
    pickUpLabel.text = pickupAddress;
    //add anottation to the map
    [mapView addAnnotation:pickupAnnotation];
    _pickupCoordinatesSetted = YES;
    
}
//this is not used anymore
//can erase it on the future
-(void)addTheRequiredAnnotationsForRoute{
    
    
    // for debugging
    withinCountry =  YES;
    if (withinCountry) {
        
        
        if (!ifDrop) {
            
            if (!isItSearchResult) {
                pickupCoord = [mapView centerCoordinate];
                
            }
            else{
                pickupCoord = pickupSearchCoord;
            }
            if (!pickupAnnotation) {
                if (!isItSearchResult) {
                    pickupAnnotation = [[PickupAnnotation alloc] initiWithTitle:pickupAddress Location:pickupCoord];
                    
                }
                else{
                    pickupAnnotation = [[PickupAnnotation alloc] initiWithTitle:pickupSearchAddress Location:pickupSearchCoord];
                    
                }
                
            }
            else{
                if (!isItSearchResult) {
                    pickupAnnotation.coordinate = pickupCoord;
                    pickupAnnotation.title = pickupAddress;
                }
                else{
                    pickupAnnotation.coordinate = pickupSearchCoord;
                    pickupAnnotation.title = pickupSearchAddress;
                    
                }
                
            }
            
            if (isItSearchResult) {
                pickUpLabel.text = pickupSearchAddress;
                
            }
            [self updateDriversLocation:self];
            
            [mapView addAnnotation:pickupAnnotation];
            [dropoffLocationLabel setHidden:NO];
            [dropoffSearchButton setHidden:NO];
            [dropOffLabel setHidden:NO];
            [self.dropofffIcon setHidden:NO];
            
            [pickUpImage setImage:[UIImage imageNamed:@"dropoff"]];
            ifDrop = YES;
            [pickupOrDropoffButton setTitle:@"Set drop-off location" forState:UIControlStateNormal];
            pickupSearchButton.enabled = NO;
            
            self.navigationItem.rightBarButtonItem.title = @"Cancel";
            self.navigationItem.rightBarButtonItem.enabled = YES;
            
        }
        
        else{
            
            if (!isItSearchResult) {
                dropOffCoord = [mapView centerCoordinate];
                
            }
            else{
                dropOffCoord = dropOffSearchCoord;
                
                
            }
            
            if (!dropOffAnnotation) {
                
                if(isItSearchResult){
                    dropOffAddress = dropOffSearchAddress;
                    dropOffCoord = dropOffSearchCoord;
                }
                
                dropOffAnnotation = [[DropoffAnnotation alloc] initiWithTitle:dropOffAddress Location:dropOffCoord];
                
            }
            else{
                if (!isItSearchResult) {
                    dropOffAnnotation.coordinate = dropOffCoord;
                    dropOffAnnotation.title = dropOffAddress;
                    
                }
                
                else{
                    dropOffAnnotation.coordinate = dropOffSearchCoord;
                    dropOffAnnotation.title = dropOffSearchAddress;
                }
            }
            
            if (isItSearchResult) {
                dropOffLabel.text = dropOffSearchAddress;
                
            }
            
            [mapView addAnnotation:dropOffAnnotation];
            [pickUpImage setHidden:YES];
            [pickupOrDropoffButton setHidden:YES];
            dropoffSearchButton.enabled = NO;
            
            routeFixed = YES;
            [self routeRequested];
            
            [UIView animateWithDuration:2.0 animations:^{
                dropOffBottomContraint.constant = 10;
                requestRideButton.hidden=NO;
                
            }];
            
            
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Alfred is not yet available in this area"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    
}

#pragma mark - Requesting of Rides
//request or cancel ride button pressed
//the button changes deppending on context
- (IBAction)requestRide:(id)sender {
    
    ifTimerShootsCancel = NO;
    
    if (!inRequest) {
        
        balance = [[PFUser currentUser][@"Balance"] doubleValue];
        
        _ridePrice  =  [(NSNumber*)(_selectedDriver[@"driverStatus"][@"pricePerSeat"]) doubleValue] * [_seatsRequested doubleValue] * 100;
        
        // isDriverSelected = true;
        if(![[PFUser currentUser][@"PhoneVerified"] boolValue]){
            
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Ooops! "
                                                           description:@"You must verify your phone number to request an Alfred\nGo to your profile to continue."
                                                                  type:TWMessageBarMessageTypeInfo];
            //
            //            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:nil message:@"Please verify your phone number in your profile" delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil] ;
            //            [alertView setTag:PHONE_VERIFY_ALERT_TAG];
            //            [alertView show];
            
            return;
            
        }
        
        if (!isDriverSelected) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Looking for an Alfred?"
                                                            message:@"Please choose one of the following options to proceed"
                                                           delegate:self
                                                  cancelButtonTitle:@"Choose on map"
                                                  otherButtonTitles:@"Alfred list",nil];
            alert.tag= CHOOSE_ALFRED_ALERT_TAG;
            [alert show];
            
        }else{

            if (balance < _ridePrice) {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Low Balance"
                                                                message:@"Please add balance to your wallet."
                                                               delegate:self
                                                      cancelButtonTitle:@"Accept"
                                                      otherButtonTitles:nil];
                alert.tag=0;
                [alert show];
                
            }
            
            else{
                
                //driver selected and balance is okey
                
                [cancelRideRequestTimer invalidate];
                cancelRideRequestTimer = nil;
                
                cancelRideRequestTimer = [NSTimer scheduledTimerWithTimeInterval:RIDE_REQUEST_EXPIRATION_TIME target: self selector: @selector(cancelRideRequestFromTimer:) userInfo: nil repeats: NO ];
                requestLabel.hidden = NO;
                requestImageView.hidden = NO;
                
                [requestRideButton setTitle:@"CANCEL REQUEST" forState:UIControlStateNormal];
                inRequest = YES;
                
                self.navigationItem.rightBarButtonItem.enabled = NO;
                //send ride request to the drivers
                
                _rideRequest = [PFObject objectWithClassName:@"RideRequest"];
                
                NSAssert(_selectedDriver!= nil, @"The driver selected is invalid");
                
                _rideRequest[@"accepted"] = @NO;
                
                _rideRequest[@"driver"] = _selectedDriver;
                _rideRequest[@"seats"] = _seatsRequested;
                _rideRequest[@"ridePrice"] = [NSNumber numberWithDouble: _ridePrice];
                _rideRequest[@"requestedBy"] = [PFUser currentUser];
                
                _rideRequest[@"pickupLat"] = [NSNumber numberWithDouble:pickupCoord.latitude];
                _rideRequest[@"pickupLong"] = [NSNumber numberWithDouble:pickupCoord.longitude ];
                _rideRequest[@"dropoffLat"] = [NSNumber numberWithDouble:dropOffCoord.latitude];
                _rideRequest[@"dropoffLong"] = [NSNumber numberWithDouble:dropOffCoord.longitude ];
                _rideRequest[@"finished"] = @NO;
                _rideRequest[@"requested"] = @YES;
                
                //the address can be null if it was not calculated properly
                if(pickupAddress == NULL || [pickupAddress length] == 0){
                    pickupAddress = @"Unknown address";
                }
                if(dropOffAddress == NULL || [dropOffAddress length] == 0){
                    dropOffAddress = @"Unknown address";
                }
                
                _rideRequest[@"pickupAddress"] = pickupAddress;
                _rideRequest[@"dropoffAddress"] = dropOffAddress;
                
                [_rideRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    
                    if(succeeded){
                        //here automatically a push is sent to the driver from parse with cloud code
                        NSLog(@"Ride request sent sucesfully");
                        
                    }else{
                        NSLog(@"Failed to send ride request");
                        //TODO: cancel it
                        
                        NSDictionary *dimensions = @{@"User": [PFUser currentUser].objectId, @"Code":@"RideRequestFailed"};
                        
                        //                        [PFAnalytics trackEvent:@"error" dimensions:dimensions];
                    }
                }];
                // [self openTheDriverView];
            }
        }
    }
    
    else{
        NSLog(@"Canceling ride request");
        
        requestLabel.hidden = YES;
        requestImageView.hidden = YES;
        
        [requestRideButton setTitle:@"LOOK FOR AN ALFRED" forState:UIControlStateNormal];
        inRequest = NO;
        
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        [self cancelRideRequest:self];
        
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    NSLog(@"Clicked button at index");
    if(buttonIndex == 1){
        [self performSegueWithIdentifier:@"DriverListSegueID" sender:self];
        
    }else{
        _annotationInteract = YES;
    }
    
}
/*
 * Called when driver requested starts from the driver details view
 */
-(void)didRequestForActiveDriverChosenForRide:(NSNotification *)notification
{
    
    isDriverSelected = true;

    //this array contains the following data
    // DriverID
    // RequestRideID
    // MessageboardID
    
    driverSelectedArray = [notification object];
    NSString *selectedDriverID = driverSelectedArray[0];
    
    //get here number of seats
    _seatsRequested = (NSNumber*)driverSelectedArray[1];
    assert([_seatsRequested intValue] > 0 );
    
    [HUD showUIBlockingIndicator];
    PFQuery * query = [PFQuery queryWithClassName:@"_User"];
    [query includeKey:@"driverStatus"];
    [query includeKey:@"driverRating"];
    [query getObjectInBackgroundWithId:driverSelectedArray[0] block:^(PFObject * _Nullable object, NSError * _Nullable error) {

        [HUD hideUIBlockingIndicator];
        if(!error){
            
            _selectedDriver = (PFUser*)object;
            isDriverSelected = YES;
            
//            NSString *title =[NSString stringWithFormat:@"SEND REQUEST TO %@", [selectedDriver[@"FirstName"] uppercaseString]];
//            [self.requestRideButton setTitle:title forState:UIControlStateNormal ];
            
            //now that the driver is selected we send the request stright away
            [self requestRide:nil];
            
        }else{
            isDriverSelected = false;
            
        }
    }];
}

-(void)didRequestForInactiveDriverChosenForRide:(NSNotification *)notification
{
    isActiveDriverChosen = NO;
    isDriverSelected = true;
    //    driverSelectedID = [notification object];
    driverSelectedArray = [notification object];
    
    //get here number of seats
    _seatsRequested = (NSNumber*)driverSelectedArray[1];
    assert([_seatsRequested intValue] > 0 );
    _rideRequest[@"seats"] = _seatsRequested;
    
    [_rideRequest saveInBackground];
    [HUD showUIBlockingIndicatorWithText:@"Getting Alfred data.."];
    PFQuery * query = [PFQuery queryWithClassName:@"_User"];
    [query getObjectInBackgroundWithId:driverSelectedArray[0] block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if(!error){
            
            _selectedDriver = (PFUser*)object;
            
            
        }else{
            isDriverSelected = false;
            
        }
        [HUD hideUIBlockingIndicator];
    }];
    
}



-(void)requestRideForAllTheAvailableDriver{
    
    
    [self requestActiveRide:self];
    
    
    
}



//LOOK FOR AN ALFRED from all active drivers

-(void)requestActiveRide:(id)sender{
    
    //get driver selected
    
    
    NSString *driverID =  driverSelectedArray[0];
    NSString *rideRequestID = driverSelectedArray[1];
    
    
    PFQuery *query = [PFUser query];
    
    [query getObjectInBackgroundWithId:driverID block:^(NSObject * object, NSError * error){
        
        
        PFQuery * selectedDriverQuery = [PFInstallation query];
        [selectedDriverQuery whereKey:@"user" containedIn:@[object]];
        
        
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:selectedDriverQuery ];
        
        NSDictionary *data = @{
                               @"alert" : @"Hello Alfred, want to take this ride?",
                               @"rid" : _rideRequest.objectId,
                               @"seats": _seatsRequested,
                               @"key" : @"RIDE_REQUEST",
                               @"badge": @"Increment"
                               };
        
        [push setData:data];
        [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(error){
                NSLog(@"Failed to send push");
                NSLog(error.localizedDescription);
                
            }else{
                NSLog(@"Push succeeded");
            }
            
        }];
        
        
    }];
    
}



//request ride from all inactive drivers

-(void)requestInactiveRide:(id)sender{
    
    NSString *driverID = driverSelectedArray[0];
    _seatsRequested = driverSelectedArray[1];
    //   NSString *rideRequestID = driverSelectedArray[1];
    
    NSLog(@"Request ride for inactive driver");
    
    
    _rideRequest[@"seats"] = _seatsRequested;
    
    
    [_rideRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){
            PFQuery * selectedDriverQuery = [PFInstallation query];
            
            [selectedDriverQuery whereKey:@"user" equalTo:_selectedDriver];
            //[selectedDriverQuery whereKey:@"user" containedIn:@[[PFUser currentUser]]];
            
            
            
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:selectedDriverQuery ];
            
            
            
            [push setData:@{@"alert" : @"Hello Alfred, want to take this ride?",
                            @"rid" : _rideRequest.objectId,
                            @"key" : @"RIDE_REQUEST",
                            @"badge": @"Increment",
                            @"seats":_seatsRequested
                            }];
            [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(error){
                    NSLog(@"Failed to send push");
                    NSLog(error.localizedDescription);
                    
                }else{
                    NSLog(@"Push succeeded");
                }
                
            }];
        }
    }];
    
    
    
    
    
    
}




#pragma mark - Cancellation of Ride Request (Needs to be updated)



-(void)cancelRideRequestFromTimer:(id)sender{
    
    ifTimerShootsCancel = YES;
    NSLog(@"Ride request timer expired");
    [self cancelRideRequest:self];
}


-(void)notifyRideCancelToDriver{
    
    
    
    
    
    NSLog(@"User requested cancel ride");
    
    NSString * key = @"RIDE_REQUEST_CANCELLED";
    
    _rideRequest[@"canceled"]= @YES;
    
    // this sends a push to the driver that the ride was canceled by the user
    // the push is send with cloud code
    //
    [_rideRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        self.onRide = @NO;
        
        
    }];
    
    
    
    
}
-(void)cancelRideRequest:(id)sender{
    
    [cancelRideRequestTimer invalidate];
    
    cancelRideRequestTimer = nil;
    
    isDriverSelected = NO;
    self.onRide = @NO;
    
    requestLabel.hidden = YES;
    requestImageView.hidden = YES;
    [requestRideButton setTitle:@"LOOK FOR AN ALFRED" forState:UIControlStateNormal];
    inRequest = NO;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    ifTimerShootsCancel = NO;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Cancelled"
                                                    message:@"Sorry please try again."
                                                   delegate:self
                                          cancelButtonTitle:@"Accept"
                                          otherButtonTitles:nil];
    alert.tag=3;
    
    [alert show];
    
    _rideRequest[@"canceled"] = @YES;
    _rideRequest[@"accepted"] = @NO;
    [_rideRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        self.onRide = @NO;
    }];
    
    isRideAccepted = NO;
    
}

#pragma mark - Ride Rejected By Driver
-(void)didRequestForMessageBoardRideRejected:(NSNotification *)notification{
    
    [cancelRideRequestTimer invalidate];
    cancelRideRequestTimer = nil;
    
    [requestImageView setHidden:true];
    [requestLabel setHidden:true];
    
    
    isRideAccepted = NO;
    
    [driverView setHidden:YES];
    
    [self cancelPickup:self];
    [self cancelPickup:self];
    [requestRideButton setTitle:@"LOOK FOR AN ALFRED" forState:UIControlStateNormal];
    inRequest = NO;
    
    
    requestRideDecisionPopupViewController = [[RideRequestDecisionViewController alloc] initWithNibName:@"RideRequestDecisionViewController" bundle:nil];
    
    
    requestRideDecisionPopupViewController.decision = @"Your ride was cancelled by driver.\nPlease request again.";
    requestRideDecisionPopupViewController.isAccepted = NO;
    [requestRideDecisionPopupViewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:requestRideDecisionPopupViewController animated:YES completion:nil];
    
    
    
}

#pragma mark - Check on any Active Ride for user


-(void)checkForUserStatus{
    
    
    if(_rideRequest == nil){
        
        
        PFQuery *query =[PFQuery queryWithClassName:@"RideRequest"];
        [query whereKey:@"requestedBy" equalTo:[PFUser currentUser]];
        [query whereKey:@"accepted" equalTo:@YES];
        [query whereKey:@"finished" notEqualTo:@YES];
        [query whereKey:@"declined" notEqualTo:@YES];
        [query whereKey:@"canceled" notEqualTo:@YES];
        [query whereKey:@"canceledByDriver" notEqualTo:@YES];
        [query includeKey:@"driver"];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if(!error ){
                if(objects.count > 0){
                    
                    [self activateUserInRideMode];
                    _rideRequest = [objects lastObject];
                    
                    PFUser *driver  = _rideRequest[@"driver"];
                    
                    [self clearRoute];
                    
                    isRideAccepted = YES;
                    routeFixed = YES;
                    
                    pickupAddress= _rideRequest[@"pickupAddress"];
                    dropOffAddress = _rideRequest[@"dropoffAddress"];
                    NSNumber *pickupLat = _rideRequest[@"pickupLat"];
                    NSNumber *pickupLong = _rideRequest[@"pickupLong"];
                    
                    
                    
                    NSNumber *dropoffLat=_rideRequest[@"dropoffLat"];
                    NSNumber *dropoffLong = _rideRequest[@"dropoffLong"];
                    self.pickUpLabel.text = pickupAddress;
                    self.dropOffLabel.text = dropOffAddress;
                    
                    
                    pickupCoord.latitude = [pickupLat doubleValue];
                    pickupCoord.longitude = [pickupLong doubleValue];
                    
                    dropOffCoord.latitude = [dropoffLat doubleValue];
                    dropOffCoord.longitude = [dropoffLong doubleValue];
                    if(pickupAnnotation!= nil)
                        [self.mapView removeAnnotation:pickupAnnotation];
                    
                    pickupAnnotation = [[PickupAnnotation alloc] initiWithTitle:pickupAddress Location:pickupCoord];
                    if(dropOffAnnotation != nil)
                        [self.mapView removeAnnotation:dropOffAnnotation];
                    dropOffAnnotation = [[DropoffAnnotation alloc] initiWithTitle:dropOffAddress Location:dropOffCoord];
                    
                    
                    [self.mapView addAnnotation:pickupAnnotation];
                    [self.mapView addAnnotation:dropOffAnnotation];
                    [self routeRequested];
                    
                    
                    [self openTheDriverView:driver];
                    
                }
            }else{
                NSLog(@"Failed to retrieve ride requests for user");
                NSLog(error.localizedDescription);
                
            }
        }];
    }
    
    //    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    //        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //        NSString *token = [prefs stringForKey:@"token"];
    //        [[NSUserDefaults standardUserDefaults] synchronize];
    //
    //        NSLog(@"Token: %@",token);
    //
    //        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    //        [manager.requestSerializer setValue:token forHTTPHeaderField:@"tokenId"];
    //
    //
    //        NSString* URL = [NSString stringWithFormat:@"http://ec2-52-74-6-189.ap-southeast-1.compute.amazonaws.com:8080/getActiveRide?id=%@",token];
    //
    //
    //        [manager GET:URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    //            NSLog(@"Active Ride Data: %@", responseObject);
    //            NSString* message =responseObject[@"message"];
    //
    //            if ([message isEqualToString:@"Active Ride Data retrieved succesfully."]) {
    //                isItRetrieval = YES;
    //
    //                if (responseObject[@"messageBoardId"]) {
    //                    NSString* rideIDE =responseObject[@"requestRideId"];
    //                    [self getMessageBoardData:rideIDE message:@"Active message board ride."];
    //
    //
    //                }
    //                else{
    //                    NSString* rideIdEE =responseObject[@"rideId"];
    //
    //                    [self getNormalRideData:rideIdEE message:@"Active ride."];
    //
    //
    //                }
    //
    //                [self activateUserInRideMode];
    //            }
    //
    //            else if ([message isEqualToString:@"No Active Ride data found."]){
    //
    //
    //            }
    //
    //        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    //            NSLog(@"Error: %@", [error localizedDescription]);
    //
    //        }];
    //        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    //
    //        });
    //    });
}





#pragma mark - Get Message Board Ride data





-(void)getMessageBoardData:(NSString*)rideId message:(NSString*)messages{
    
    
    if (!isRideAccepted) {
        isRideAccepted = YES;
        
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *token = [prefs stringForKey:@"token"];
    NSString *driverId = [prefs stringForKey:@"driverId"];
    
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"tokenId"];
    
    NSString* URL = [NSString stringWithFormat:@"http://ec2-52-74-6-189.ap-southeast-1.compute.amazonaws.com:8080/getBoardRideData?requestRideId=%@",rideId];
    
    [manager GET:URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        
        retrievedDict = responseObject;
        
        NSString* riderName =responseObject[@"driverName"];
        NSString* driverIDFromData =responseObject[@"driverId"];
        
        
        NSString* userMobileDirect =responseObject[@"driverMobile"];
        driverPhone = userMobileDirect;
        NSString* usermobile = [NSString stringWithFormat:@"Cell: %@",userMobileDirect];
        
        NSString* driverProfilePic =responseObject[@"driverProfilePic"];
        
        
        NSString* driverRating =[NSString stringWithFormat:@"Rating: 0.00"];
        
        
        NSString* message =responseObject[@"message"];
        
        if ([message isEqualToString:@"Data retrieved succesfully."]) {
            
            
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            
            
            if([prefs boolForKey:@"isDriver"]) {
                
                int driver = [driverId intValue];
                int compareDriver = [driverIDFromData intValue];
                
                if (driver != compareDriver) {
                    
                    [self openTheDriverView:nil];
                    
                }
            }
            else{
                
                [self openTheDriverView:nil];
                
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        
    }];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"DriverListSegueID"]){
        //called to show the driver list
        
        DriverListViewController *vc = segue.destinationViewController;
        vc.driverList = driversArray;
        
    }
    if([segue.identifier isEqualToString:@"DriverDetailsSegue"]){
        
        DriverCalloutPopupViewController *vc = segue.destinationViewController;
        vc.driverLocation =  _selectedDriverLocation;
        
    }if([segue.identifier isEqualToString:@"rateDriver"]){
        
        RideRatingViewController *vc = segue.destinationViewController;
        NSAssert(_rideRequest != nil, @"Ride request can't be null");
        vc.rideRequest = _rideRequest;
    }
}



#pragma mark - Get Drivers location

//check the drivers availables and draw them on a map

-(void)updateDriversLocation:(id)sender{
    
    
    PFQuery *activeQuery = [PFQuery queryWithClassName:@"DriverStatus"];
    [activeQuery whereKey:@"active" equalTo:@YES];  // this means the user is in driver mode
    [activeQuery whereKey:@"inride" equalTo:@NO]; //this limit to only on ride
    
    //    [activeQuery quereKey:@"available" equalTo:@YES];
    
    
    // if the user set the dropoff coordinate then
    //the available alfreds are filtered according the
    //following rule
    // alfred location: within 500m of user pickup
    // alfred destination: within 300m of user dropoff
    
    if(_dropoffCoordinatesSetted){
        PFGeoPoint *userDestinationGeopoint = [PFGeoPoint geoPointWithLatitude:dropOffCoord.latitude longitude:dropOffCoord.longitude];
        [activeQuery whereKey:@"destination" nearGeoPoint:userDestinationGeopoint withinKilometers:2];
        
        //if the user set the dropoff coordinates now only the available drivers will appear
        [activeQuery whereKey:@"available" equalTo:@YES];
    }
    
    //query for drivers
    PFQuery *innerQuery = [PFUser query];
    [innerQuery whereKey:@"UserMode" notEqualTo:@YES];
    [innerQuery whereKey:@"driverStatus" matchesQuery:activeQuery];
    [innerQuery includeKey:@"driverRating"];
    //query for location of drivers
    
    NSTimeInterval TEN_SECONDS_AGO = - 10; // in seconds
    CLLocationCoordinate2D userLocation = mapView.userLocation.coordinate;
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserLocation"];
    
    // [query whereKey:@"updatedAt"
    //    greaterThanOrEqualTo:[NSDate dateWithTimeIntervalSinceNow: TEN_SECONDS_AGO]];
    if(_pickupCoordinatesSetted){
        
        PFGeoPoint *pickupLocationGeoPoint = [PFGeoPoint geoPointWithLatitude:pickupCoord.latitude longitude:pickupCoord.longitude];
        [query whereKey:@"location" nearGeoPoint:pickupLocationGeoPoint  withinKilometers: 2];
    }else{
        
        //TODO: user center map coordinate not pickup coordinate in this case
        PFGeoPoint *userLocationGeoPoint = [PFGeoPoint geoPointWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
        
        [query whereKey:@"location" nearGeoPoint:userLocationGeoPoint  withinKilometers: 1.5];
    }
    [query whereKey:@"user" matchesQuery:innerQuery];
    [query includeKey:@"user.driverRating"];
    [query includeKey:@"user.driverStatus"];
    
    
    
    
    //    [query whereKey:@"location" nearGeoPoint:[PFGeoPoint geoPointWithLatitude:userLocation.latitude    longitude:userLocation.longitude] withinKilometers: 10.0];
    
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
        if(!error){
            
            driversArray = objects;
            NSLog(@"Available drivers: %lu",(unsigned long)objects.count);
            [self addDriverAnnotations];
            
        }else{
            NSLog(@"Failed to get drivers or not drivers availables");
        }
        
    }];
    
    
}






#pragma mark - More, Center location and Call Driver Buttons

//this is called when user cancels ride
- (IBAction)cancelRideByUser:(id)sender {
    
    isDriverSelected = NO;
    
    assert(_rideRequest!=nil);
    
    NSLog(@"User requested cancel ride");
    
    isRideAccepted= NO;
    
    //[self notifyRideCancelToDriver];
    
    //do ui changes here
    inRequest = false;
    [self.mapView removeAnnotations:[mapView annotations]];
    [self clearRoute];
    routeFixed = NO;
    [self allowSetPickup];
    _dropoffCoordinatesSetted = NO;
    _pickupCoordinatesSetted = NO;
    self.driverView.hidden = YES;
    
    if(_canRefund){
        
        double balance = [[PFUser currentUser][@"balance"] doubleValue];
        balance += _ridePrice;
        [PFUser currentUser][@"balance"]= [NSNumber numberWithDouble:balance];
        [[PFUser currentUser] saveInBackground];
        _ridePrice = 0.0;
        _rideRequest[@"ridePrice"] = [NSNumber numberWithDouble:_ridePrice];
        _rideRequest[@"canceled"] = @YES;
        [_rideRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            self.onRide = @NO;
        }];
        
        isRideAccepted = NO;

    }else{
        
        
        //TODO: open feedback screen
        
    }
    
    //[PFAnalytics trackEvent:@"RideCanceledByUser" dimensions:@{@"User":[PFUser currentUser].objectId}];
    
}


- (IBAction)moreInfo:(id)sender {
    NSLog(@"Construct More Action");
    
}

- (IBAction)callDriver:(id)sender {
    
    
    
    NSString *phoneNumber = [@"telprompt://" stringByAppendingString:self.driverMobile.text];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}



- (IBAction)centerOnUsersLocation:(id)sender {
    [self updateLocationBarOnUserLocation];
    [mapView setRegion:region animated:YES];
    
    
}



#pragma mark - Annotations and their views


-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[PickupAnnotation class]]) {
        PickupAnnotation *pickUpAnnotation = (PickupAnnotation*)annotation;
        MKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"PickupAnnotation"];
        if (annotationView==nil) {
            annotationView = pickUpAnnotation.annotationView;
            
        }
        else
            annotationView.annotation = annotation;
        return annotationView;
    }
    
    else if ([annotation isKindOfClass:[DropoffAnnotation class]]){
        DropoffAnnotation *dropoffAnnotation = (DropoffAnnotation*)annotation;
        MKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"DropoffAnnotation"];
        if (annotationView==nil) {
            annotationView = dropoffAnnotation.annotationView;
            
        }
        else
            annotationView.annotation = annotation;
        return annotationView;
    }
    
    else if ([annotation isKindOfClass:[DriverAnnotation class]]){
        
        DriverAnnotation *driverAnnotation = (DriverAnnotation*)annotation;
        MKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"DriverAnnotation"];
        if (annotationView==nil) {
            annotationView = driverAnnotation.annotationView;
            
        }
        else
            annotationView.annotation = annotation;
        
        
        MKPlacemark *driverPlacemark = [[MKPlacemark alloc] initWithCoordinate: driverAnnotation.coordinate addressDictionary:nil];
        
        MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
        [request setSource:[[MKMapItem alloc] initWithPlacemark:driverPlacemark]];
        
        
        
        [request setDestination:[MKMapItem mapItemForCurrentLocation]];
        
        [request setTransportType:MKDirectionsTransportTypeAutomobile];
        [request setRequestsAlternateRoutes:NO];
        MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
            if ( ! error && [response routes] > 0) {
                MKRoute *route = [[response routes] objectAtIndex:0];
                //route.distance  = The distance
                //route.expectedTravelTime = The ETA
                [ driverAnnotation setETA: [NSString stringWithFormat:@"%2.1f mins", route.expectedTravelTime/60  ]];
            }
        }];
        
        
        annotationView.canShowCallout = YES;
        
        UIImageView *driverImage = [[UIImageView alloc ]initWithFrame:CGRectMake(0, 0, 30, 30)];
        UIImageView *phoneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 30, 30) ];
        [phoneImageView setImage:[UIImage imageNamed:@"phone_new"]];
        
        [driverImage sd_setImageWithURL: driverAnnotation.driverProfilePic placeholderImage:[UIImage imageNamed:@"blank profile"]];
        
        driverImage.layer.cornerRadius  = driverImage.layer.frame.size.width/2;
        driverImage.layer.masksToBounds = YES;
        driverImage.contentMode =  UIViewContentModeScaleAspectFit;
        
        annotationView.leftCalloutAccessoryView = driverImage;
        annotationView.rightCalloutAccessoryView = phoneImageView;
        
        return annotationView;
    }
    else
        return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    // Annotation is your custom class that holds information about the annotation
    if ([view.annotation isKindOfClass:[DriverAnnotation class]]) {
        DriverAnnotation *annot = view.annotation;
        //NSInteger index = [self.arrayOfDriverAnnotations indexOfObject:annot];
        // NSLog(@"%ld",(long)index);
        
        NSLog(@"Selected driver anotation");
        
        NSLog(@"%ld",(long)annot.tag);
        
        //if the user selected select from map
        if(_annotationInteract){
            
            [self driverAnnotationCallout:annot];
            _annotationInteract = NO;
        }
        
        
    }
    
    
}



#pragma mark - Alert View Dismiss

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    if(alertView.tag == 4){
        assert(inRequest);
        [self requestRide:nil];
    }
    
    if (alertView.tag == 0) {
        SWRevealViewController *revealController = [self revealViewController];
        UIViewController *frontViewController = revealController.frontViewController;
        UINavigationController *frontNavigationController =nil;
        
        if ( [frontViewController isKindOfClass:[UINavigationController class]] )
            frontNavigationController = (id)frontViewController;
        
        
        if ( ![frontNavigationController.topViewController isKindOfClass:[WalletViewController class]] )
            
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            WalletViewController *frontViewController = (WalletViewController *)[storyboard instantiateViewControllerWithIdentifier:@"WALLET_VIEW_CONTROLLER"];
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
            [revealController pushFrontViewController:navigationController animated:YES];
        }
        else{
            [revealController revealToggleAnimated:YES];
            
        }
    }
}



#pragma mark - Mapview Interaction and Delegatess


- (BOOL)mapViewRegionDidChangeFromUserInteraction
{
    UIView *view = self.mapView.subviews.firstObject;
    //  Look through gesture recognizers to determine whether this region change is from user interaction
    for(UIGestureRecognizer *recognizer in view.gestureRecognizers) {
        //        if(recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateEnded) {
        if( recognizer.state == UIGestureRecognizerStateEnded) {
            return YES;
        }
    }
    
    return NO;
}



- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    // mapChangedFromUserInteraction = [self mapViewRegionDidChangeFromUserInteraction];
    
    
    if(!routeFixed){
        pickupOrDropoffButton.hidden = YES;
        
        if (!ifDrop) {
            pickUpLabel.text = @"Updating Location..";
        }
        else{
            dropOffLabel.text = @"Updating Location..";
        }
    }
    else{
        
    }
    
    
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    //    if (mapChangedFromUserInteraction) {
    pickupOrDropoffButton.hidden = YES;
    if (!routeFixed) {
        
        [self updateLocationBar];
        
    }
    else{
        NSLog(@"Map location changed");
        
    }
    
    //    }
}

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
    
    
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    CLLocationCoordinate2D userCoordinate = aUserLocation.coordinate;
    
    region.span = span;
    region.center = userCoordinate;
    
}

#pragma mark - Location Bar Update


-(void)updateLocationBar{
    
    
    
    CLGeocoder *locator = [[CLGeocoder alloc]init];
    
    CLLocationCoordinate2D centre = [mapView centerCoordinate];
    
    double myLatitude = centre.latitude;
    double myLongitude = centre.longitude;
    
    CLLocation *location = [[CLLocation alloc]initWithLatitude:myLatitude longitude:myLongitude];
    
    
    //hide the button until we ge the address
    pickupOrDropoffButton.hidden = YES;
    
    
    [locator reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if(error){
            
            NSLog(@"Can't update location bar");
            NSLog([error description]);
            
        }else{
            
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            
            pickupOrDropoffButton.hidden = NO;
            
            
            if (!ifDrop) {
                pickupPlacemark = placemark;
                
                pickupAddress = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                pickUpLabel.text = pickupAddress;
                pickupCity = [placemark locality];
                
                //[self updateDriversLocation:self];
                
                if ([placemark.country isEqualToString:@"India"] || [placemark.country isEqualToString:@"United Kingdom"] || [placemark.country isEqualToString:@"United States"] ){
                    withinCountry = YES;
                    [availabilityBar setHidden:YES];
                    
                }
                else{
                    withinCountry = NO;
                    [availabilityBar setHidden:NO];
                    
                    
                }
                
                
            }
            else{
                dropoffPlacemark = placemark;
                
                if ([placemark.country isEqualToString:@"India"] || [placemark.country isEqualToString:@"United Kingdom"] || [placemark.country isEqualToString:@"United States"] ){
                    withinCountry = YES;
                    [availabilityBar setHidden:YES];
                    
                }
                else{
                    withinCountry = NO;
                    [availabilityBar setHidden:NO];
                    
                }
                
                dropOffAddress = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                dropOffLabel.text = dropOffAddress;
                
            }
            
        }
        
        
        
        
    }];
    
}


-(void)updateUserLocationOnServer:(NSTimer *)timer{
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            
            [PFCloud callFunctionInBackground:@"UpdateUserLocation"
                               withParameters:@{@"location": geoPoint}
                                        block:^(NSString *success, NSError *error) {
                                            if (!error) {
                                                
                                            } else {
                                                
                                            }
                                        }];
        } else {
            
        }
    }];
}



//update the location address according to the center coordinate on map
-(void)updateLocationBarOnUserLocation{
    
    CLGeocoder *locator = [[CLGeocoder alloc]init];
    
    CLLocationCoordinate2D centerCoordinate =[mapView centerCoordinate];
    
    _myLatitude =  centerCoordinate.latitude;
    _myLongitude = centerCoordinate.longitude;
    CLLocation *location = [[CLLocation alloc]initWithLatitude:_myLatitude longitude:_myLongitude];
    
    [locator reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if(!error){
            assert(placemarks);
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            
            if (!ifDrop) {
                pickupPlacemark = placemark;
                
                pickupAddress = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                if(pickupAddress.length > 0){
                    pickUpLabel.text = pickupAddress;
                }else{
                    pickUpLabel.text = @"Updating location..";
                }
                pickupCity = [placemark locality];
                
                //check if this must be called
                [self updateDriversLocation:self];
                
                
                
                
                if ([placemark.country isEqualToString:@"India"] || [placemark.country isEqualToString:@"United Kingdom"] || [placemark.country isEqualToString:@"United States"] ){
                    withinCountry = YES;
                    [availabilityBar setHidden:YES];
                    
                }
                else{
                    withinCountry = NO;
                    [availabilityBar setHidden:NO];
                    
                    
                }
                
                
            }
            else{
                dropoffPlacemark = placemark;
                
                if ([placemark.country isEqualToString:@"India"] || [placemark.country isEqualToString:@"United Kingdom"] || [placemark.country isEqualToString:@"United States"] ){
                    withinCountry = YES;
                    [availabilityBar setHidden:YES];
                    
                }
                else{
                    withinCountry = NO;
                    [availabilityBar setHidden:NO];
                    
                }
                
                dropOffAddress = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                dropOffLabel.text = dropOffAddress;
                
            }
            
        }
        else{
            NSLog(@"Can't get address for center coordinate on map");
            NSLog(@"%@", error.localizedDescription);
            
            // Delay execution for 1 sec and call again
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self updateLocationBarOnUserLocation];
            });
            
            ;
        }
        
    }];
}


-(void)allowSetDropOff{
    
    settingDropoffLocation = YES;
    _dropoffCoordinatesSetted = NO;
    dropoffLocationLabel.hidden = NO;
    dropoffSearchButton.enabled = YES;
    self.dropofffIcon.hidden = NO;
    
    [mapView removeAnnotation:dropOffAnnotation];
    
    [pickUpImage setImage:[UIImage imageNamed:@"dropoff"]];
    ifDrop = YES;
    [pickupOrDropoffButton setTitle:@"Set drop-off location" forState:UIControlStateNormal];
    pickupOrDropoffButton.enabled = YES;
    pickupSearchButton.enabled = NO;
    
    self.navigationItem.rightBarButtonItem.title = @"Cancel";
    self.navigationItem.rightBarButtonItem.enabled = YES;
    dropoffSearchButton.hidden = NO;
    dropOffLabel.hidden = NO;
    
    
    
}
// set pick up location selected
#pragma mark - Pickup Button Action
- (IBAction)pickupAction:(id)sender {
    
    
    isItSearchResult = NO;
    //set start annotation
    
    if(settingPickupLocation){
        [self addPickupAnnotation];
        settingPickupLocation = NO;
        
        //change UI to drop off
        [self allowSetDropOff];
        
    }
    else if(settingDropoffLocation){
        
        [self addDropoffAnnotation];
        settingDropoffLocation = NO;
    }
    
    if(_pickupCoordinatesSetted && _dropoffCoordinatesSetted) {
        routeFixed = YES;
        [self routeRequested];
        
        [UIView animateWithDuration:2.0 animations:^{
            dropOffBottomContraint.constant = 10;
            requestRideButton.hidden=NO;
            [requestRideButton setTitle:@"LOOK FOR AN ALFRED" forState:UIControlStateNormal];
        }];
        
    }
    
    // [self addTheRequiredAnnotationsForRoute];
    
}

#pragma mark - Search Bar Notification and Push


- (void) didRequestForSearchResult:(NSNotification *)notification
{
    isItSearchResult = YES;
    
    if (_pickupCoordinatesSetted) {
        
        dropoffPlacemark = [notification object];
        dropOffSearchCoord = dropoffPlacemark.location.coordinate;
        dropOffSearchAddress = [[dropoffPlacemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
        
        if ([dropoffPlacemark.country isEqualToString:@"India"] || [dropoffPlacemark.country isEqualToString:@"United Kingdom"] || [dropoffPlacemark.country isEqualToString:@"United States"] ){
            withinCountry = YES;
            [availabilityBar setHidden:YES];
            
        }
        else{
            withinCountry = NO;
            [availabilityBar setHidden:NO];
            
            
        }
        isItDropSearch = NO;
        
        if (routeFixed) {
            [self clearRoute];
            routeFixed = NO;
            [mapView removeAnnotation:dropOffAnnotation];
            
        }
        if (ifDrop && !routeFixed) {
            [mapView removeAnnotation:dropOffAnnotation];
            
        }
        [self addTheRequiredAnnotationsForRoute];
    }
    else{
        
        pickupPlacemark = [notification object];
        pickupSearchCoord = pickupPlacemark.location.coordinate;
        pickupSearchAddress = [[pickupPlacemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
        
        pickupCity = [pickupPlacemark locality];
        [self updateDriversLocation:self];
        if ([pickupPlacemark.country isEqualToString:@"India"] || [pickupPlacemark.country isEqualToString:@"United Kingdom"] || [pickupPlacemark.country isEqualToString:@"United States"] ){
            withinCountry = YES;
            [availabilityBar setHidden:YES];
            
        }
        else{
            withinCountry = NO;
            [availabilityBar setHidden:NO];
            
            
        }
        [self addPickupAnnotation];
        
        settingPickupLocation = NO;
        settingDropoffLocation = YES;
        [self addTheRequiredAnnotationsForRoute];
        CLLocationCoordinate2D coord = pickupSearchCoord;
        MKCoordinateRegion initialRegion = MKCoordinateRegionMakeWithDistance(coord, 1000.0, 1000.0);
        [mapView setRegion:initialRegion animated:YES];
        
    }
    
    
    
}


-(void)searchPopupForPickupView:(id)sender{
    isItDropSearch = NO;
    [self performSegueWithIdentifier:@"SearchViewPush" sender:self];
}

-(void)searchPopupForDropoffView:(id)sender{
    isItDropSearch = YES;
    [self performSegueWithIdentifier:@"SearchViewPush" sender:self];
}

#pragma mark - Ride Cancelled by Driver (Not in use)


-(void)didRequestForRideCancelByDriver:(NSNotification *)notification
{
    isRideAccepted = NO;
    
    [driverView setHidden:YES];
    
    [self cancelPickup:self];
    [self cancelPickup:self];
    [requestRideButton setTitle:@"LOOK FOR AN ALFRED" forState:UIControlStateNormal];
    inRequest = NO;
    
    requestRideDecisionPopupViewController = [[RideRequestDecisionViewController alloc] initWithNibName:@"RideRequestDecisionViewController" bundle:nil];
    
    requestRideDecisionPopupViewController.decision = @"Your ride was cancelled by driver.\nPlease request again.";
    requestRideDecisionPopupViewController.isAccepted = NO;
    [requestRideDecisionPopupViewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:requestRideDecisionPopupViewController animated:YES completion:^{
        
        _rideRequest[@"canceledByDriver"] = @YES;
        [_rideRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(succeeded){
                NSLog(@"Ride canceled by driver saved in parse");
            }
        }];
        
        
    }];
    
    
}


#pragma mark - Get normal Ride Request Data (Not in use)

-(void)getNormalRideData:(NSString*)ride message:(NSString*)messages{
    
    
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *token = [prefs stringForKey:@"token"];
    NSString *driverId = [prefs stringForKey:@"driverId"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"tokenId"];
    
    NSString* URL_SIGNIN = [NSString stringWithFormat:@"http://ec2-52-74-6-189.ap-southeast-1.compute.amazonaws.com:8080/getRideData?rideId=%@",ride];
    
    [manager GET:URL_SIGNIN parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        
        NSString* riderName =responseObject[@"driverName"];
        
        
        NSString* userMobileDirect =responseObject[@"driverMobile"];
        driverPhone = userMobileDirect;
        NSString* usermobile = [NSString stringWithFormat:@"Cell: %@",userMobileDirect];
        
        
        
        double driverRatingDouble = [[responseObject objectForKey:@"driverRating"] doubleValue];
        NSString* driverRating =[NSString stringWithFormat:@"Rating: %.2f",driverRatingDouble];
        NSString* driverIDFromData =responseObject[@"driverId"];
        
        
        NSString* message =responseObject[@"message"];
        
        if ([message isEqualToString:@"Data retrieved succesfully."]) {
            
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            
            
            if([prefs boolForKey:@"isDriver"]) {
                
                int driver = [driverId intValue];
                int compareDriver = [driverIDFromData intValue];
                
                if (driver != compareDriver) {
                    
                    
                    self.driverName.text = riderName;
                    self.driverMobile.text = usermobile;
                    self.driverRating.text =driverRating;
                    [self rideRequestDecisionMade:messages];
                    
                    
                }
                
            }
            else{
                
                self.driverName.text = riderName;
                self.driverMobile.text = usermobile;
                self.driverRating.text =driverRating;
                [self rideRequestDecisionMade:messages];
                
            }
            
            
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        
    }];
    
    
    
    
}

#pragma mark - Deallocation

- (void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [[NSNotificationCenter defaultCenter] removeObserver: self name:@"didRequestForRideEnd" object:nil];
}

-(void)didRequestForStoppingAllMappingServices:(id)sender{
    [self.locationManager stopUpdatingLocation];
    
    [driverLocationTimer invalidate];
    driverLocationTimer = nil;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
