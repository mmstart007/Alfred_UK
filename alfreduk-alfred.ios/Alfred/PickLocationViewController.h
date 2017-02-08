//
//  PickLocationViewController.h
//  Alfred
//
//  Created by Arjun Busani on 03/04/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface PickLocationViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
/*!
 @abstract true is the view controler will be used for select a pickup location,
 if it is false, the it will be for a dropoff location,
 defaults to true
 */
@property BOOL isPickup;
@property(strong,nonatomic)NSString* address;
@property(strong,nonatomic)NSString* city;
@property double myLat,myLong;

@end
