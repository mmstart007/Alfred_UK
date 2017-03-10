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

@interface RiderViewController ()<SWRevealViewControllerDelegate>{
    
    //this variable holds the state when the rider got the acceptation push form the driver and he process the request
    BOOL _processingRequest;
    BOOL _pickupCoordinatesSetted, _dropoffCoordinatesSetted;
    BOOL settingPickupLocation, settingDropoffLocation;
    BOOL _canRefund;
    bool _annotationInteract;
    
    double _myLatitude, _myLongitude;
    
    PFUser *_selectedDriver;
    PFObject *_selectedDriverLocation;
    PFObject *_lastRideInfo;

    NSNumber *_seatsRequested;
    UIBarButtonItem *_revealButtonItem;
    
    CHDraggingCoordinator *_draggingCoordinator;
}

@property (nonatomic) NSNumber* onRide;

@end

@implementation RiderViewController

@synthesize mapView,locationManager,region, pickUpImage,bryantPark, bryantParkAnn;
@synthesize pickupOrDropoffButton,pickUpLabel,pickupAnnotation,pickupCoord,pickupAddress,pickupPlacemark;
@synthesize dropOffLabel,dropOffAnnotation,dropOffCoord,dropOffAddress,dropoffPlacemark,dropofffIcon;
@synthesize dropoffSearchButton;
@synthesize routeDetails,pickupCity,routeDistance;
@synthesize cancelButton;
@synthesize pickupSearchButton,availabilityBar;
@synthesize pickupSearchAddress,pickupSearchCoord,dropOffSearchAddress,dropOffSearchCoord,requestRideButton;
@synthesize queryDriverTimer, updateLocationTimer, cancelRideRequestTimer;
@synthesize requestImageView,requestLabel,isRideAccepted;
@synthesize driverView;
@synthesize retrievedDict;
@synthesize driversArray, arrayOfDriverAnnotations, selectedDriverArray;
@synthesize balance;
@synthesize requestRideDecisionPopupViewController;
@synthesize rideID, driverID;
@synthesize dropOffBottomContraint;



