//
//  DriverHeadViewController.h
//  Alfred
//
//  Created by Miguel Angel Carvajal on 10/15/15.
//  Copyright © 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface DriverHeadViewController : UIViewController
-(void)setRideRequest:(PFObject*)rideRequest;
@property id delegate;
@end


@protocol DriverHeadDelegate <NSObject>

-(void)didRequestForShowPickupOnMap:(PFObject*)rideRequest;
-(void)didRequestForShowDropoffOnMap:(PFObject*)rideRequest;
-(void)didRequestForRouteToPickup:(PFObject*)rideRequest;
-(void)didRequestForRouteToDropoff:(PFObject*)rideRequest;


@end
