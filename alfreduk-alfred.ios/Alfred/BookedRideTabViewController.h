//
//  BookedRideTabViewController.h
//  Alfred
//
//  Created by Miguel Angel Carvajal on 3/12/16.
//  Copyright © 2016 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

#import "HCSStarRatingView.h"

@interface BookedRideTabViewController : UITableViewController

@property(strong,nonatomic)PFObject* selectedMessage;
@property(strong,nonatomic)NSArray* driverMessageRequests;


@end