//this is not hidding anymore, just changing visual appareance
- (void)hideNavigationController {
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:NULL action:NULL];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _annotationInteract = NO;
    _pickupCoordinatesSetted = NO;
    _dropoffCoordinatesSetted = NO;
    _processingRequest = NO;
    isChooseOnMap = NO;
    isItRetrieval = NO;
    isActiveDriverChosen = NO;
    isDriverSelected = NO;
    mapChangedFromUserInteraction = NO;
    routeFixed = NO;
    inRequest  = NO;
    ifDrop = NO;
    settingPickupLocation = YES;
    settingDropoffLocation = YES;
    //check is location is within country
    withinCountry = NO;
    isItDropSearch = NO;
    isItSearchResult = NO;
    
    _lastRideInfo = nil;
    
    //configure driver view and make it hidden
    self.driverView.layer.cornerRadius = 0.5;
    self.driverView.layer.shadowOpacity = 0.8;
    self.driverView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
    [driverView setHidden:YES];
    
    //register for notifications
    [self watchForNotifications];
    
    requestLabel.hidden = YES;
    requestRideButton.hidden=YES;
    requestImageView.hidden = YES;
    [availabilityBar setHidden:YES];
    
    arrayOfDriverAnnotations = [[NSMutableArray alloc]init];

    UIImage *drawerImage = [[UIImage imageNamed:@"menu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _revealButtonItem = [[UIBarButtonItem alloc] initWithImage:drawerImage
                                                         style:UIBarButtonItemStylePlain target:self action:@selector(revealToggle:)];
    cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelPickup:)];

    SWRevealViewController *revealViewController = self.revealViewController;
    self.navigationItem.leftBarButtonItem = _revealButtonItem;

    if (revealViewController) {
        [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
        [self.navigationItem.leftBarButtonItem setTarget:self.revealViewController];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    //search pickup address
    [pickupSearchButton addTarget:self action:@selector(searchPopupForPickupView:) forControlEvents:UIControlEventTouchUpInside];
    [dropoffSearchButton addTarget:self action:@selector(searchPopupForDropoffView:) forControlEvents:UIControlEventTouchUpInside];
    
    [dropoffSearchButton setHidden:YES];
    [dropOffLabel setHidden:YES];
    
    mapView.delegate = self;
    [mapView setRotateEnabled:NO];
    //array with available drivers
    
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
    
    pickUpLabel.text = @"Updating Location..";
    
    [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self
                                   selector: @selector(updateUserLocationBar)
                                   userInfo: nil
                                    repeats: NO];
    
    queryDriverTimer = [NSTimer scheduledTimerWithTimeInterval: 10.0
                                                        target: self
                                                      selector: @selector(queryDriverPathways:)
                                                      userInfo: nil
                                                       repeats: YES];

    updateLocationTimer = [NSTimer scheduledTimerWithTimeInterval: 20.0
                                                           target: self
                                                         selector: @selector(updateUserLocation)
                                                         userInfo: nil
                                                          repeats: YES];


    if([[PFUser currentUser][@"UserMode"] boolValue] == NO){
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DriverViewController *frontViewController = (DriverViewController *)[storyboard instantiateViewControllerWithIdentifier:@"DriverMainID"];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
        [revealViewController pushFrontViewController:navigationController animated:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self hideNavigationController];
    
    self.onRide = @NO;
    
    if (!queryDriverTimer) {
        queryDriverTimer = [NSTimer scheduledTimerWithTimeInterval: 10.0
                                                            target: self
                                                          selector: @selector(queryDriverPathways:)
                                                          userInfo: nil
                                                           repeats: YES];
    }
    if (!updateLocationTimer) {
        updateLocationTimer = [NSTimer scheduledTimerWithTimeInterval: 20.0
                                                           target: self
                                                         selector: @selector(updateUserLocation)
                                                         userInfo: nil
                                                          repeats: YES];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.locationManager stopUpdatingLocation];
    
    [queryDriverTimer invalidate];
    queryDriverTimer = nil;
    [updateLocationTimer invalidate];
    updateLocationTimer = nil;
}

/*
 * @summary Register class to watch for different notifications
 */
- (void)watchForNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForStoppingAllMappingServices:) name:@"didRequestForStoppingAllMappingServices" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForActiveDriverChosenForRide:) name:@"didRequestForActiveDriverChosenForRide" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForSearchResult:) name:@"didRequestForSearchResult" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForRideAcceptedForDriver:) name:@"didRequestForRideAcceptedForDriver" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForRideCancelByDriver:) name:@"didRequestForRideCancelByDriver" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForRideEnd:) name:@"didRequestForRideEnd" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForOpenRatingView:) name:@"didRequestForOpenRatingView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndedRating:) name:@"didEndedRating" object:nil];

    /*// sent when the ride is accepted by the requested driver
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForInactiveDriverChosenForRide:) name:@"didRequestForInactiveDriverChosenForRide" object:nil];
     
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForRideDecisionCloseView:) name:@"didRequestForRideDecisionCloseView" object:nil];
    // sent by the driver when the ride is ended
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForMessageBoardRideStarted:) name:@"didRequestForMessageBoardRideStarted" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForMessageBoardRidePickedUp:) name:@"didRequestForMessageBoardRidePickedUp" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForMessageBoardRideRejected:) name:@"didRequestForMessageBoardRideRejected" object:nil]; */
}

-(void)didRequestForRideDecisionCloseView:(NSNotification *)notification
{
    
    NSArray *boolDecision = [notification object];
    isRideAccepted = [[boolDecision objectAtIndex:0] boolValue];
    
}

#pragma mark - Select Alfred Notification
/*
 * Called when driver requested starts from the driver details view
 */
-(void)didRequestForActiveDriverChosenForRide:(NSNotification *)notification
{
    isDriverSelected = YES;
    selectedDriverArray = [notification object];
    
    [self requestRide:self];
}

#pragma mark - Drawing of the route, Clearing and the overlay render

