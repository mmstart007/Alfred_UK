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



@import MapKit;


@interface DriverViewController ()<SWRevealViewControllerDelegate, CHDraggingCoordinatorDelegate, DriverHeadDelegate>
{
    double myLatitude;
    double myLongitude;
    UIBarButtonItem *cancelButton;
    PFUser * user;
    
    PFObject *activeRide;
    CLLocationCoordinate2D destinationCoord;
    CLLocationCoordinate2D driverCoord;
    
    
    //handle the drawing of chat heads
    CHDraggingCoordinator *_draggingCoordinator;
    KLCPopup *popup;
    NSMutableArray *_rideRequests;
    PFObject* _lastRideRequest;
    NSMutableArray *_chatHeads;
    NSTimer *_mapCenterTimer ;
    DriverHeadViewController *vc;
    UINavigationItem *_revealButtonItem;
    
}

@property NSNumber *rideConfigured;
@property NSNumber *destinationSetted;


@end

@implementation DriverViewController

@synthesize mapView,region;
@synthesize currentAddress,startRideButton;
@synthesize cancelButton,currentLocationLabel,locationManager,driverLatLoc,driverLongLoc,driverLocationTimer;
@synthesize rideRequestArray;
@synthesize requestRidePopupViewController,pickupAddress,dropoffAddress,pickupPlacemark,dropoffPlacemark;
@synthesize dropOffAddress,dropOffAnnotation,dropOffCoord;
@synthesize requestRideDecisionPopupViewController,userLat,userLong,routeDetails,pickUpCoord,destLat,destLong,isDriverAccepted,rideID;
@synthesize calucaltateDistanceTimer,driverDistanceTravelled,distanceCovered,driverStartLat,driverStartLong;
@synthesize userView,bottomLayoutConstrint;
@synthesize userProfilePic,userMobile,userName,userRating,userPhone;
@synthesize rideRatingViewController,messageBoardDict;
@synthesize messageBoardStartRideViewController,selectedUserDict,endMessageBoardButton;
@synthesize messageBoardUsersBGView;

@synthesize cancelRideButton,callButton,messageBoardUsersViewController,rideEndArray;



// center the map view into the user location

- (IBAction)centerInDriverLocation:(id)sender {
    
    [ self  centerOnUsersLocation:sender];
    
}

- (IBAction)searchAddress:(id)sender {
    
    NSLog(@"Search Address");
    
    [self performSegueWithIdentifier:@"SearchViewPush" sender:self];
    
}

//called when the dropoff button was touched to set destination

-(void)addChatHead:(int)rideRequestIndex{
    
    PFObject *rideRequest = [_rideRequests objectAtIndex:rideRequestIndex];
    
    UIImageView* imgView =[[UIImageView alloc] init];
    [imgView sd_setImageWithURL:rideRequest[@"requestedBy"][@"ProfilePicUrl"] placeholderImage:[UIImage imageNamed:@"profile_pic_teja"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        CHDraggableView *draggableView = [CHDraggableView draggableViewWithImage:imgView.image];
        
        draggableView.tag = rideRequestIndex;
        
        [draggableView snapViewCenterToPoint: CGPointMake(self.view.layer.frame.size.width,100)  edge:0];
        
        draggableView.delegate = _draggingCoordinator;
        [self.navigationController.view addSubview:draggableView];
        [_chatHeads addObject:draggableView];
    }];
}

-(void)setupChatHeads{
    _draggingCoordinator = [[CHDraggingCoordinator alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow] draggableViewBounds:self.view.bounds];
    _draggingCoordinator.delegate = self;
    _draggingCoordinator.snappingEdge = CHSnappingEdgeBoth;
}

- (void)draggingCoordinator:(CHDraggingCoordinator *)coordinator presentViewForDraggableView:(CHDraggableView*)view
{
    
    // get chat head index
    int index =    [_chatHeads indexOfObject:view];
    PFObject *rideRequest = _rideRequests[index];
    
    NSLog(@"Detected");
    
    // Show in popup
    KLCPopupLayout layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter,KLCPopupVerticalLayoutBottom);
    
    vc = [[DriverHeadViewController alloc]initWithNibName:@"DriverHeadViewController" bundle:nil];
    
    [vc setRideRequest:rideRequest];
    vc.delegate = self;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    CGRect viewFrame = vc.view.frame;
    viewFrame.size.width = screenWidth;
    vc.view.frame =  viewFrame;

    popup = [KLCPopup popupWithContentView:vc.view
                                  showType:KLCPopupShowTypeSlideInFromBottom
                               dismissType:KLCPopupDismissTypeSlideOutToBottom
                                  maskType:KLCPopupMaskTypeDimmed
                  dismissOnBackgroundTouch:YES
                     dismissOnContentTouch:NO];
    [popup showWithLayout:layout];
    
}

-(void)draggingCoordinator:(CHDraggingCoordinator *)coordinator dismissViewForDraggableView:(CHDraggableView*)view
{
    NSLog(@"Detected");
}


- (void) didRequestForSearchResult:(NSNotification *)notification
{
    
    self.rideConfigured = @NO;
    
    self.navigationItem.rightBarButtonItem =  cancelButton;
    
    NSLog(@"Search finished");
    CLPlacemark *placemark =  [notification object];
    
    self.locationSearchButton.enabled = NO;
    
    startRideButton.hidden = NO;
    destinationCoord = placemark.location.coordinate;
    
    NSDictionary * addressDictionary = placemark.addressDictionary;
    NSMutableArray *formatedAddressLines = [addressDictionary valueForKey:@"FormattedAddressLines"];
    [formatedAddressLines removeLastObject];
    [formatedAddressLines removeLastObject];
    
    NSString *address = [formatedAddressLines componentsJoinedByString:@", "];
    
    [self setDestinationOnMapWithCoordiante:destinationCoord andAddress:address];
    
    // dropOffAnnotation = [[DropoffAnnotation alloc] initiWithTitle:@"Destination" Location:destinationCoord];
    // trace route from origin to destination
    // [self traceRouteWithStartingCoordinates:pickUpCoord end:destinationCoord];
}

-(void)setDestinationOnMapWithCoordiante:(CLLocationCoordinate2D)destinationCoord andAddress:(NSString*)address{

    self.rideConfigured = @NO;
    self.destinationSetted = @YES;
    self.navigationItem.rightBarButtonItem =  cancelButton;

    startRideButton.hidden = NO;
    
    [startRideButton setTitle:@"ADVERTISE YOUR JOURNEY" forState:UIControlStateNormal];
    [startRideButton removeTarget:self action:@selector(endRide:) forControlEvents:UIControlStateNormal];
    [startRideButton removeTarget:self action:@selector(navigateToDestination:) forControlEvents:UIControlStateNormal];
    
    [startRideButton addTarget:self action:@selector(startRideButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    self.locationSearchButton.enabled = NO;
    
    _driverStatus[@"destination"] = [PFGeoPoint geoPointWithLatitude:destinationCoord.latitude longitude:destinationCoord.longitude];
    
    if(address.length == 0 || address.length == 0){
        _driverStatus[@"destinationAddress"] = @"Undetermined";
    }else{
        _driverStatus[@"destinationAddress"] = address;
    }
   
    [_driverStatus saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){
            NSLog(@"Saved driver destination in parse");
            
        }
    }];
    
    dropOffAnnotation = [[DropoffAnnotation alloc] initiWithTitle:@"Your Destination" Location:destinationCoord];
    
    [mapView addAnnotation:dropOffAnnotation];
    [_dropOffButton setHidden:YES];
    [_dropOffPinImage setHidden:YES];
    
    // get driver origin
    driverCoord = [[mapView userLocation] coordinate];
    
    // trace route from origin to destination
    
    [self traceRouteWithStartingCoordinates:driverCoord end:destinationCoord];
}

- (IBAction)setDestinationTouchedUpInside:(id)sender {
    
    destinationCoord =  [mapView centerCoordinate] ;
    _destinationSetted = @YES;
    [self setDestinationOnMapWithCoordiante:     [mapView centerCoordinate] andAddress:currentAddress];
    
}

