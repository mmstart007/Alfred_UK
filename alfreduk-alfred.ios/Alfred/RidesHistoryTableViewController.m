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
    
    rideRequests = 0;
    finishedRides = 0;
    canceledRides = 0;
    driverRidesDone = 0;
    driverRidesCancelled = 0;
    [self getUsersRideHistory];
    
    

 
    name = [PFUser currentUser] [@"FullName"];
    
    profilePic = [PFUser currentUser][@"ProfilePicUrl"];
 
  

    

    

    
   
    
    self.title = @"Ride History";
    
   
    [self getDriverRideHistory];
    [self getUsersRideHistory];
}


-(void)getDriverRideHistory{
    
    PFQuery *query1 = [PFQuery queryWithClassName:@"RideRequest"];
    [query1 whereKey:@"driver" equalTo:[PFUser currentUser]];
    
    [query1 countObjectsInBackgroundWithBlock:^(int count, NSError *error){
        if(!error){
            
            driverRidesDone = count;
            
            
            [self reloadData];
        }
        
    }];
    
    PFQuery *query2 = [PFQuery queryWithClassName:@"RideRequest"];
    [query2 whereKey:@"driver" equalTo:[PFUser currentUser]];
    [query2 whereKey:@"canceledByDriver" equalTo:@YES];
    
    
    [query2 countObjectsInBackgroundWithBlock:^(int count, NSError *error){
        if(!error){
            
            driverRidesCancelled = count;
            
            
            [self reloadData];
        }
        
    }];
    
    

}
-(void)getUsersRideHistory{
    
    
    PFQuery *query1 = [PFQuery queryWithClassName:@"RideRequest"];
    [query1 whereKey:@"requestedBy" equalTo:[PFUser currentUser]];
    
    [query1 countObjectsInBackgroundWithBlock:^(int count, NSError *error){
        if(!error){
            
            rideRequests  = count;
            
            [self reloadData];
        }
        
    }];
    
    PFQuery *query2 = [PFQuery queryWithClassName:@"RideRequest"];
    [query2 whereKey:@"requestedBy" equalTo:[PFUser currentUser]];
    [query2 whereKey:@"finished" equalTo:@YES];
    [query2 countObjectsInBackgroundWithBlock:^(int count, NSError *error){
        if(!error){
            
            finishedRides  = count;
            
            [self reloadData];
        }
        
    }];
    
    PFQuery *query3 = [PFQuery queryWithClassName:@"RideRequest"];
    [query3 whereKey:@"requestedBy" equalTo:[PFUser currentUser]];
    [query3 whereKey:@"canceled" equalTo:@YES];
    [query3 countObjectsInBackgroundWithBlock:^(int count, NSError *error){
        if(!error){
            
            canceledRides  = count;
            
            [self reloadData];
        }
        
    }];
    
    
    
    
}


-(void)reloadData{
    self.rideRequestsLabel.text = [NSString stringWithFormat:@"%d",rideRequests];
    self.canceledRidesLabel.text = [NSString stringWithFormat:@"%d",canceledRides];
    self.finishedRidesLabel.text = [NSString stringWithFormat:@"%d", finishedRides];
    
    
    self.driverRidesDoneLabel.text= [NSString stringWithFormat:@"%d", driverRidesDone];
    self.driverRidesCanceledLabel.text = [NSString stringWithFormat:@"%d", driverRidesCancelled];
    
    

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