-(void)routeRequested {
    
    //called when pick up and drop off points where set properly
    //draw route on map
    [HUD showUIBlockingIndicatorWithText:@"Routing ..."];
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
            NSLog( @"%@", error.localizedDescription);
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
                
            } else {
                pickupCoord = pickupSearchCoord;
            }
            if (!pickupAnnotation) {
                if (!isItSearchResult) {
                    pickupAnnotation = [[PickupAnnotation alloc] initiWithTitle:pickupAddress Location:pickupCoord];
                    
                } else {
                    pickupAnnotation = [[PickupAnnotation alloc] initiWithTitle:pickupSearchAddress Location:pickupSearchCoord];
                    
                }
                
            } else {
                if (!isItSearchResult) {
                    pickupAnnotation.coordinate = pickupCoord;
                    pickupAnnotation.title = pickupAddress;
                } else {
                    pickupAnnotation.coordinate = pickupSearchCoord;
                    pickupAnnotation.title = pickupSearchAddress;
                    
                }
            }
            
            if (isItSearchResult) {
                pickUpLabel.text = pickupSearchAddress;
                
            }
            
            [mapView addAnnotation:pickupAnnotation];
            [dropoffSearchButton setHidden:NO];
            [dropOffLabel setHidden:NO];
            [self.dropofffIcon setHidden:NO];
            
            [pickUpImage setImage:[UIImage imageNamed:@"dropoff"]];
            ifDrop = YES;
            [pickupOrDropoffButton setTitle:@"Set drop-off location" forState:UIControlStateNormal];
            pickupSearchButton.enabled = NO;
            
            self.navigationItem.rightBarButtonItem = cancelButton;
            
        } else  {
            
            if (!isItSearchResult) {
                dropOffCoord = [mapView centerCoordinate];
                
            } else {
                dropOffCoord = dropOffSearchCoord;

            }
            if (!dropOffAnnotation) {
                
                if(isItSearchResult){
                    dropOffAddress = dropOffSearchAddress;
                    dropOffCoord = dropOffSearchCoord;
                }
                
                dropOffAnnotation = [[DropoffAnnotation alloc] initiWithTitle:dropOffAddress Location:dropOffCoord];
                
            } else {
                if (!isItSearchResult) {
                    dropOffAnnotation.coordinate = dropOffCoord;
                    dropOffAnnotation.title = dropOffAddress;
                    
                } else {
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
                requestRideButton.hidden = NO;
                
            }];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Alfred is not yet available in this area"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Ride Mode
#pragma mark - Requesting of Rides
//request or cancel ride button pressed
//the button changes deppending on context
- (IBAction)requestRide:(id)sender {
    
    if (!inRequest) {

        balance = [NSNumber numberWithDouble:[[PFUser currentUser][@"Balance"] doubleValue]];
        if(![[PFUser currentUser][@"PhoneVerified"] boolValue]){
            
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Ooops! "
                                                           description:@"You must verify your phone number to request an Alfred\nGo to your profile to continue."
                                                                  type:TWMessageBarMessageTypeInfo];

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
            
        } else {
            
            PFUser *selectedDriver      = selectedDriverArray[0];
            PFGeoPoint *pickupLocation  = selectedDriverArray[1];
            PFGeoPoint *dropoffLocation = selectedDriverArray[2];
            NSNumber *seats             = selectedDriverArray[3];
            NSNumber *price             = selectedDriverArray[4];
            
            assert([seats intValue] > 0 );
            
            if (self.balance < price) {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Low Balance"
                                                                message:@"Please add balance to your wallet."
                                                               delegate:self
                                                      cancelButtonTitle:@"Accept"
                                                      otherButtonTitles:nil];
                alert.tag=0;
                [alert show];
                
            } else {
                /*
                 *  driver selected and balance is okey
                 */
                
                [cancelRideRequestTimer invalidate];
                cancelRideRequestTimer = nil;
                
                cancelRideRequestTimer = [NSTimer scheduledTimerWithTimeInterval: RIDE_REQUEST_EXPIRATION_TIME
                                                                          target: self
                                                                        selector: @selector(cancelRideRequestFromTimer:)
                                                                        userInfo: nil
                                                                         repeats: NO ];
                requestLabel.hidden = NO;
                requestImageView.hidden = NO;
                
                [requestRideButton setTitle:@"CANCEL REQUEST" forState:UIControlStateNormal];
                inRequest = YES;
                
                self.navigationItem.rightBarButtonItem = nil;
                
                /*
                 *  send ride request to the drivers
                 */
                
                [PFCloud callFunctionInBackground:@"RequestRide"
                                   withParameters:@{@"driver": [selectedDriver objectId],
                                                    @"pickupLocation": pickupLocation,
                                                    @"dropoffLocation": dropoffLocation,
                                                    @"pickupAddress": pickupAddress,
                                                    @"dropoffAddress": dropOffAddress,
                                                    @"seats": seats,
                                                    @"price": price}
                                            block:^(PFObject *object, NSError *error) {
                                                if (!error) {
                                                    _lastRideInfo = object;
                                                    rideID = _lastRideInfo.objectId;
                                                    _processingRequest = NO;
                                                    NSLog(@"Ride request sent sucesfully ================ ");
                                                } else {
                                                    NSLog(@"Failed to send ride request ================");
                                                }
                                            }];

            }
        }
    } else {
        NSLog(@"Canceled ride request");
        requestLabel.hidden = YES;
        requestImageView.hidden = YES;
        [requestRideButton setTitle:@"LOOK FOR AN ALFRED" forState:UIControlStateNormal];
        inRequest = NO;
        isDriverSelected = NO;
        self.navigationItem.rightBarButtonItem = cancelButton;
        
        [self cancelRideRequest:@"REQUEST_CANCELED"];
    }
}

