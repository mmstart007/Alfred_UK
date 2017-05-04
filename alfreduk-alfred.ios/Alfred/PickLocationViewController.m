//
//  PickLocationViewController.m
//  Alfred
//
//  Created by Arjun Busani on 03/04/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "PickLocationViewController.h"

#import "SearchViewController.h"
#import "HUD.h"


@interface PickLocationViewController () <AlfredSearchControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *makerImage;

@end

@implementation PickLocationViewController
@synthesize mapView,locationManager,myLat,myLong,address,city;
@synthesize isPickup;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"Select pickup";
    if(!isPickup){
        self.makerImage.image = [UIImage imageNamed:@"dropoff"];
        self.navigationItem.title = @"Select dropoff";
    }
    
    
    [self.navigationItem setHidesBackButton:YES];

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
    //check if autorized to use location services
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



}
/*
 This is called when the search button is taped 
 for searching the location with text
 The result of the location is passed back with a push notification
 
 */

- (IBAction)searchLocation:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    SearchViewController * searchVC = (SearchViewController*)[storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];

    UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:searchVC];
    
    searchVC.delegate = self;


    [self presentViewController:navBar animated:YES completion:nil];

    
}

-(void)searchViewController:(id)controller didFinishedSearchWithPlacemark:(CLPlacemark *)placemark{
    
    [(SearchViewController*)controller dismissViewControllerAnimated:YES completion:nil];
    address = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
    city = [placemark locality];
    
    NSMutableArray* locationArray = [[NSMutableArray alloc] init];
    [locationArray addObject:[NSNumber numberWithDouble:myLat]];
    [locationArray addObject:[NSNumber numberWithDouble:myLong]];
    if(city){
        [locationArray addObject:city];
    }
    else{
        [locationArray addObject:@"Unknown City"];
    }
    [locationArray addObject:address];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForLocation" object:locationArray];
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)cancel:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)setLocation:(id)sender {
    CLGeocoder *locator = [[CLGeocoder alloc]init];
    
    CLLocationCoordinate2D centre = [mapView centerCoordinate];
    myLat = centre.latitude;
    myLong = centre.longitude;
    
    self.setLocationButton.hidden = YES;
    [HUD showUIBlockingIndicator];
    CLLocation *location = [[CLLocation alloc]initWithLatitude:myLat longitude:myLong];
    [locator reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        [HUD hideUIBlockingIndicator];
        if(!error) {
            
            CLPlacemark *placemark = [placemarks firstObject];

            address = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
            city = [placemark locality];
        
            NSMutableArray* locationArray = [[NSMutableArray alloc] init];
            [locationArray addObject:[NSNumber numberWithDouble:myLat]];
            [locationArray addObject:[NSNumber numberWithDouble:myLong]];
            if(city){
                [locationArray addObject:city];
            } else {
                [locationArray addObject:@"Unknown City"];
            }
            [locationArray addObject:address];
            //post notification with pickup data
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForLocation" object:locationArray];


            [self.navigationController popViewControllerAnimated:YES];
            
        }else{
           
            self.setLocationButton.hidden = NO;
            NSLog(@"%@", [NSString stringWithFormat:@"setLocation error: %@", error ]);
            UIAlertView * locationErrorAlertView = [[UIAlertView alloc] initWithTitle:@"Location Error" message:@"Failed to set location" delegate:nil cancelButtonTitle:@"Try later" otherButtonTitles: nil, nil];
            [locationErrorAlertView show];
            
            //[self dismissViewControllerAnimated:YES completion:nil];
        }
        
    }];
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
