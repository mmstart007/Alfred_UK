//
//  DriverCalloutPopupViewController.m
//  Alfred
//
//  Created by Arjun Busani on 09/04/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "DriverCalloutPopupViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "HCSStarRatingView/HCSStarRatingView.h"
#import "PickupAnnotation.h"
#import "DropoffAnnotation.h"

@interface DriverCalloutPopupViewController (){

    CLLocationCoordinate2D  pickupCoord;
    CLLocationCoordinate2D dropoffCoord;
    MKRoute *routeDetails;
    
}

@end

@implementation DriverCalloutPopupViewController


@synthesize driverRating,driverProfilePic,driverMobile,driverName,messageBoardId;
@synthesize profileNameLabel;
@synthesize seatsSelectView;
@synthesize availbleSeats;
@synthesize pricePerSeatLabel;
@synthesize cellPhoneLabel;
@synthesize profilePic;
@synthesize ratingView;
@synthesize driverLocation;
@synthesize mapView;
@synthesize ladiesOnlyLabel;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    PFObject *user = driverLocation[@"driver"];
    PFObject *driRating = user[@"driverRating"];
    self.seatsSelectView.maximumValue = [driverLocation[@"availableSeats"] doubleValue];;
    self.seatsSelectView.minimumValue = 1;
    self.ladiesOnlyLabel.hidden = ![driverLocation[@"ladiesOnly"] boolValue];
    [self.destinationAddressLabel setText: driverLocation[@"destinationAddress"]];
    [self.profileNameLabel setText: user[@"FullName"]];
    self.cellPhoneLabel.text = [NSString stringWithFormat:@"Cell: %@",user[@"Phone"]];
    self.pricePerSeatLabel.text = [NSString stringWithFormat:@"%3.1lf" , [driverLocation[@"pricePerSeat"]doubleValue] / 100];

    self.ratingView.userInteractionEnabled = NO;
    [self.ratingView setValue: [driRating[@"rating"] doubleValue]];
    
    if (![profilePic isKindOfClass:[NSNull class]]) {
        [profilePic sd_setImageWithURL:[NSURL URLWithString:user[@"ProfilePicUrl"]] placeholderImage:[UIImage imageNamed:@"blank profile"]];
    }

    profilePic.layer.cornerRadius = profilePic.frame.size.height / 2;
    profilePic.layer.masksToBounds = YES;
    profilePic.layer.borderWidth = 0;
    
    pickupCoord.latitude = [user[@"location"] latitude];
    pickupCoord.longitude = [user[@"location"] longitude];
    dropoffCoord.latitude = [driverLocation[@"destination"] latitude];
    dropoffCoord.longitude = [driverLocation[@"destination"] longitude];
    self.mapView.delegate = self;
    [self.mapView setRotateEnabled:NO];

    [self.mapView setShowsUserLocation:YES];
    CLLocationCoordinate2D coord = mapView.userLocation.location.coordinate;
    MKCoordinateRegion initialRegion = MKCoordinateRegionMakeWithDistance(coord, 1000.0, 1000.0);
    [mapView setRegion:initialRegion animated:YES];
    
    [self loadMapWithPickup:pickupCoord dropOff:dropoffCoord];
}

-(void)loadMapWithPickup:( CLLocationCoordinate2D)pickupCoordinate dropOff:(CLLocationCoordinate2D)dropoffCoordinate{
    
    PickupAnnotation *pickupAnnotation  = [[PickupAnnotation alloc] initiWithTitle:@"" Location:pickupCoordinate];
    
    DropoffAnnotation *dropoffAnnotation = [[DropoffAnnotation alloc] initiWithTitle:@"" Location:dropoffCoordinate];
    
    [self.mapView addAnnotation:pickupAnnotation];
    [self.mapView addAnnotation:dropoffAnnotation];
    
    [self traceRouteWithStartingCoordinates:pickupCoordinate end:dropoffCoordinate];

}

-(void)traceRouteWithStartingCoordinates: (CLLocationCoordinate2D)startCoordinate end:(CLLocationCoordinate2D) endCoordinate {
    
    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
    
    MKPlacemark *dropPlacemark = [[MKPlacemark alloc] initWithCoordinate: startCoordinate addressDictionary:nil];
    MKPlacemark *pickPlacemark = [[MKPlacemark alloc] initWithCoordinate: endCoordinate addressDictionary:nil];
    
    [directionsRequest setSource:[[MKMapItem alloc] initWithPlacemark:pickPlacemark]];
    [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:dropPlacemark]];
    directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        NSLog(@"Calculating directions completed");
        
        if (error) {
            
            NSLog(@"Calculation directions error\nError %@", error.description);
            [[            [UIAlertView alloc]initWithTitle:@"Error!" message:@"Route services is not available right now" delegate:nil cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil] show ];
        }
        else{
            assert(response);
            routeDetails = response.routes.lastObject;
            
            [self.mapView addOverlay:routeDetails.polyline ];
            
            [self showRouteOnMap];
            
        }
    }];
}


-(void)showRouteOnMap{
    
    CLLocationCoordinate2D southWest =  pickupCoord  ;
    CLLocationCoordinate2D northEast = dropoffCoord;
    
    southWest.latitude = MIN(southWest.latitude, pickupCoord.latitude);
    southWest.longitude = MIN(southWest.longitude, pickupCoord.longitude);
    
    northEast.latitude = MAX(northEast.latitude, dropoffCoord.latitude);
    northEast.longitude = MAX(northEast.longitude, dropoffCoord.longitude);
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)joinAlfred:(id)sender {
    
    NSLog(@"Selected driver");
    NSAssert(self.seatsSelectView.value > 0, @"Seats can't be zero");
    PFUser *selectedDriver = driverLocation[@"driver"];
    PFGeoPoint *pickupLocation = [PFGeoPoint geoPointWithLatitude:pickupCoord.latitude longitude:pickupCoord.longitude];
    PFGeoPoint *dropoffLocation = [PFGeoPoint geoPointWithLatitude:dropoffCoord.latitude longitude:dropoffCoord.longitude];
    NSNumber *seats = [NSNumber numberWithDouble: self.seatsSelectView.value];
    NSNumber *perSeatPrice = [NSNumber numberWithDouble: [driverLocation[@"pricePerSeat"] doubleValue]];
    NSNumber *price = [NSNumber numberWithDouble: ([seats doubleValue] * [perSeatPrice doubleValue])];
    
    NSArray* driverArr = @[selectedDriver,
                           pickupLocation,
                           dropoffLocation,
                           seats,
                           price
                           ];
    
    [self dismissViewControllerAnimated:YES completion:^(){
    
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForActiveDriverChosenForRide" object:driverArr];
    }];

}

- (IBAction)rejectAlfred:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer  * routeLineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:routeDetails.polyline];
    routeLineRenderer.strokeColor = [UIColor redColor];
    routeLineRenderer.lineWidth = 5;
    return routeLineRenderer;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)selectAlfred:(id)sender {
    
    [self joinAlfred:sender];
    
}

@end
