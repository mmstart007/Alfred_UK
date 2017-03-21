//
//  RidesHistoryTableViewController.m
//  Alfred
//
//  Created by Arjun Busani on 26/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "RidesHistoryTableViewController.h"
#import "SWRevealViewController.h"


#import "RidesHistoryDetailTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Parse/Parse.h>


@interface RidesHistoryTableViewController ()<SWRevealViewControllerDelegate>{

    int rideRequests;
    int finishedRides;
    int canceledRides;
    int driverRideRequests;
    int driverRidesDone;
    int driverRidesCancelled;
    
}

@property (weak, nonatomic) IBOutlet UILabel *rideRequestsLabel;
@property (weak, nonatomic) IBOutlet UILabel *finishedRidesLabel;
@property (weak, nonatomic) IBOutlet UILabel *canceledRidesLabel;
@property (weak, nonatomic) IBOutlet UILabel *driverRidesDoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *driverRidesCanceledLabel;

@end

@implementation RidesHistoryTableViewController

@synthesize rideRequestsLabel,finishedRidesLabel,canceledRidesLabel,driverRidesDoneLabel,driverRidesCanceledLabel;
@synthesize userRideData,driverRideData,profilePic;
@synthesize name;

- (void)hideNavigationController {
    [self.navigationController.navigationBar setTranslucent:YES];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Ride History";
    finishedRides = [userRideData[@"rideCount"] intValue];
    canceledRides = [userRideData[@"canceledRide"] intValue];
    rideRequests = finishedRides + canceledRides;
    driverRidesDone = [driverRideData[@"rideCount"] intValue];
    driverRidesCancelled = [driverRideData[@"canceledRide"] intValue];
    driverRideRequests = driverRidesDone + driverRidesCancelled;
    
    rideRequestsLabel.text = [NSString stringWithFormat:@"%3d", rideRequests];
    finishedRidesLabel.text = [NSString stringWithFormat:@"%3d", finishedRides];
    canceledRidesLabel.text = [NSString stringWithFormat:@"%3d", canceledRides];
    driverRidesDoneLabel.text = [NSString stringWithFormat:@"%3d", driverRideRequests];
    driverRidesCanceledLabel.text = [NSString stringWithFormat:@"%3d", driverRidesCancelled];
}





@end