#pragma mark - Ride Accepted by Driver

/*
 * Called when the ride request sent to the driver is accepted by him
 */

-(void)didRequestForRideAcceptedForDriver:(NSNotification *)notification
{
    if(!_processingRequest){
        _processingRequest = YES;
        inRequest = NO;
        
        //hide it to load the new data
        [driverView setHidden:YES];
        [requestRideButton setTitle:@"CANCEL REQUEST" forState:UIControlStateNormal];
        
        requestRideDecisionPopupViewController = [[RideRequestDecisionViewController alloc] initWithNibName:@"RideRequestDecisionViewController" bundle:nil];
        NSString *decision = [NSString stringWithFormat:@"Your ride was accepted by Driver"];
        requestRideDecisionPopupViewController.decision = decision;
        requestRideDecisionPopupViewController.isAccepted = YES;
        [requestRideDecisionPopupViewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:requestRideDecisionPopupViewController animated:YES completion:^() {
            
            [cancelRideRequestTimer invalidate];
            cancelRideRequestTimer = nil;
            
            if (!isRideAccepted) {
                
                isRideAccepted = YES;
                
                NSArray*  rideRequestArray = [notification object];
                
                // this is the notification object when a new ride request
                // is accepted by the driver
                // the notification contains the objectId of the request
                // and the push is sent from CloudCode
                // so the first object is the ride id
                assert(rideRequestArray.count > 0);
                
                driverID = [rideRequestArray firstObject];
                
                //the ride id should be equal to the ride request made by the user
                // so lets assert that
                
                NSLog(@"Driver id: %@", driverID);
                
                //retrieve driver data
                //maybe this query is not needed as i alrady know the driver and ride request
                //should optimize it later
                
                [PFCloud callFunctionInBackground:@"GetUser"
                                   withParameters:@{@"userId": driverID}
                                            block:^(PFUser *user, NSError *error) {

                                                if (!error) {
                                                    self.onRide  = @YES;
                                                    _selectedDriver = user;
                                                    [self openTheDriverView:user];
                                                } else {
                                                    NSLog(@"Get Ride request Failed !!!!");
                                                    [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Accept" otherButtonTitles:nil] show];
                                                }
                                            }];
            }
            
        }];
    }
}

-(void)openTheDriverView:(PFUser *)driver{

    self.driverName.text = driver[@"FullName"];
    self.driverMobile.text = driver[@"Phone"];
    //PFObject *ratingData = driver[@"driverRating"];
    NSString *driverProfilePic = driver[@"ProfilePicUrl"];
    
    if (![driverProfilePic isKindOfClass:[NSNull class]]) {
        [self.driverProfilePic sd_setImageWithURL:[NSURL URLWithString:driverProfilePic] placeholderImage:[UIImage imageNamed:@"blank profile"]];
    }
    
    self.driverProfilePic.layer.cornerRadius = self.driverProfilePic.frame.size.height / 2;
    self.driverProfilePic.layer.masksToBounds = YES;
    self.driverProfilePic.layer.borderWidth = 0;
    
    if (isRideAccepted) {
        
        requestLabel.hidden = YES;
        requestImageView.hidden = YES;
        //move the dropoff to the botom
        dropOffLabel.hidden = NO;
        dropoffSearchButton.hidden = NO;
        dropoffSearchButton.enabled = NO;
        
        //hide the request button at the bottom
        //requestRideButton.hidden=YES;
        [driverView setHidden:NO];
        
        if (isItRetrieval) {
            
            [self retrieveTheAnnotationsAndRoute:retrievedDict];
            
        }
    }
}

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
            NSLog(@"%@", [error description]);
        }
        
        pickupPlacemark = [placemarks objectAtIndex:0];
        
        pickupAddress = [[pickupPlacemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
        
        if (!pickupAnnotation) {
            pickupAnnotation = [[PickupAnnotation alloc] initiWithTitle:pickupAddress Location:pickupCoord];
            
        } else {
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
                
            } else {
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

#pragma mark - Ride Cancelled by Driver (Not in use)

-(void)didRequestForRideCancelByDriver:(NSNotification *)notification
{
    NSString *message = [notification object];
    [driverView setHidden:YES];
    requestLabel.hidden = YES;
    requestImageView.hidden = YES;
    self.navigationItem.rightBarButtonItem = cancelButton;
    
    inRequest = NO;
    isRideAccepted = NO;
    isDriverSelected = NO;
    [requestRideButton setTitle:@"LOOK FOR AN ALFRED" forState:UIControlStateNormal];
    
    requestRideDecisionPopupViewController = [[RideRequestDecisionViewController alloc] initWithNibName:@"RideRequestDecisionViewController" bundle:nil];

    requestRideDecisionPopupViewController.decision = message;
    requestRideDecisionPopupViewController.isAccepted = NO;
    [requestRideDecisionPopupViewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:requestRideDecisionPopupViewController animated:YES completion:^{
        
    }];
}

#pragma mark - Ride End and Rating View

-(void)didRequestForRideEnd:(NSNotification *)notification
{
    NSLog(@"Request for ride ended");

    NSString *rideCost = _lastRideInfo[@"price"];
    double rideCostDouble = [rideCost doubleValue];
    NSString* decisionStr = [NSString stringWithFormat:@"Ride Cost: $%.2f", rideCostDouble / 100];
    NSLog(@"%@", decisionStr);
    
    requestRideDecisionPopupViewController = [[RideRequestDecisionViewController alloc] initWithNibName:@"RideRequestDecisionViewController" bundle:nil];
    requestRideDecisionPopupViewController.decision = decisionStr;
    requestRideDecisionPopupViewController.isAccepted = NO;
    requestRideDecisionPopupViewController.openRatingView = YES;
    
    [requestRideDecisionPopupViewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:requestRideDecisionPopupViewController animated:YES completion:nil];
    
}

// called when the Driver did rated to the Passenger on the RideRatingView
-(void)didEndedRating:(NSNotification *)notification {
    
    _dropoffCoordinatesSetted = NO;
    _processingRequest = NO;
    _annotationInteract = NO;
    isChooseOnMap = NO;
    isItRetrieval = NO;
    isActiveDriverChosen = NO;
    isDriverSelected = NO;
    mapChangedFromUserInteraction = NO;
    routeFixed = NO;
    inRequest  = NO;
    ifDrop = NO;
    settingPickupLocation = YES;
    settingDropoffLocation = YES;
    withinCountry = NO;
    isItDropSearch = NO;
    isItSearchResult = NO;
    isRideAccepted = NO;
    
    [driverView setHidden:YES];
    
    self.onRide = @NO;
    
    [self.mapView removeAnnotations:[mapView annotations]];
    [self clearRoute];
    [self allowSetPickup];
    
}

#pragma mark - Rating to the Driver

-(void)didRequestForOpenRatingView:(NSNotification *)notification
{
    [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self
                                   selector: @selector(openRatingView:) userInfo: nil repeats: NO];
}

-(void)openRatingView:(id)sender{
    
    [self performSegueWithIdentifier:@"rateDriver" sender:nil];
    
}

#pragma mark - Ride Cancelled by Passenger

- (IBAction)cancelRideByUser:(id)sender {
    
    inRequest = NO;
    isDriverSelected = NO;
    _processingRequest = NO;
    self.navigationItem.rightBarButtonItem = cancelButton;
    [self cancelRideRequest:@"PASSENGER_CANCELED_RIDE"];
}

-(void)cancelRideRequestFromTimer:(id)sender{
    
    NSLog(@"Ride request timer expired");
    [self cancelRideRequest:@"REQUEST_CANCELED"];
}

-(void)cancelRideRequest:(NSString *)sender {
    
    [cancelRideRequestTimer invalidate];
    cancelRideRequestTimer = nil;
    isDriverSelected = NO;
    self.onRide = @NO;
    requestLabel.hidden = YES;
    requestImageView.hidden = YES;
    [requestRideButton setTitle:@"LOOK FOR AN ALFRED" forState:UIControlStateNormal];
    inRequest = NO;
    self.navigationItem.rightBarButtonItem = cancelButton;
    self.navigationItem.leftBarButtonItem.enabled = YES;
    [UIView animateWithDuration:2.0 animations:^{
        driverView.hidden = YES;
        
    }];
    
    [HUD showUIBlockingIndicatorWithText:@"Canceling ..."];
    [PFCloud callFunctionInBackground:@"DeleteRide"
                       withParameters:@{@"rideId": rideID,
                                        @"reason": sender}
                                block:^(NSString *success, NSError *error) {
                                    [HUD hideUIBlockingIndicator];
                                    if (!error) {
                                        
                                        isRideAccepted = NO;
                                        
                                        /*NSString *message = ([sender isEqualToString:@"REQUEST_CANCELED"] ? @"Ride request Canceled" : @"Ride canceled");
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message
                                                                                        message:@"please try again."
                                                                                       delegate:self
                                                                              cancelButtonTitle:@"Accept"
                                                                              otherButtonTitles:nil];
                                        alert.tag=3;
                                        [alert show]; */
                                        
                                    } else {
                                        NSLog(@"RequestCancel request Failed !!!!");
                                    }
                                }];

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

-(void)disableNavigation {
    
    self.navigationItem.leftBarButtonItem = nil;

}

-(void)enableNavigation {
    
    self.navigationItem.leftBarButtonItem = _revealButtonItem;
    
}

#pragma mark - Remove Ride Mode

- (void)allowSetPickup {

    //hide drop off settings
    [dropoffSearchButton setHidden:YES];
    [dropOffLabel setHidden:YES];
    [dropofffIcon setHidden:YES];
    [requestRideButton setHidden:YES];
    
    _pickupCoordinatesSetted = NO;
    ifDrop = NO;
    
    [mapView removeAnnotation:pickupAnnotation];
    
    [pickUpImage setImage:[UIImage imageNamed:@"pickup"]];
    pickUpImage.hidden = NO;
    [pickupOrDropoffButton setTitle:@"Set Pickup Point" forState:UIControlStateNormal];
    pickupOrDropoffButton.enabled = YES;

    self.navigationItem.rightBarButtonItem = nil;
    pickupSearchButton.enabled = YES;
}

#pragma mark - Alert View Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSLog(@"Clicked button at index");
    if(buttonIndex == 1){
        [self performSegueWithIdentifier:@"DriverListSegueID" sender:self];
        
    }else{
        _annotationInteract = YES;
    }
    
}

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
        NSURL *profilePicUrl = [NSURL URLWithString:[driverAnnotation.driverProfilePic stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [driverImage sd_setImageWithURL: profilePicUrl placeholderImage:[UIImage imageNamed:@"blank profile"]];
        
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
    //if (mapChangedFromUserInteraction) {
    pickupOrDropoffButton.hidden = YES;
    if (!routeFixed) {
        [self updateLocationBar];
    }
    else{
        NSLog(@"Map location changed");
    }
    //}
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

-(void)updateLocationBar {
    
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
            NSLog(@"%@", [error description]);
            
        }else{
            
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            pickupOrDropoffButton.hidden = NO;
            
            if (!ifDrop) {
                pickupPlacemark = placemark;
                
                pickupAddress = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                pickUpLabel.text = pickupAddress;
                pickupCity = [placemark locality];
                
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

//update the location address according to the center coordinate on map
-(void)updateUserLocationBar {
    
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
                [self updateUserLocationBar];
            });
            
            ;
        }
        
    }];
}

-(void)allowSetDropOff{
    
    _dropoffCoordinatesSetted = NO;
    dropoffSearchButton.enabled = YES;
    self.dropofffIcon.hidden = NO;
    
    [mapView removeAnnotation:dropOffAnnotation];
    
    [pickUpImage setImage:[UIImage imageNamed:@"dropoff"]];
    ifDrop = YES;
    [pickupOrDropoffButton setTitle:@"Set drop-off location" forState:UIControlStateNormal];
    pickupOrDropoffButton.enabled = YES;
    pickupSearchButton.enabled = NO;
    
    self.navigationItem.rightBarButtonItem = cancelButton;
    dropoffSearchButton.hidden = NO;
    dropOffLabel.hidden = NO;
}

- (void) didRequestForSearchResult:(NSNotification *)notification {
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

-(void)didRequestForStoppingAllMappingServices:(id)sender{
    [self.locationManager stopUpdatingLocation];
    
    [queryDriverTimer invalidate];
    queryDriverTimer = nil;
    [updateLocationTimer invalidate];
    updateLocationTimer = nil;
}

#pragma mark - UIButton Action.

- (IBAction)pickupAction:(id)sender {
    
    isItSearchResult = NO;
    //set start annotation
    
    if(settingPickupLocation) {
        [self addPickupAnnotation];
        settingPickupLocation = NO;
        settingDropoffLocation = NO;
        
        //change UI to drop off
        [self allowSetDropOff];
        
    }
    else if(!settingDropoffLocation) {
        
        [self addDropoffAnnotation];
        settingPickupLocation = YES;
        
    }
    if(_pickupCoordinatesSetted && _dropoffCoordinatesSetted) {
        routeFixed = YES;
        [self routeRequested];
        
        [UIView animateWithDuration:2.0 animations:^{
            requestRideButton.hidden = NO;
            [requestRideButton setTitle:@"LOOK FOR AN ALFRED" forState:UIControlStateNormal];
        }];
    }
}

-(void)cancelPickup:(id)sender{
    
    //the user must select a driver again
    isChooseOnMap = NO;
    
    if (!routeFixed ) {
        [self allowSetPickup];
        settingPickupLocation = YES;
        settingDropoffLocation = YES;
    }
    
    if (routeFixed) {
        [self clearRoute];
        [self allowSetDropOff];
        
        settingDropoffLocation = NO;
        settingPickupLocation = NO;
        routeFixed = NO;
        [pickUpImage setHidden:NO];
        [pickupOrDropoffButton setHidden:NO];
        
        [UIView animateWithDuration:2.0 animations:^{
            requestRideButton.hidden = YES;
            
        }];
    }
}

- (IBAction)callDriver:(id)sender {
    
    NSString *phoneNumber = [@"telprompt://" stringByAppendingString:self.driverMobile.text];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (IBAction)centerOnUsersLocation:(id)sender {
    [self updateUserLocationBar];
    [mapView setRegion:region animated:YES];
}

#pragma mark - Update User Location To the Server

-(void)updateUserLocation {
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        
        if (!error) {
            CLGeocoder *locator = [[CLGeocoder alloc]init];
            CLLocation *location = [[CLLocation alloc]initWithLatitude: geoPoint.latitude longitude: geoPoint.longitude];
            
            [locator reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                
                if(!error){
                    CLPlacemark *placemark = [placemarks objectAtIndex:0];
                    NSDictionary * addressDictionary = placemark.addressDictionary;
                    NSMutableArray *formatedAddressLines = [addressDictionary valueForKey:@"FormattedAddressLines"];
                    NSString *currentAddress = [formatedAddressLines componentsJoinedByString:@", "];
                    if (currentAddress.length == 0) {
                        currentAddress = @"Undetermined";
                    }
                    
                    NSLog(@"Current Passenger Address is ========== %@ ======== %@", currentAddress, geoPoint);
                    
                    [PFCloud callFunctionInBackground:@"UpdateUserLocation"
                                       withParameters:@{@"location": geoPoint,
                                                        @"locationAddress": currentAddress}
                                                block:^(NSString *success, NSError *error) {
                                                    if (!error) {
                                                        NSLog(@"UpdatePassengerLocation request Success !!!!");
                                                    } else {
                                                        NSLog(@"UpdatePassengerLocation request Failed !!!!");
                                                    }
                                                }];
                } else {
                    
                    NSLog(@"%@", error.localizedDescription);
                }
            }];
        } else {
            NSLog(@"Failed to get Passenger current location ======= ");
        }
    }];
}

#pragma mark - Get Drivers From Server

- (void)queryDriverPathways:(NSTimer *)timer {
    
    void (^callCloud)(PFGeoPoint *, PFGeoPoint *) = ^void(PFGeoPoint *pickupLocation, PFGeoPoint *dropoffLocation) {
        NSLog(@"Called Query Driver Pathways ===================== ");
        [PFCloud callFunctionInBackground:@"QueryDriverPathways"
                           withParameters:@{@"pickupLocation": pickupLocation,
                                            @"dropoffLocation": dropoffLocation}
                                    block:^(NSArray *object, NSError *error) {
                                        if (!error) {
                                            driversArray = object;
                                            NSLog(@"Available drivers: %lu",(unsigned long)object.count);
                                            [self addDriverAnnotations];
                                            
                                        } else {
                                            NSLog(@"Failed to get drivers or not drivers availables");
                                        }
                                    }];

    };
    
    if (!settingPickupLocation) {
        PFGeoPoint *pickupLocation = [PFGeoPoint geoPointWithLatitude:pickupCoord.latitude longitude:pickupCoord.longitude];
        PFGeoPoint *dropoffLocation = [PFGeoPoint geoPointWithLatitude:0 longitude:0];
        NSLog(@"Pickup Location ======== %@", pickupLocation);
        callCloud(pickupLocation, dropoffLocation);
    } else if (!settingDropoffLocation) {
        PFGeoPoint *pickupLocation = [PFGeoPoint geoPointWithLatitude:pickupCoord.latitude longitude:pickupCoord.longitude];
        PFGeoPoint *dropoffLocation = [PFGeoPoint geoPointWithLatitude:dropOffCoord.latitude longitude:dropOffCoord.longitude];
        callCloud(pickupLocation, dropoffLocation);
        NSLog(@"Pickup Location ======== %@", pickupLocation);
        NSLog(@"Dropoff Location ======== %@", dropoffLocation);
    } else {
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            if (!error) {
                callCloud(geoPoint, [PFGeoPoint geoPointWithLatitude:0 longitude:0]);
            }
            
        }];
    }
}

