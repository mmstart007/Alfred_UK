//
//  MessageBoardUserDetailTableViewController.m
//  Alfred
//
//  Created by Arjun Busani on 27/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "MessageBoardUserDetailTableViewController.h"
#import "SWRevealViewController.h"
#import "RideRatingViewController.h"
#import "PickupAnnotation.h"
#import "DropoffAnnotation.h"
#import "HUD.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface MessageBoardUserDetailTableViewController () {
    
    CLLocationCoordinate2D  pickupCoord;
    CLLocationCoordinate2D dropoffCoord;
    MKRoute *routeDetails;
    double rating;
    BOOL isJoin;
}


@end

@implementation MessageBoardUserDetailTableViewController
@synthesize selectedMessage,arrUserReview;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialView];
    
    arrUserReview = [[NSArray alloc] init];
    
    self.title = @"Profile";
}

-(void)backView:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
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
        self.acceptButton.enabled = NO;
    } else {
        user = from;
        self.acceptButton.enabled = YES;
    }
    
    NSDate *date = rideMessage[@"date"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm MMM dd, yyyy"];
    NSString* rideTime = [formatter stringFromDate:date];
    NSString* dropAddress = rideMessage[@"dropoffAddress"];
    NSString* originAddress = rideMessage[@"pickupAddress"];
    NSString* message = rideMessage[@"desc"];
    NSString *cell = user[@"Phone"];
    NSString* userName = [NSString stringWithFormat:@"%@ %c.", user[@"FirstName"], [(NSString*)user[@"LastName"] characterAtIndex:0]];
    NSString* pic = user[@"ProfilePicUrl"];
    BOOL femaleOnly = [rideMessage[@"femaleOnly"] boolValue];
    
    // price per seat
    int totalPrice = [selectedMessage[@"price"] intValue];
    int seats = [selectedMessage[@"seats"] intValue];
    float pricePerSeat = (float)totalPrice;
    
    if([rideMessage[@"driverMessage"] boolValue] == YES) {
        rating = [user[@"passengerRating"] doubleValue];
        isJoin = NO;
    } else {
        rating = [user[@"driverRating"] doubleValue];
        isJoin = YES;
    }
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
    self.seatsSelectView.value = [selectedMessage[@"seats"] doubleValue];
    self.seatsSelectView.maximumValue = seats;
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
                                        arrUserReview = result;
                                        [self.tableView reloadData];
                                    } else {
                                        NSLog(@"Failed to post new message");
                                        [[[UIAlertView alloc] initWithTitle:@"Alfred" message:@"Can't get reviews right now." delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil] show];
                                    }
                                }];
}

#pragma mark - UIButton Action.
- (IBAction)acceptJourneyAction:(id)sender {
    
    [HUD showUIBlockingIndicatorWithText:@"Accepting..."];
    [PFCloud callFunctionInBackground:@"AcceptRideMessage"
                       withParameters:@{@"rideObjId": selectedMessage.objectId,
                                        @"reason": @"accept",
                                        @"isDriverMessage": [NSNumber numberWithBool:isJoin]}
                                block:^(NSString *result, NSError *error) {
                                    [HUD hideUIBlockingIndicator];
                                    if (!error) {
                                        NSLog(@"accept request sent sucessfully");
                                        
                                        // send to the RatingViewController that selected message object .
                                        NSDictionary *messageInfo = [NSDictionary dictionaryWithObject:selectedMessage forKey:@"messageInfo"];
                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForGetSelectedMessageObject" object:nil userInfo:messageInfo];

                                        [self.navigationController popViewControllerAnimated:YES];
                                    } else {
                                        NSLog(@"Failed accept request.");
                                        [[[UIAlertView alloc] initWithTitle:@"Alfred" message:@"Can't get messages right now." delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil] show];
                                    }
                                }];
}

- (IBAction)declineJourneyAction:(id)sender {
    
    [HUD showUIBlockingIndicatorWithText:@"Declining..."];
    [PFCloud callFunctionInBackground:@"DeleteRideMessage"
                       withParameters:@{@"deleteMessageObjId": selectedMessage.objectId,
                                        @"reason": @"DECLINE_RIDE_MESSAGE"}
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
    return arrUserReview.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * cellIdentifier = @"AlfredReviewCell";
    MessageBoardReviewTableViewCell *cell = (MessageBoardReviewTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    PFObject *review = arrUserReview[indexPath.row];
    
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
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