-(void)traceRouteWithStartingCoordinates: (CLLocationCoordinate2D)startCoordinate end:(CLLocationCoordinate2D) endCoordinate {
    
    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
    
    MKPlacemark *dropPlacemark = [[MKPlacemark alloc] initWithCoordinate: startCoordinate addressDictionary:nil];
    MKPlacemark *pickPlacemark = [[MKPlacemark alloc] initWithCoordinate: endCoordinate addressDictionary:nil];
    
    [directionsRequest setSource:[[MKMapItem alloc] initWithPlacemark:pickPlacemark]];
    [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:dropPlacemark]];
    directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    
    [HUD showUIBlockingIndicatorWithText:@"Routing.."];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        NSLog(@"Calculating directions completed");
        
        if (error) {
            
            [[[UIAlertView alloc]initWithTitle:@"Error!" message:@"Route services is not available right now" delegate:nil cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil] show ];
        }
        else{
            assert(response);
            if(routeDetails){
                
                [self.mapView removeOverlay:routeDetails.polyline];
            }
            
            routeDetails = response.routes.lastObject;
            
            [self.mapView addOverlay:routeDetails.polyline];
            
            [self showRouteOnMap];
            
        }
        
        [HUD hideUIBlockingIndicator];
    }];
    
}

-(void)configureNavigationBar {
    
    [self.navigationController.navigationBar setTranslucent:NO];
   
    self.navigationItem.title = @"Driver's Map";
    
}

- (void)viewDidLoad {
    
    //ui configuration
    
    [self configureView];
    
    // user status configuration
    self.rideConfigured = @NO;
    
    _destinationSetted = @NO;
    
    isItRetrieval = NO;
    _lastRideRequest = nil;
    
    //this is for what?
    selectedUserDict = [[NSDictionary alloc] init];
    
    [self loadDriverStatus];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

-(void)appDidBecomeActive:(NSNotification*)notification{
    
    //check for any changes in my ride when i was out?
    [self checkForRideChanges];
    
}

-(void)checkForRideChanges{

    //check the ride status here
    
    PFObject *rideRequest =[self.rideRequestArray firstObject];
    
    [rideRequest fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if([rideRequest[@"canceledByDriver"] boolValue] ){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRideRequestCancel" object:@[object.objectId]];
            
        }
    }];

}


-(void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    
}


-(void )configureView{
    
    [super viewDidLoad];
    
    self.userView.layer.cornerRadius = 0.5;
    self.userView.layer.shadowOpacity = 0.8;
    self.userView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    [messageBoardUsersBGView setHidden:YES];
    [endMessageBoardButton setHidden:YES];
    [userView setHidden:YES];
  

    [self watchForNotifications];
    // set drawer button
    UIImage *menuImage = [[UIImage imageNamed:@"menu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    _revealButtonItem = [[UIBarButtonItem alloc] initWithImage:menuImage style:UIBarButtonItemStylePlain target:self action:@selector(revealToggle:)];
    UIImage *blackArrowImage = [[UIImage imageNamed:@"arrow black"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [ cancelRideButton addTarget:self action:@selector(cancelRide:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelDropoff:)];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    mapView.delegate = self;
    [mapView setRotateEnabled:NO];
    
    startRideButton.hidden = YES;
    
    SWRevealViewController *revealViewController = self.revealViewController;
    self.navigationItem.leftBarButtonItem = _revealButtonItem;
    
    //hidden at the begining
    self.navigationItem.rightBarButtonItem = nil;
    [self configureNavigationBar];
    
    driverLocationTimer=  [NSTimer scheduledTimerWithTimeInterval:4.0
                                                           target:self
                                                         selector:@selector(updateDriverLocation:)
                                                         userInfo:nil
                                                          repeats:YES];
    //_mapCenterTimer = [NSTimer scheduledTimerWithTimeInterval: 3.0 target: self
    //                             selector: @selector(updateLocationBarOnUserLocation) userInfo: nil repeats: YES];
    
    self.locationLabel.text = @"Updating Location..";
    currentLocationLabel.text = @"Updating Location..";
    
    _chatHeads = [[NSMutableArray alloc]init];
    _rideRequests =[[NSMutableArray alloc] init];
    
    if ( revealViewController ){
        [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
        [self.navigationItem.leftBarButtonItem setTarget:self.revealViewController];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    [self setupChatHeads];
    
}

-(void )load{
    
    if(![[PFUser currentUser][@"EnabledAsDriver"] boolValue]  || [[PFUser currentUser][@"UserMode"] boolValue]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didBecomeDisabledAsDriver" object:nil];
        return;
        
    }
    
    //load driver status and configure view
    [self loadDriverStatus];

}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
}

-(void)loadDriverStatus{
    
    NSLog(@"Loading driver status");
    if(_driverStatus == nil){
    
        _driverStatus = [PFUser currentUser][@"driverStatus"];
    }
    
    [_driverStatus fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        [HUD hideUIBlockingIndicator];
        
        if(!error){
            _driverStatus = object;
            
            if([_driverStatus[@"available"] boolValue] ){
                
                PFGeoPoint *destinationGeoPoint = _driverStatus[@"destination"];
                NSString *destinationAddress = _driverStatus[@"destinationAddress"];
                
                CLLocationCoordinate2D oldDestinationCoord = CLLocationCoordinate2DMake(destinationGeoPoint.latitude, destinationGeoPoint.longitude);
                destinationCoord = oldDestinationCoord;
                //set marker on map and draw route
                [self setDestinationOnMapWithCoordiante:oldDestinationCoord andAddress:destinationAddress];
                
                self.rideConfigured= @YES;
                if([_driverStatus[@"inride"] boolValue]){
                    //get the ride requests

                    [self getActiveRideRequests];
                
                }else{
                    //the driver is available but not in ride, check missing driverrequest and show them
                    
                    [self checkForMissingDriverRequests];
                
                }
                
            }
            
            NSLog(@"Loaded driver status");
        }else{
        
            NSLog(@"Driver status not loadded");
            //cant continue
        }
    }];
}

//get the rideRequest that are active and have this driver

-(void)getActiveRideRequests{
    
    [HUD showUIBlockingIndicatorWithText:@"Getting passengers..."];
    PFQuery *query = [PFQuery queryWithClassName:@"RideRequest"];

    [query whereKey:@"driver" equalTo:[PFUser currentUser]];
    [query whereKey:@"accepted" equalTo:@YES];
    [query whereKey:@"canceled" notEqualTo:@YES];
    [query whereKey:@"canceledByDriver" notEqualTo:@YES];
    [query includeKey:@"requestedBy"];
    [query includeKey:@"requestedBy.userRating"];
    
    [HUD showUIBlockingIndicatorWithText:@"Loading active rides"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        [HUD hideUIBlockingIndicator];
        if(error == nil){
        
            for(PFObject *rideRequest in objects){
                [self startRideWithRideRequest:rideRequest];
            }
        }
            
    }];
}

-(void)cancelRide:(id)sender{
    
    
    PFQuery *userQuery =[PFInstallation query];
    [ userQuery whereKey:@"user" equalTo: user];
    
    PFPush *push = [[PFPush alloc] init];
    
    _driverStatus[@"inride"] = @NO;
    NSLog(@"===== driverStatus saveInBackground in cancelRide (inride)");
    [_driverStatus saveInBackground];
    [push setQuery:userQuery ];
    
    NSDictionary *data = @{
                           @"alert" : @"Your ride was canceled by the driver.",
                           @"rid" : rideID,
                           @"key" : @"RIDE_CANCELLED_BY_DRIVER",
                           @"badge": @"Increment"
                           };
    
    [push setData:data];
    
    NSLog(@"===== sendPushInBackgroundWithBlock in cancelRide");
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){
            NSLog(@"Push for canceling request succeeded");
            activeRide[@"canceledByDriver"] = @YES;
            NSLog(@"===== activeRide saveInBackgroundWithBlock in cancelRide (canceledByDriver)");
            [activeRide saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                NSLog(@"Ride canceled by driver");
            }];
            
        }
    }];
    
    [self.mapView removeOverlay:routeDetails.polyline];
    
    [mapView removeAnnotation:dropOffAnnotation];
    
    [startRideButton removeTarget:self action:@selector(endRide:) forControlEvents:UIControlEventTouchUpInside];
    [startRideButton setHidden:YES];
    
    bottomLayoutConstrint.constant = 10;
    [userView setHidden:YES];
    for(CHDraggableView *view in _chatHeads){
        [view removeFromSuperview];
    }
    
    [_chatHeads removeAllObjects];
    for(PFObject *ride in _rideRequests){
        ride[@"canceledByDriver"] = @YES;
        NSLog(@"===== ride saveEventually in cancelRide (canceledByDriver)");
        [ride saveEventually];
    }
    [_rideRequests removeAllObjects];
    
    isDriverAccepted = NO;
    
}