#pragma mark - Adding the annotations (Automatically)

-(void)addDriverAnnotations {
    
    DriverAnnotation *driverAnnotation;

    CLLocationCoordinate2D driverCoordinates;
    double latDouble;
    double longDouble;
    
    NSString* dropAddress=@"";
    NSString* dropLatitude=@"";
    NSString* dropLongitude=@"";
    NSString* driverName=@"";
    NSString* driverRating=@"";
    NSString* driverMobile=@"";
    NSString* driverProfilePic=@"";
    
    [self.mapView removeAnnotations:arrayOfDriverAnnotations];
    [arrayOfDriverAnnotations removeAllObjects];
    
    for (PFObject* driverData in driversArray) {
        
        PFUser *userData = driverData[@"driver"];
        PFGeoPoint *loc = userData[@"location"];
        
        dropAddress = driverData[@"destinationAddress"];
        latDouble = loc.latitude;
        longDouble = loc.longitude;
        driverCoordinates = CLLocationCoordinate2DMake(latDouble, longDouble);

        driverName = userData[@"FullName"];
        driverMobile = userData[@"Phone"];
        NSString* usermobile = [NSString stringWithFormat:@"Cell: %@",driverMobile];

        PFObject *ratingObject = userData[@"driverRating"];
        driverRating =[NSString stringWithFormat:@"Rating: %3.2lf", [ratingObject[@"rating"] doubleValue]];
        
        driverProfilePic = userData[@"ProfilePicUrl"];
        NSString *numOfSeats = driverData[@"availableSeats"];
        
        driverAnnotation = [[DriverAnnotation alloc] initWithTitle: driverName Location:driverCoordinates];
        driverAnnotation.activeRide = YES; // now only active rides, but setting this just in case
        [driverAnnotation setActiveRide:NO]; //check from user data, maybe change driver info
        [driverAnnotation setDriverMobile:usermobile];
        [driverAnnotation setDriverProfilePic:driverProfilePic];
        [driverAnnotation setDriverRating:driverRating];
        [driverAnnotation setDriverID: userData.objectId];
        [driverAnnotation setDropAddress:dropAddress];
        [driverAnnotation setDropLatitude:dropLatitude];
        [driverAnnotation setDropLongitude:dropLongitude];
        [driverAnnotation setAvailbleSeats: numOfSeats];
        [arrayOfDriverAnnotations addObject:driverAnnotation];
        
        [mapView addAnnotation:driverAnnotation];
        
    }
}

