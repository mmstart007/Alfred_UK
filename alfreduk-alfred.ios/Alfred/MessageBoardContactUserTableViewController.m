//
//  MessageBoardContactUserTableViewController.m
//  Alfred
//
//  Created by Maxim on 4/27/17.
//  Copyright © 2017 A Ascendanet Sun. All rights reserved.
//

#import "MessageBoardContactUserTableViewController.h"
#import "MessageBoardReviewTableViewCell.h"
#import "PickupAnnotation.h"
#import "DropoffAnnotation.h"
#import "HUD.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface MessageBoardContactUserTableViewController () {
    
    CLLocationCoordinate2D  pickupCoord;
    CLLocationCoordinate2D dropoffCoord;
    MKRoute *routeDetails;
    double rating;
    BOOL isJoin;
}



@end

@implementation MessageBoardContactUserTableViewController

@synthesize selectedMessage,driverMessageRequests;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialView];
    
    driverMessageRequests = [[NSArray alloc] init];
    driverMessageRequests = selectedMessage[@"driverMessageRequests"];

    self.navigationItem.title = @"Profile";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialView {
    
    //user data
    PFUser * user;
    PFObject *rideMessage = selectedMessage[@"rideMessage"];
    
    PFUser *from, *to;
    from = selectedMessage[@"from"];
    to = selectedMessage[@"to"];
    if ([from.objectId isEqualToString:[[PFUser currentUser] objectId]]) {
        user = to;
        if([rideMessage[@"driverMessage"] boolValue]) {
            rating = [user[@"driverRating"] doubleValue];
            isJoin = YES;
        } else {
            rating = [user[@"passengerRating"] doubleValue];
            isJoin = NO;
        }
    } else {
        user = from;
        if([rideMessage[@"driverMessage"] boolValue]) {
            rating = [user[@"passengerRating"] doubleValue];
            isJoin = NO;
        } else {
            rating = [user[@"driverRating"] doubleValue];
            isJoin = YES;
        }
    }
    NSDate *date = rideMessage[@"date"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm MMM dd, yyyy"];
    NSString* rideTime = [formatter stringFromDate:date];
    int seats = [selectedMessage[@"seats"] intValue];
    NSString* dropAddress = rideMessage[@"dropoffAddress"];
    NSString* originAddress = rideMessage[@"pickupAddress"];
    double pricePerSeat = [selectedMessage[@"price"] doubleValue];
    NSString* message = rideMessage[@"desc"];
    BOOL femaleOnly = [rideMessage[@"femaleOnly"] boolValue];
    NSString *cell = user[@"Phone"];
    
    NSString* userName = [NSString stringWithFormat:@"%@ %c.",
                          user[@"FirstName"],
                          [ (NSString*)user[@"LastName"] characterAtIndex:0]];
    
    NSString* pic = user[@"ProfilePicUrl"];
    
    if (![pic isKindOfClass:[NSNull class]]) {
        [self.picImageView sd_setImageWithURL:[NSURL URLWithString:pic] placeholderImage:[UIImage imageNamed:@"blank profile"]];
    }
    [self.nameLabel setText:[NSString stringWithFormat:@"%@",userName]];
    [self.cellLabel setText:cell]; //this is a hack for now
    [self.ratingLabel setText:[NSString stringWithFormat:@"%.1f",rating]];
    [self.pickupLabel setText:originAddress];
    [self.dropoffLabel setText:dropAddress];
    [self.timeLabel setText:rideTime];
    [self.messagesTextView setText:message];
    [self.priceLabel setText:[NSString stringWithFormat:@"Price: £%3.2lf per seat", pricePerSeat]];
    self.picImageView.layer.cornerRadius = self.picImageView.frame.size.height /2;
    self.picImageView.layer.masksToBounds = YES;
    self.picImageView.layer.borderWidth = 0;
    self.seatsLabel.text = [NSString stringWithFormat:@"Seats available: %2d",seats];
    self.seatsSelectView.maximumValue = seats;
    self.seatsSelectView.value = [rideMessage[@"seats"] doubleValue];
    self.seatsSelectView.userInteractionEnabled = NO;
    [self.seatsSelectView setNeedsDisplay];
    
    if (femaleOnly) {
        [self.ladiesOnlyLabel setHidden:NO];
    } else {
        [self.ladiesOnlyLabel setHidden:YES];
    }
    
    self.alfredMapView.delegate = self;
    pickupCoord.latitude = (CLLocationDegrees)[rideMessage[@"pickupLat"] doubleValue];
    pickupCoord.longitude = (CLLocationDegrees)[rideMessage[@"pickupLong"] doubleValue];
    dropoffCoord.latitude = (CLLocationDegrees)[rideMessage[@"dropoffLat"] doubleValue];
    dropoffCoord.longitude = (CLLocationDegrees)[rideMessage[@"dropoffLong"] doubleValue];
    
    [self.alfredMapView setShowsUserLocation:YES];
    CLLocationCoordinate2D coord = self.alfredMapView.userLocation.location.coordinate;
    MKCoordinateRegion initialRegion = MKCoordinateRegionMakeWithDistance(coord, 1000.0, 1000.0);
    [self.alfredMapView setRegion:initialRegion animated:YES];
    
    [self loadMapWithPickup:pickupCoord dropOff:dropoffCoord];
    
    // get user review
    [self getUserReview:user.objectId isDriverMessage:isJoin];
}

- (void)getUserReview:(NSString *)userID isDriverMessage:(BOOL)isDriver {
    
    [HUD showUIBlockingIndicatorWithText:@"Loading..."];
    [PFCloud callFunctionInBackground:@"GetUserReview"
                       withParameters:@{@"to": userID,
                                        @"isDriver": [NSNumber numberWithBool:isDriver]}
                                block:^(NSArray *result, NSError *error) {
                                    [HUD hideUIBlockingIndicator];
                                    if (!error) {
                                        NSLog(@"get user review sucessfully");
                                        driverMessageRequests = result;
                                        [self.tableView reloadData];
                                    } else {
                                        NSLog(@"Failed to post new message");
                                        [[[UIAlertView alloc] initWithTitle:@"Alfred" message:@"Can't get messages right now." delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil] show];
                                    }
                                }];
}

#pragma mark - UIButton Action.
- (IBAction)cancelJourneyAction:(id)sender {

    [HUD showUIBlockingIndicatorWithText:@"Canceling..."];
    [PFCloud callFunctionInBackground:@"DeleteRideMessage"
                       withParameters:@{@"deleteMessageObjId": selectedMessage.objectId,
                                        @"reason": @"CANCEL_RIDE_MESSAGE"}
                                block:^(NSString *success, NSError *error) {
                                    [HUD hideUIBlockingIndicator];
                                    if (!error) {
                                        
                                        NSLog(@"delete request board message sucessfully");
                                        
                                        [self.navigationController popViewControllerAnimated:YES];
                                    } else {
                                        
                                        NSLog(@"Getting request message failed");
                                        
                                        [[[UIAlertView alloc] initWithTitle:@"Alfred" message:@"Can't get messages right now." delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil] show];
                                    }
                                }];
}

#pragma mark - UITableView Data Source.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return driverMessageRequests.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * cellIdentifier = @"AlfredReviewCell";
    MessageBoardReviewTableViewCell *cell = (MessageBoardReviewTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    PFObject *review = driverMessageRequests[indexPath.row];
    
    [cell configureCell:review];
    
    return cell;
}

#pragma mark - UITableView Delegate.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 92;
}

#pragma mark - MKMapView.
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer  * routeLineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:routeDetails.polyline];
    routeLineRenderer.strokeColor = [UIColor redColor];
    routeLineRenderer.lineWidth = 5;
    return routeLineRenderer;
}

-(void)loadMapWithPickup:( CLLocationCoordinate2D)pickupCoordinate dropOff:(CLLocationCoordinate2D)dropoffCoordinate{
    
    PickupAnnotation *pickupAnnotation  = [[PickupAnnotation alloc] initiWithTitle:@"" Location:pickupCoordinate];
    
    DropoffAnnotation *dropoffAnnotation = [[DropoffAnnotation alloc] initiWithTitle:@"" Location:dropoffCoordinate];
    
    [self.alfredMapView addAnnotation:pickupAnnotation];
    [self.alfredMapView addAnnotation:dropoffAnnotation];
    
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
            
            [self.alfredMapView addOverlay:routeDetails.polyline ];
            
            [self showRouteOnMap];
            
        }
    }];
}

-(void)showRouteOnMap {
    
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
    
    [self.alfredMapView setRegion:regionRoute animated:YES];
    
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