-(void)cancelDropoff:(id)sender{
    
    
    self.rideConfigured = @NO;
    self.destinationSetted = @NO;
    
    
    if([_driverStatus[@"inride"] boolValue] ){
        [self cancelRide:nil];
    }
    
    //remove anotation
    self.locationSearchButton.enabled = YES;
    
    //remove route
    [self.mapView removeOverlay:routeDetails.polyline];
    
    isDriverAccepted = NO;
    
    startRideButton.hidden = YES;
    
    //remove all annotations
    [self.mapView removeAnnotations: self.mapView.annotations];
    
    [_dropOffButton setHidden:NO];
    [_dropOffPinImage setHidden:NO];
    
    self.navigationItem.rightBarButtonItem = nil;
    
    _driverStatus[@"available"] = @NO;
    NSLog(@"===== driverStatus saveInBackground in cancelDropoff (available)");
    [_driverStatus saveInBackground];
    self.startRideButton.hidden = YES;
    [self.startRideButton removeTarget:self action:@selector(startRideButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.startRideButton removeTarget:self action:@selector(navigateToDestination:) forControlEvents:UIControlEventTouchUpInside];
    [self.startRideButton removeTarget:self action:@selector(endRide:) forControlEvents:UIControlEventTouchUpInside];
    
    //[self cancelRide:nil];
}

-(void)checkForMissingDriverRequests{
    
    PFQuery * query = [PFQuery queryWithClassName:@"RideRequest"];
    [query whereKey:@"driver" equalTo:[PFUser currentUser]];
    [query whereKey:@"accepted" notEqualTo:@YES];
    [query whereKey:@"finished" notEqualTo:@YES];
    [query whereKey:@"canceled" notEqualTo:@YES];
    [query whereKey:@"canceledByDriver" notEqualTo:@YES];
    [query includeKey:@"requestedBy"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error  && [objects count] > 0){
            
            [self   processRideRequest: [objects firstObject] ];
            
            //only interested on last one
            return;
        }
    }];
}

-(void)watchForNotifications{
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForStoppingAllMappingServices:) name:@"didRequestForStoppingAllMappingServices" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForStoppingAllMappingServices:) name:@"didRequestForStoppingAllMappingServices" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(driverDecisionTaken:) name:@"driverDecisionTaken" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForRideRequest:) name:@"didRequestForRideRequest" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForRideRequest:) name:@"didRequestForStartTheMessageBoardRide" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForRideAcceptedForDriver:) name:@"didRequestForRideAcceptedForDriver" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForRideAcceptedByAnotherDriver:) name:@"didRequestForRideAcceptedByAnotherDriver" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForRideDecisionCloseView:) name:@"didRequestForRideDecisionCloseView" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForRideRequestCancel:) name:@"didRequestForRideRequestCancel" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForRideEnd:) name:@"didRequestForRideEnd" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForOpenRatinView:) name:@"didRequestForOpenRatinView" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForMessageBoardStartRide:) name:@"didRequestForMessageBoardStartRide" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForMessageBoardStartAccepted:) name:@"didRequestForMessageBoardStartAccepted" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForUserSelected:) name:@"didRequestForUserSelected" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForMessageBoardRideEnded:) name:@"didRequestForMessageBoardRideEnded" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForSearchResult:) name:@"didRequestForSearchResult" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConfigureRide) name:@"didConfigureRide" object:nil];
    
}


//called when the driver saves the data properly on the settings view
-(void)didConfigureRide{
    
    self.rideConfigured = @YES;
    //make the driver active and advertise ride
    _driverStatus
    [@"active"] = @YES; // now the driver is active and can be visible on map
    _driverStatus[@"inride"] = @NO;
    
    
    _driverStatus[@"available"] =  @YES; // available means it have empty seats
    
    
    [HUD showUIBlockingIndicatorWithText:@"Loading..."];
    [_driverStatus saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
        [HUD hideUIBlockingIndicator];
        if(succeeded){
            NSLog(@"Saved driver destination in parse");
            
        }else{
            //TODO: can't become available
        
        }
    }];
    
}


#pragma mark - Ride Request

/*
 * Called when a new ride request arrive, to handle it and take the pertinent
 * actions
 */

-(void)processRideRequest:(PFObject *) rideRequest{
    rideID = rideRequest.objectId;
    
    _lastRideRequest = rideRequest;
    
    NSLog(@"request id%@", rideID);
    
    //get the request data from server
    //and prompt for accepting or rejecting it
    
    NSString* originLatitude = rideRequest[@"pickupLat"];
    NSString* originLongitude = rideRequest[@"pickupLong"];
    
    userLat = [originLatitude doubleValue];
    userLong = [originLongitude doubleValue];
    
    NSString* destinationLatitude = rideRequest[@"dropoffLat"];
    NSString* destinationLongitude = rideRequest[@"dropoffLong"];
    
    destLat = [destinationLatitude doubleValue];
    destLong = [destinationLongitude doubleValue];
    
    int seats =[rideRequest[@"seats"] intValue];
    
    user = rideRequest[@"requestedBy"];
    NSAssert(user!= nil, @"User that requested the ride can't be nil");

    
    //NSString* originalAddress = responseObject[@"originAddress"];
    //NSString* dropAddress =responseObject[@"dropAddress"];
    
    NSString* riderName = user[@"FullName"];
    
    userPhone = user[@"Phone"];
    
    PFObject *ratingData = user[@"userRating"];
    
    NSString* userPic =user[@"ProfilePicUrl"];
    
    {
        requestRidePopupViewController = [[RequestRidePopupViewController alloc] initWithNibName:@"RequestRidePopupViewController" bundle:nil];
        
        requestRidePopupViewController.pickupAddress = rideRequest[@"pickupAddress"];
        // originalAddress;
        
        requestRidePopupViewController.rideRequest = rideRequest;
        requestRidePopupViewController.dropoffAddress = rideRequest[@"dropoffAddress"]; //dropAddress;
        requestRidePopupViewController.mobile = userPhone;
        requestRidePopupViewController.rating = ratingData[@"rating"];
        requestRidePopupViewController.requestId = rideRequest.objectId;
        
        requestRidePopupViewController.riderName = riderName;
        requestRidePopupViewController.userId = user.objectId;
        
        requestRidePopupViewController.seats = seats;
        requestRidePopupViewController.pricePerSeat = [_driverStatus[@"pricePerSeat"] doubleValue];
        requestRidePopupViewController.requestRideId = rideID;
        requestRidePopupViewController.isActive = isDriverAccepted;
        
        requestRidePopupViewController.userPic = userPic;
    
    }
    
    self.userName.text = riderName;
    self.userMobile.text = userPhone;
    self.ratingView.value = [ratingData[@"rating"] doubleValue];
    
    [requestRidePopupViewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:requestRidePopupViewController animated:YES completion:nil];
}