#pragma mark - show driver details for active driver

-(void)driverAnnotationCallout:(DriverAnnotation*)driverAnnot{
    
    long  selectedDriverIndex  =  [arrayOfDriverAnnotations indexOfObject:driverAnnot];
    
    _selectedDriverLocation = driversArray[selectedDriverIndex];
    //get the user for the selected driver
    _selectedDriver = _selectedDriverLocation[@"driver"];
    
    [self performSegueWithIdentifier:@"DriverDetailsSegue" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"DriverListSegueID"]){
        //called to show the driver list
        
        DriverListViewController *vc = segue.destinationViewController;
        vc.driverList = driversArray;
        
    }
    if([segue.identifier isEqualToString:@"DriverDetailsSegue"]){
        
        DriverCalloutPopupViewController *vc = segue.destinationViewController;
        vc.driverLocation =  _selectedDriverLocation;
        
    }
    if([segue.identifier isEqualToString:@"rateDriver"]){
        RideRatingViewController *vc = segue.destinationViewController;
        NSAssert(_lastRideInfo != nil, @"Ride request can't be null");
        NSLog(@"Rate to the Driver =================== /n %@ /n ======================= %@", _lastRideInfo, _selectedDriver);
        vc.rideRequest = _lastRideInfo;
    }
}





@end