-(void)didRequestForRideRequest:(NSNotification *)notification
{
    //isDriverAccepted
    NSString* requestId  = [notification object];
    
    if(_driverStatus == nil){
        
        PFQuery * query = [PFQuery queryWithClassName:@"DriverStatus"];
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if(error){
                
                NSLog(@"Somethig wrong happend, alert user");
                
            }else{
                _driverStatus = object;
                [self didRequestForRideRequest:notification];
            
            }
            
        }];
        
        return;
        
    }
    
    //the driver should be active and enabled, not sure
    
    if([_driverStatus[@"available"] boolValue]){
        
        PFQuery * query =  [PFQuery queryWithClassName:@"RideRequest"];
        //[query whereKey:@"canceled" notEqualTo:@YES];
        //[query whereKey:@"canceledByDriver" notEqualTo:@YES];
        [query includeKey:@"requestedBy"];
        [query includeKey:@"requestedBy.userRating"];
        
        //get the ride request object from Parse
        [query getObjectInBackgroundWithId:requestId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
            
            if(error ==  NULL ){
                NSLog(@"Processing ride request with id");
                NSLog(@"%@", object.objectId);
                assert([object.objectId isEqualToString:requestId]);
                //_lastRideRequest = object;
                [self processRideRequest:object];
            }else{
                
                NSLog(@"Can get ride request properly");
                [[  [UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Accept" otherButtonTitles:nil] show];
            }
        }];
    
    }else{
        //this would happend because driver canceled ride or some cached results
        //for now just silently ignore it but later on
        // should send push with cancel from driver
    }
}


#pragma mark - Activate Driver Mode

-(void)didRequestForMessageBoardStartRide:(NSNotification *)notification{
    
    NSLog(@"Notification: %@", notification);
    
    messageBoardDict = [notification object];
    
    double driverMessageLat = mapView.userLocation.location.coordinate.latitude;
    double driverMessageLong = mapView.userLocation.location.coordinate.longitude;
    
    
    NSString* latNow = [NSString stringWithFormat:@"%f",driverMessageLat];
    NSString* longNow = [NSString stringWithFormat:@"%f",driverMessageLong];
    
    messageBoardStartRideViewController = [[MessageBoardStartRideViewController alloc] initWithNibName:@"MessageBoardStartRideViewController" bundle:nil];
    
    [messageBoardStartRideViewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    messageBoardStartRideViewController.messageBoardDict = messageBoardDict;
    messageBoardStartRideViewController.latNow = latNow;
    messageBoardStartRideViewController.longNow = longNow;
    
    [self presentViewController:messageBoardStartRideViewController animated:YES completion:nil];
}


-(void)didRequestForMessageBoardStartAccepted:(NSNotification *)notification
{
    isDriverAccepted = YES;
    // [self checkForUserStatus];
    
}

-(void)activateMessageDriveMode:(NSDictionary*)messageDict{
    
    NSArray* usersArray = messageDict[@"driverMessageRequests"];
    if ([usersArray count]>0) {
        selectedUserDict = usersArray[0];
        self.userName.text = selectedUserDict[@"userName"];
        self.userMobile.text = [NSString stringWithFormat:@"Cell: %@",selectedUserDict[@"userMobile"]];
        
        userPhone =selectedUserDict[@"userMobile"];
        
        double driverRatingDouble = [[selectedUserDict objectForKey:@"userRating"] doubleValue];
        NSString* driverRating =[NSString stringWithFormat:@"Rating: %.2f",driverRatingDouble];
        
        self.userRating.text =driverRating;
        NSString* userProfilePics =selectedUserDict[@"userProfilePic"];
        
        if (![userProfilePics isKindOfClass:[NSNull class]]) {
            
            [self.userProfilePic sd_setImageWithURL:[NSURL URLWithString:userProfilePics] placeholderImage:[UIImage imageNamed:@"blank profile"]];
        }
        
        [self.userProfilePic setContentMode:UIViewContentModeScaleAspectFill];
        
        self.userProfilePic.layer.cornerRadius = self.userProfilePic.frame.size.height /2;
        self.userProfilePic.layer.masksToBounds = YES;
        self.userProfilePic.layer.borderWidth = 0;
        
    }
    
    [endMessageBoardButton setHidden:NO];
    [endMessageBoardButton addTarget:self action:@selector(endMessageBoard:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [startRideButton setTitle:@"NAVIGATE" forState:UIControlStateNormal];
    [startRideButton setHidden:NO];
    [startRideButton addTarget:self action:@selector(addFirstNavPath:) forControlEvents:UIControlEventTouchUpInside];
    
    bottomLayoutConstrint.constant = 80;
    
    [userView setHidden:NO];
    
    [messageBoardUsersBGView setHidden:NO];
    [self addMessageBoardUsers];
    
    [cancelRideButton setTitle:@"NAVIGATE" forState:UIControlStateNormal];
    [cancelRideButton addTarget:self action:@selector(navigateToMessageBoard:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)addMessageBoardUsers{
    
    NSArray* usersArray = messageBoardDict[@"driverMessageRequests"];
    
    NSString* userLats;
    NSString* userLongs;
    NSString* userID;
    UserAnnotation *userAnnotations;
    CLLocationCoordinate2D userCoordinates;
    CLLocationDegrees latDeg;
    CLLocationDegrees longDeg;
    double latDouble;
    double longDouble;
    NSString *name = @"Alfred User";
    
    
    for (NSDictionary* userDict in usersArray) {
        userLats = userDict[@"originLatitude"];
        userLongs = userDict[@"originLongitude"];
        
        
        
        latDouble = [userLats doubleValue];
        longDouble = [userLongs doubleValue];
        
        latDeg = latDouble;
        longDeg =longDouble;
        
        // NSLog(@"%f",latDeg);
        // NSLog(@"%f",longDeg);
        
        
        userID = [userDict objectForKey:@"userId"];
        userCoordinates = CLLocationCoordinate2DMake(latDeg, longDeg);
        
        userAnnotations = [[UserAnnotation alloc] initiWithTitle:name Location:userCoordinates];
        
        [mapView addAnnotation:userAnnotations];
        
        
        
    }
    
    
}




/*
 * Called when the driver accepts or rejects the request
 *
 */
-(void)didRequestForRideDecisionCloseView:(NSNotification *)notification
{
    NSArray *boolDecision = [notification object];
    isDriverAccepted = [[boolDecision objectAtIndex:0] boolValue];
    
    if (isDriverAccepted) {
        
        
        // [startRideButton setTitle:@"NAVIGATE" forState:UIControlStateNormal];
        // [startRideButton setHidden:NO];
        // [startRideButton addTarget:self action:@selector(addFirstNavPath:) forControlEvents:UIControlEventTouchUpInside];
        
        // bottomLayoutConstrint.constant = 80;
        // [userView setHidden:NO];
        
        
        
        //[self requestRouteToUser];
        
        
    }
    
    
}


#pragma mark - Driver Mode Helper Methods

-(void)rideRequestDecisonMade:(NSString*)message{
    
    requestRideDecisionPopupViewController = [[RideRequestDecisionViewController alloc] initWithNibName:@"RideRequestDecisionViewController" bundle:nil];
    
    requestRideDecisionPopupViewController.decision = message;
    requestRideDecisionPopupViewController.isAccepted = YES;
    [requestRideDecisionPopupViewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:requestRideDecisionPopupViewController animated:YES completion:nil];
    
    
    
}



-(void)addFirstNavPath:(id)sender{
    
    [self.mapView removeOverlay:routeDetails.polyline];
    [mapView removeAnnotation:dropOffAnnotation];
    
    NSString* originLatitude =selectedUserDict[@"originLatitude"];
    NSString* originLongitude =selectedUserDict[@"originLongitude"];
    
    userLat = [originLatitude doubleValue];
    userLong = [originLongitude doubleValue];
    
    [self requestRouteToUser];
    [startRideButton removeTarget:self action:@selector(startRide:) forControlEvents:UIControlEventTouchUpInside];
    [startRideButton removeTarget:self action:@selector(addFirstNavPath:) forControlEvents:UIControlEventTouchUpInside];
    [startRideButton addTarget:self action:@selector(navigateToMessageBoardUser:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)navigateToMessageBoardUser:(id)sender{
    
    
    
    BOOL googleInstalled = [CMMapLauncher isMapAppInstalled:CMMapAppGoogleMaps];
    if (googleInstalled) {
        [CMMapLauncher launchMapApp:CMMapAppGoogleMaps
                    forDirectionsTo:[CMMapPoint mapPointWithName:dropoffAddress
                                                      coordinate:dropOffCoord]];
    }
    
    
}




- (IBAction)messageBoardUsers:(id)sender {
    
    NSArray* usersArray = messageBoardDict[@"driverMessageRequests"];
    
    
    NSString* requestRideId =messageBoardDict[@"requestRideId"];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:requestRideId forKey:@"requestRideId"];
    
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    double driverMessageLat = mapView.userLocation.location.coordinate.latitude;
    double driverMessageLong = mapView.userLocation.location.coordinate.longitude;
    
    
    NSString* latNow = [NSString stringWithFormat:@"%f",driverMessageLat];
    NSString* longNow = [NSString stringWithFormat:@"%f",driverMessageLong];
    
    
    
    messageBoardUsersViewController = [[MessageBoardUsersViewController alloc] initWithNibName:@"MessageBoardUsersViewController" bundle:nil];
    
    [messageBoardUsersViewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    
    messageBoardUsersViewController.usersArray = usersArray;
    messageBoardUsersViewController.latNow = latNow;
    messageBoardUsersViewController.longNow = longNow;
    messageBoardUsersViewController.requestRideId = requestRideId;
    
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:messageBoardUsersViewController animated:YES completion:nil];
    
}

-(void)navigateToMessageBoard:(id)sender{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Navigate to User", @"Navigate to Destination", nil];
    
    actionSheet.tag = 100;
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 100) {
        if (buttonIndex == 0) {
            [self.mapView removeOverlay:routeDetails.polyline];
            [mapView removeAnnotation:dropOffAnnotation];
            
            NSString* originLatitude =selectedUserDict[@"originLatitude"];
            NSString* originLongitude =selectedUserDict[@"originLongitude"];
            
            userLat = [originLatitude doubleValue];
            userLong = [originLongitude doubleValue];
            [startRideButton removeTarget:self action:@selector(addFirstNavPath:) forControlEvents:UIControlEventTouchUpInside];
            [startRideButton addTarget:self action:@selector(navigateToMessageBoardUser:) forControlEvents:UIControlEventTouchUpInside];
            
            [self requestRouteToUser];
            
        }
        else if (buttonIndex ==1){
            [self.mapView removeOverlay:routeDetails.polyline];
            [mapView removeAnnotation:dropOffAnnotation];
            
            NSString* originLatitude =selectedUserDict[@"destinationLatitude"];
            NSString* originLongitude =selectedUserDict[@"destinationLongitude"];
            
            userLat = [originLatitude doubleValue];
            userLong = [originLongitude doubleValue];
            [startRideButton removeTarget:self action:@selector(addFirstNavPath:) forControlEvents:UIControlEventTouchUpInside];
            [startRideButton addTarget:self action:@selector(navigateToMessageBoardUser:) forControlEvents:UIControlEventTouchUpInside];
            
            [self requestRouteToUser];
            
            
        }
        
    }
    
    
    
}


-(void)didRequestForUserSelected:(NSNotification *)notification
{
    selectedUserDict = [notification object];
    
    NSLog(@"Selected Users: %@",selectedUserDict);
    
    self.userName.text = selectedUserDict[@"userName"];
    self.userMobile.text = [NSString stringWithFormat:@"Cell: %@",selectedUserDict[@"userMobile"]];
    userPhone =selectedUserDict[@"userMobile"];
    
    double driverRatingDouble = [[selectedUserDict objectForKey:@"userRating"] doubleValue];
    NSString* driverRating =[NSString stringWithFormat:@"Rating: %.2f", driverRatingDouble];
    
    self.userRating.text  =driverRating;
    
    NSString* userProfilePics =selectedUserDict[@"userProfilePic"];
    
    
    
    if (![userProfilePics isKindOfClass:[NSNull class]]) {
        
        
        [self.userProfilePic sd_setImageWithURL:[NSURL URLWithString:userProfilePics] placeholderImage:[UIImage imageNamed:@"blank profile"]];
    }
    
    [self.userProfilePic setContentMode:UIViewContentModeScaleAspectFill];
    
    self.userProfilePic.layer.cornerRadius = self.userProfilePic.frame.size.height /2;
    self.userProfilePic.layer.masksToBounds = YES;
    self.userProfilePic.layer.borderWidth = 0;
    
    
    
    
    [self.mapView removeOverlay:routeDetails.polyline];
    [mapView removeAnnotation:dropOffAnnotation];
    
    NSString* destinationLatitude =selectedUserDict[@"destinationLatitude"];
    NSString* destinationLongitude =selectedUserDict[@"destinationLongitude"];
    
    userLat = [destinationLatitude doubleValue];
    userLong = [destinationLongitude doubleValue];
    
    double originLatitude =[selectedUserDict[@"originLatitude"] doubleValue];
    double originLongitude =[selectedUserDict[@"originLongitude"] doubleValue];
    
    [self routedAnnotationsForUserSelected:originLatitude long:originLongitude];
}


#pragma mark - Remove Driver Mode


-(void)removeMessageBoardUsers{
    
    for (id annotation in [mapView annotations])
    {
        [mapView removeAnnotation:annotation];
        
    }
}

-(void)endMessageBoard:(id)sender{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Confirm"
                                                                             message:@"Confirm you want to end the Message Board Ride. Please drop all users before ending ride."
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"End Ride", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [self confirmedEndRideForMessageBoard];
                                   
                                   
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(void)startRideWithRideRequest:(PFObject*)rideRequest{

    assert(rideRequest != nil);
    
    for(PFObject *r in _rideRequests){
        if ([r.objectId isEqualToString:rideRequest.objectId]){
            return;// the ride is already there
        }
    }
    [_rideRequests addObject:rideRequest];
    
    
    isDriverAccepted = YES;
    //once the driver accepts the ride request for the user it status is in ride
    
    _driverStatus[@"inride"] = @YES;
    
    
    //the number of seats is reduced now
    _driverStatus[@"numberOfSeats"] = [NSNumber numberWithInt:([_lastRideRequest[@"seats"] intValue] )];
    
    NSLog(@"===== driverStatus saveInBackground in startRideWithRideRequest (inride,numberOfSeats)");
    [_driverStatus saveInBackground];
    
    
    [_dropOffButton setHidden:YES];
    [_dropOffPinImage setHidden:YES];
    
    
    assert(_rideRequests != nil);
    
    [self addChatHead: [_rideRequests indexOfObject:rideRequest]];
    
    _lastRideRequest= nil;
    //

}


//called after popup option was selected

-(void)driverDecisionTaken:(NSNotification *)notification
{
    bool desicion = [[notification object] boolValue];
    
    if(desicion == YES){
        
        assert(_lastRideRequest != nil);
      
        [self startRideWithRideRequest:_lastRideRequest];
        
        
    }else{
        rideID = nil;
        
        _driverStatus[@"inride"] = @NO;
        NSLog(@"===== driverStatus saveInBackground in  driverDecisionTaken (inride)");
        [_driverStatus saveInBackground];
        
    }
    
}


-(void)didRequestForMessageBoardRideEnded:(NSNotification *)notification
{
    [self confirmedEndRideForMessageBoard];
    
}

-(void)confirmedEndRideForMessageBoard{
    
    
    isDriverAccepted = NO;
    
    [self.mapView removeOverlay:routeDetails.polyline];
    [mapView removeAnnotation:dropOffAnnotation];
    [self removeMessageBoardUsers];
    
    [endMessageBoardButton setHidden:YES];
    [endMessageBoardButton removeTarget:self action:@selector(endMessageBoard:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [startRideButton setTitle:@"CANCEL RIDE" forState:UIControlStateNormal];
    [startRideButton setHidden:YES];
    [startRideButton removeTarget:self action:@selector(addFirstNavPath:) forControlEvents:UIControlEventTouchUpInside];
    
    bottomLayoutConstrint.constant = 10;
    
    
    [userView setHidden:YES];
    
    [messageBoardUsersBGView setHidden:YES];
    
    [cancelRideButton setTitle:@"NAVIGATE" forState:UIControlStateNormal];
    [cancelRideButton removeTarget:self action:@selector(navigateToMessageBoard:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
}




#pragma mark - Routing

-(void)traceRouteToUser{
    
    
    CLGeocoder *locator = [[CLGeocoder alloc]init];
    
    double myLatitude = mapView.userLocation.location.coordinate.latitude;
    double myLongitude = mapView.userLocation.location.coordinate.longitude;
    
    pickUpCoord.latitude = myLatitude;
    pickUpCoord.longitude = myLongitude;
    
    
    dropOffCoord.latitude = userLat;
    dropOffCoord.longitude = userLong;
    
    
    
    CLLocation *location = [[CLLocation alloc]initWithLatitude:myLatitude longitude:myLongitude];
    
    [locator reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        pickupPlacemark = [placemarks objectAtIndex:0];
        
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
            [mapView addAnnotation:dropOffAnnotation];
            [self addRouteToUser];
            
            
            
        }];
    }];
    
    
    
}

-(void)requestRouteToUser{
    
    
    
    
    startRideButton.hidden = NO;
    
    [startRideButton setTitle:@"NAVIGATE TO USER" forState:UIControlStateNormal];
    
    [startRideButton removeTarget:self action:@selector(startRide:) forControlEvents:UIControlEventTouchUpInside];
    
    [startRideButton addTarget:self action:@selector(navigateToUser:) forControlEvents:UIControlEventTouchUpInside];
    
    self.userView.hidden = NO;
    self.bottomLayoutConstrint.constant = 80;
    
    
    
}

-(void)addRouteToUser{
    
    
    [HUD showUIBlockingIndicatorWithText:@"Routing.."];
    
    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
    MKPlacemark *dropPlacemark = [[MKPlacemark alloc] initWithPlacemark:dropoffPlacemark];
    MKPlacemark *pickPlacemark = [[MKPlacemark alloc] initWithPlacemark:pickupPlacemark];
    
    [directionsRequest setSource:[[MKMapItem alloc] initWithPlacemark:dropPlacemark]];
    [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:pickPlacemark]];
    directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error %@", error.description);
        }
        else{
            routeDetails = response.routes.lastObject;
            
            
            [self.mapView addOverlay:routeDetails.polyline];
            
            
            
            
            
        }
        [HUD hideUIBlockingIndicator];
    }];
    
}



-(void)showRouteOnMap{
    
    
    CLLocationCoordinate2D southWest = driverCoord  ;
    CLLocationCoordinate2D northEast = destinationCoord;
    
    southWest.latitude = MIN(southWest.latitude, driverCoord.latitude);
    southWest.longitude = MIN(southWest.longitude, driverCoord.longitude);
    
    northEast.latitude = MAX(northEast.latitude, destinationCoord.latitude);
    northEast.longitude = MAX(northEast.longitude, destinationCoord.longitude);
    
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
#pragma mark - Routing for The User Selected
// add route for the selected user
-(void)routedAnnotationsForUserSelected:(double)userPickLat long:(double)userPickLong{
    
    CLGeocoder *locator = [[CLGeocoder alloc]init];
    
    pickUpCoord.latitude = userPickLat;
    pickUpCoord.longitude = userPickLong;
    
    
    dropOffCoord.latitude = userLat;
    dropOffCoord.longitude = userLong;
    
    CLLocation *location = [[CLLocation alloc]initWithLatitude:userPickLat longitude:userPickLong];
    
    [locator reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        pickupPlacemark = [placemarks objectAtIndex:0];
        
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
            [mapView addAnnotation:dropOffAnnotation];
            [self addRouteToUser];
            
            
        }];
    }];
}



#pragma mark - Ride End and Rating View

-(void)didRequestForRideEnd:(NSNotification *)notification
{
    
    rideEndArray = [notification object];
    
    NSString* rideCost = @"0.00";
    
    if(rideEndArray.count){
        rideCost = [rideEndArray firstObject];
    }
    
    double rideCostDouble = [rideCost doubleValue];
    
    requestRideDecisionPopupViewController = [[RideRequestDecisionViewController alloc] initWithNibName:@"RideRequestDecisionViewController" bundle:nil];
    
    NSString* decisionStr = [NSString stringWithFormat:@"Ride Cost: $%.2f", rideCostDouble];
    
    requestRideDecisionPopupViewController.decision = decisionStr;
    requestRideDecisionPopupViewController.isAccepted = NO;
    requestRideDecisionPopupViewController.openRatingView = YES;
    [requestRideDecisionPopupViewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:requestRideDecisionPopupViewController animated:YES completion:nil];
    
}

-(void)didRequestForOpenRatinView:(NSNotification *)notification
{
    [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self
                                   selector: @selector(openRatingView:) userInfo: nil repeats: NO];
}


-(void)openRatingView:(id)sender{
    
    [self performSegueWithIdentifier:@"rateUser" sender:nil];
}

#pragma mark - Get Message Board Ride data

-(void)getMessageBoardData:(NSString*)ride message:(NSString*)messages{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *token = [prefs stringForKey:@"token"];
    NSString *driverId = [prefs stringForKey:@"driverId"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"tokenId"];
    
    NSString* URL = [NSString stringWithFormat:@"http://ec2-52-74-6-189.ap-southeast-1.compute.amazonaws.com:8080/getBoardRideData?requestRideId=%@",ride];
    
    [manager GET:URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        messageBoardDict = responseObject;
        
        
        
        NSString* message =responseObject[@"message"];
        NSString* driverIDFromData =responseObject[@"driverId"];
        
        
        if ([message isEqualToString:@"Data retrieved succesfully."]) {
            isDriverAccepted = YES;
            
            int driver = [driverId intValue];
            int compareDriver = [driverIDFromData intValue];
            
            if (driver == compareDriver) {
                
                
                [self activateMessageDriveMode:responseObject];
                //[self rideRequestDecisonMade:messages];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        
    }];
}

#pragma mark - Driver Location Update

/*!
 @abstract Save the driver location on server
 */
-(void)updateDriverLocation:(id)sender{
    
    PFGeoPoint *location = [PFGeoPoint geoPointWithLatitude:latitude  longitude:driverLong];
    
    [PFCloud callFunctionInBackground:@"UpdateUserLocation"
                       withParameters:@{@"location": location}
                                block:^(NSString *success, NSError *error) {
                                    if (!error) {
                                        
                                    } else {
                                        
                                    }
                                }];

}

#pragma mark - More, Center location and Call Driver Buttons


- (IBAction)callUser:(id)sender {
    
    NSString *phoneNumber = [@"telprompt://" stringByAppendingString:userPhone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}


-(void)cancelFired:(id)sender{
    NSLog(@"Who call this?");
    
}

- (IBAction)centerOnUsersLocation:(id)sender {
    
    [self updateLocationBarOnUserLocation];
    
    [mapView setRegion:region animated:YES];
    
}

#pragma mark - Location Manager and Map Delegate

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
    
    MKCoordinateSpan span;
    /*span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    CLLocationCoordinate2D location;
    location.latitude = aUserLocation.coordinate.latitude;
    location.longitude = aUserLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [self updateLocationBarOnUserLocation];
    
    NSLog(@"%f %f",location.latitude,location.longitude);
    */
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    MKPolylineRenderer  * routeLineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:routeDetails.polyline];
    
    routeLineRenderer.strokeColor = [UIColor redColor];
    routeLineRenderer.lineWidth = 5;
    return routeLineRenderer;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    CLLocation *location =  [locations lastObject];
    
    CLLocationCoordinate2D currentCoordinates = location.coordinate;
    latitude = currentCoordinates.latitude;
    driverLong = currentCoordinates.longitude;
    
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
    
    //    NSLog(@"Updating my location as driver location");
    
    if( _driverStatus && ![_driverStatus[@"available"] boolValue]  ){
        
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
                
                currentAddress = [formatedAddressLines componentsJoinedByString:@", "];
                if(currentAddress.length !=0){
                    self.locationLabel.text = currentAddress;
                }else{
                    self.locationLabel.text = @"Updating location..";
                }
                
            }else{
                
                error.localizedDescription;
            }
            
        }];
        
    }
    
}

-(void)updateLocationBarOnCenterLocation{
    
//    NSLog(@"Updating my location as driver location");

    [_driverStatus fetchIfNeeded];//this should be done in the background
    if(_driverStatus ==  nil ||  (![_driverStatus[@"available"] boolValue]  && ![_destinationSetted boolValue]) ){
        
        NSLog(@"Updating address bar with center map location");
        CLGeocoder *locator = [[CLGeocoder alloc]init];
        
        CLLocationCoordinate2D centerCoordinate = [mapView centerCoordinate];
        
        myLatitude = centerCoordinate.latitude;
        myLongitude = centerCoordinate.longitude;
        CLLocation *location = [[CLLocation alloc]initWithLatitude:myLatitude longitude:myLongitude];
        self.dropOffButton.hidden = YES;
        self.locationLabel.text = @"Updating location..";
        [locator reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            NSLog(@"Finished updating address bar with center map location");
            
            if(!error){
                
                NSLog(@"Location updated sucessfully");
                self.dropOffButton.hidden = NO;
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                
                NSDictionary * addressDictionary = placemark.addressDictionary;
                NSMutableArray *formatedAddressLines = [addressDictionary valueForKey:@"FormattedAddressLines"];
                [formatedAddressLines removeLastObject];
                [formatedAddressLines removeLastObject];
                
                currentAddress = [formatedAddressLines componentsJoinedByString:@", "];
                if(currentAddress.length !=0){
                    self.locationLabel.text = currentAddress;
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



#pragma mark - Start of Ride (Not in use)

-(void)startRide:(id)sender{
    
    
    [self.mapView removeOverlay:routeDetails.polyline];
    [mapView removeAnnotation:dropOffAnnotation];
    
    userLat = destLat;
    userLong = destLong;
    
    [self requestRouteToUser];
    
    [startRideButton setTitle:@"NAVIGATE TO DESTINATION" forState:UIControlStateNormal];
    [startRideButton removeTarget:self action:@selector(startRide:) forControlEvents:UIControlEventTouchUpInside];
    [startRideButton addTarget:self action:@selector(navigateToDestination:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    calucaltateDistanceTimer =[NSTimer scheduledTimerWithTimeInterval:15.0
                                                               target:self
                                                             selector:@selector(calucaltateDistanceTimer:)
                                                             userInfo:nil
                                                              repeats:YES];
    

    
}




#pragma mark - Reject Ride Request (Not in use)

- (IBAction)rejectRideForUser:(id)sender {
    
    
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *token = [prefs stringForKey:@"token"];
        NSString *driverID = [prefs stringForKey:@"driverId"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        int driverIDInt = [driverID intValue];
        
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        [manager.requestSerializer setValue:token forHTTPHeaderField:@"tokenId"];
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:rideID,@"rideId",nil];
        [params setValue:[NSNumber numberWithInt:driverIDInt] forKey:@"driverId"];
        
        NSString* URL_SIGNIN = @"http://ec2-52-74-6-189.ap-southeast-1.compute.amazonaws.com:8080/driverCancelRide";
        
        [manager POST:URL_SIGNIN parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Success: %@", responseObject);
            
            NSString* message =responseObject[@"message"];
            
            if ([message isEqualToString:@"Ride cancelled."]) {
                
                isDriverAccepted = NO;
                
                [calucaltateDistanceTimer invalidate];
                calucaltateDistanceTimer = nil;
                
                [self.mapView removeOverlay:routeDetails.polyline];
                [mapView removeAnnotation:dropOffAnnotation];
                [startRideButton setHidden:YES];
                
                bottomLayoutConstrint.constant = 10;
                [userView setHidden:YES];
                
                
                
            }
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", [error localizedDescription]);
            
        }];
        
        
        
    });
    
    
}

#pragma mark - Ending of Ride (Not in use)

-(void)endRide:(id)sender{
    
    [self.mapView removeOverlay:routeDetails.polyline];
    
    [mapView removeAnnotation:dropOffAnnotation];
    
    //[startRideButton setTitle:@"START NAVIGATION" forState:UIControlStateNormal];
    [startRideButton removeTarget:self action:@selector(endRide:) forControlEvents:UIControlEventTouchUpInside];
    
    [startRideButton setHidden:YES];
    
    bottomLayoutConstrint.constant = 10;
    [userView setHidden:YES];
    
    isDriverAccepted = NO;
    self.rideConfigured = @NO;
    self.destinationSetted = @NO;
    [calucaltateDistanceTimer invalidate];
    calucaltateDistanceTimer = nil;
    
    //    activeRide[@"finished"]= @YES;
    
    for(CHDraggableView *view in _chatHeads){
        [view removeFromSuperview];
    }
    
    [_chatHeads removeAllObjects];
    
    NSMutableArray* usersArray = [[NSMutableArray alloc]init];
    
    for (PFObject *ride in _rideRequests){
    
        ride[@"finished"] = @YES;
        assert(ride[@"requestedBy"]!= nil);
        
        PFUser *rider = ride[@"requestedBy"];
        
        // [usersArray addObject:ride[@"requestedBy"]];
        [ride saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            NSLog(@"Notified rider of ride end");
            NSLog(@"RiderID: %@", rider.objectId);
        }];
    }
    
    if( [_driverStatus[@"inride"] boolValue] == YES){
        
        [self openRatingView:nil];
        
        _driverStatus[@"inride"] = @NO;
        
        [_driverStatus saveInBackground];
        
    }
    
    [activeRide saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"Ride ended");
    }];
    
    _driverStatus[@"inride"] = @NO;
    _driverStatus[@"active"] = @NO;
    
    [_driverStatus saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){
            NSLog(@"Saved driver end ride successfully on parse");
        }
    }];
    
    [self cancelDropoff:nil];
    
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

-(void)didRequestForRideAcceptedByAnotherDriver:(NSNotification *)notification
{
    
    requestRideDecisionPopupViewController = [[RideRequestDecisionViewController alloc] initWithNibName:@"RideRequestDecisionViewController" bundle:nil];
    
    requestRideDecisionPopupViewController.decision = @"Sorry but another driver has been accepted for the ride";
    requestRideDecisionPopupViewController.isAccepted = NO;
    [requestRideDecisionPopupViewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:requestRideDecisionPopupViewController animated:YES completion:nil];
    isDriverAccepted = NO;
    
}


-(void)calculateDistanceTimer:(id)sender{
    
    
    double myLatitude = mapView.userLocation.location.coordinate.latitude;
    double myLongitude = mapView.userLocation.location.coordinate.longitude;
    
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:driverStartLat longitude:driverStartLong];
    
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:myLatitude longitude:myLongitude];
    driverDistanceTravelled = [locA distanceFromLocation:locB];
    distanceCovered += driverDistanceTravelled;
    
    NSLog(@"Total distance being travelled: %f",distanceCovered);
    
    driverStartLat = myLatitude;
    driverStartLong = myLongitude;
    
}

-(void)navigateToDestination:(id)sender{
    

        
    [CMMapLauncher launchMapApp:CMMapAppAppleMaps
                    forDirectionsTo:[CMMapPoint mapPointWithName:@"Destination"
                                                      coordinate:destinationCoord]];
        
    
    NSLog(@"Driver is navigating to destination");
    
    [startRideButton setTitle:@"END RIDE" forState:UIControlStateNormal];
    [startRideButton removeTarget:self action:@selector(navigateToDestination:) forControlEvents:UIControlEventTouchUpInside];
    [startRideButton addTarget:self action:@selector(endRide:) forControlEvents:UIControlEventTouchUpInside];
    
}



-(void)navigateToUser:(id)sender{
    
    
    NSLog(@"Driver is navigating to user");
    
    
    
    BOOL googleInstalled = [CMMapLauncher isMapAppInstalled:CMMapAppGoogleMaps];
    
   
        
    [CMMapLauncher launchMapApp:CMMapAppAppleMaps forDirectionsTo:[CMMapPoint mapPointWithName:dropoffAddress address:dropoffAddress coordinate:dropOffCoord]];
        
        
    
    
    
    [startRideButton setTitle:@"NAVIGATE TO DESTINATION" forState:UIControlStateNormal];
    [startRideButton removeTarget:self action:@selector(navigateToUser:) forControlEvents:UIControlEventTouchUpInside];
    
    [startRideButton addTarget:self action:@selector(navigateToDestination:) forControlEvents:UIControlEventTouchUpInside];
    
    
    NSLog(@"User started navigation to user");
    
    
}

-(void)navigateToDestination{
    
    [startRideButton setTitle:@"NAVIGATE TO DESTINATION" forState:UIControlStateNormal];
    [startRideButton removeTarget:self action:@selector(navigateToUser:) forControlEvents:UIControlEventTouchUpInside];
    [startRideButton addTarget:self action:@selector(startRide:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)didRequestForRideRequestCancel:(NSNotification *)notification
{
    NSArray *data = [notification object];
    
    if ([data count] == 0){
        
        return ;
        
    }
    NSString *rideId = [data firstObject];
    NSAssert(rideId != nil, @"Request for canceling an nil ride id");
    
    PFObject * _canceledRideRequest = nil;
    for(PFObject *rideRequest in _rideRequests){
    
        if ([rideRequest.objectId isEqualToString:rideID]){
            _canceledRideRequest = rideRequest;
            break;
        }
    }
    if(_canceledRideRequest == nil){
        
        NSLog(@"Got cancel from inactive ride request %@",rideID);
        
        //skip silently
        
        return;
    
    }
    
    PFUser *rider = _canceledRideRequest[@"requestedBy"];
    
    if (isDriverAccepted) {
        
        requestRideDecisionPopupViewController = [[RideRequestDecisionViewController alloc] initWithNibName:@"RideRequestDecisionViewController" bundle:nil];
        
        requestRideDecisionPopupViewController.decision = [NSString stringWithFormat:@"The ride was canceled by %@",rider[@"Full Name"]];

        requestRideDecisionPopupViewController.isAccepted = NO;
        [requestRideDecisionPopupViewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:requestRideDecisionPopupViewController animated:YES completion:nil];
        
        isDriverAccepted = NO;
        
        [calucaltateDistanceTimer invalidate];
        calucaltateDistanceTimer = nil;
        
        //search for the index of the ride request
        int index = 0;
        
        for(PFObject* rideRequest in _rideRequests){
            
            if([rideRequest.objectId isEqualToString: rideId]){
                [rideRequest fetchIfNeeded];
                rideRequest[@"canceled"] = @YES;
                //TODO: get the number of seats requested and make the available again
                //this can be done in driverStatus
                
                [rideRequest saveInBackground];
                break;
            }
            index++;
            
        }
        
        //remove chat head with that index
        CHDraggableView *view =  [_chatHeads objectAtIndex:index];
        [view removeFromSuperview];
        [_chatHeads removeObjectAtIndex:index];
        //remove ride request from list
        
        [_rideRequests removeObjectAtIndex:index];

        if(_rideRequests.count == 0){
            
            _driverStatus[@"inride"] = @NO;
            
        }
        _driverStatus[@"available"] = @YES;
        
        [_driverStatus saveInBackground];
        
        //change to navigate to destination
        
        NSAssert(_chatHeads.count == _rideRequests.count,@"Ride request count must be equal to the number of chatheads");
        
    }else{
        
        NSLog(@"Ride request canceled by driver");
    }
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForStoppingAllMappingServices" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForRideRequest" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForRideAcceptedForDriver" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForRideAcceptedByAnotherDriver" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForRideDecisionCloseView" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForRideRequestCancel" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForRideEnd" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForOpenRatinView" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForMessageBoardStartRide" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForMessageBoardStartAccepted" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForUserSelected" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForMessageBoardRideEnded" object:nil];
}

-(void)didRequestForStoppingAllMappingServices:(id)sender{
    [self.locationManager stopUpdatingLocation];
    
    [driverLocationTimer invalidate];
    driverLocationTimer = nil;
    [_mapCenterTimer invalidate];
    _mapCenterTimer = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startRideButtonTouchUpInside:(id)sender {
    
    
    if(![[PFUser currentUser][@"PhoneVerified"] boolValue]){
        [[[UIAlertView alloc]initWithTitle:nil message:@"Please verify your phone number before advertising a ride" delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil] show];
        return;
        
    }
    
    NSLog(@"Start ride button clicked");
    NSLog(@"Ride details");
    
    if(![self.rideConfigured boolValue]){
        
        
        [self performSegueWithIdentifier:@"RideSettingsSegue" sender:nil];
        
        
    }
    
    //    self.navigationItem.rightBarButtonItem=nil;
    
    //    driverStatus[@"inride"] = @YES;, not in ride, it is active but has no passenger
    //    [driverStatus saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
    //        if(succeeded){
    //            NSLog(@"Saved driver in ride successfully on parse");
    //        }
    //    }];
    
    // [self traceRouteWithStartingCoordinates:pickUpCoord end:dropOffCoord];
    
    //make the driver active and advertise ride
    _driverStatus[@"active"] = @YES;
    _driverStatus[@"inride"] = @NO;
//    driverStatus[@"available"] =  @YES;
    
    [_driverStatus saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){
            NSLog(@"Saved driver destination in parse");
            
        }
    }];
    
    #warning what happens now
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString: @"RideSettingsSegue"]){
        
        RideSettingsViewController *vc =(RideSettingsViewController*)[segue destinationViewController];
        vc.driverStatus = _driverStatus;
    }
    if([segue.identifier isEqualToString: @"rateUser"]){
        
       RideRatingViewController *vc =(RideRatingViewController*)[segue destinationViewController];
        
        //rate only last user, this is wrong
        vc.rideRequest = [_rideRequests firstObject];
    }
    
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
-(void)didRequestForRouteToPickup:(PFObject *)rideRequest{
    
    double pickupLat  = [rideRequest[@"pickupLat"] doubleValue];
    double pickupLong  = [rideRequest[@"pickupLong"] doubleValue];
    CLLocationCoordinate2D pickupCoordinate = CLLocationCoordinate2DMake(pickupLat, pickupLong);
    NSString *pickupAddress = rideRequest[@"pickupAddress"];
    
    
    [CMMapLauncher launchMapApp:CMMapAppAppleMaps
                forDirectionsTo:[CMMapPoint mapPointWithName:pickupAddress
                                                  coordinate:pickupCoordinate]];
    
    
    
    
    
}
-(void)didRequestForRouteToDropoff:(PFObject *)rideRequest{
    
    double dropoffLat  = [rideRequest[@"dropoffLat"] doubleValue];
    double dropoffLong  = [rideRequest[@"dropoffLong"] doubleValue];
    CLLocationCoordinate2D dropoffCoordinate = CLLocationCoordinate2DMake(dropoffLat, dropoffLong);
    NSString *dropoffAddress = rideRequest[@"dropoffAddress"];
    
    
    [CMMapLauncher launchMapApp:CMMapAppAppleMaps
                forDirectionsTo:[CMMapPoint mapPointWithName:dropoffAddress
                                                  coordinate:dropoffCoordinate]];


}


-(void)disableNavigation{
    
    self.navigationItem.leftBarButtonItem = nil;
    
    
}
-(void)enableNavigation{
    
    self.navigationItem.leftBarButtonItem = _revealButtonItem;
    
}
#pragma mark - Setters
-(void)setRideConfigured:(NSNumber *)rideConfigured{

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


@end
