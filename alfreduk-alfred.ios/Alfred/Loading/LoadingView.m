 //
//  LoadingView.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 1/22/16.
//  Copyright © 2016 A Ascendanet Sun. All rights reserved.
//

#import "LoadingView.h"
#import <Parse/Parse.h>
#import "SWRevealViewController.h"
#import "RiderViewController.h"
#import "DriverViewController.h"
#import "SideMenuTableViewController.h"


@interface LoadingView (){

    BOOL _isRider;
    
    PFObject *_driverStatus;
}

@end



@implementation LoadingView
-(void)viewDidLoad{

    [super viewDidLoad];

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
       if([PFUser currentUser]){
        [self loadLoggedUser];
    }else{
        
        [self performSegueWithIdentifier:@"Login" sender:self];
    }
}
-(void)loadLoggedUser{

    PFUser * currentUser =  [PFUser currentUser];
    
    [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
       
        
        bool userMode = [currentUser[@"UserMode"] boolValue];
        if(userMode){
            [self loadRider];
        }else{
            
            _driverStatus = currentUser[@"driverStatus"];
            
            [_driverStatus fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                _driverStatus = object;
                
                [self loadDriver];
            }];
            
        }
        
        
    }];
    
    


}

-(void)loadRider{
    
    _isRider = YES;
    

    

    
    UIStoryboard *storybaord = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
   RiderViewController *riderViewController = [storybaord instantiateViewControllerWithIdentifier:@"MainPageId"];
    

    
   
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:riderViewController];
    SideMenuTableViewController *menuViewController = [storybaord instantiateViewControllerWithIdentifier:@"MenuViewController"];
    
    SWRevealViewController *viewController = [[SWRevealViewController alloc] initWithRearViewController:menuViewController
                                              
                                              
                                               frontViewController:navigationController];
    
    [self presentViewController:viewController animated:YES completion:nil];
    

    

}


-(void)loadDriver{
    
    
    _isRider = NO;
    
    
    UIStoryboard *storybaord = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    DriverViewController *driverViewController = [storybaord instantiateViewControllerWithIdentifier:@"DriverMainID"];
    
    
    
    driverViewController.driverStatus = _driverStatus;

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:driverViewController];
    
    
    SideMenuTableViewController *menuViewController = [storybaord instantiateViewControllerWithIdentifier:@"MenuViewController"];
    
    SWRevealViewController *viewController = [[SWRevealViewController alloc] initWithRearViewController:menuViewController
                                              
                                              
                                                                                    frontViewController:navigationController];
    
    [self presentViewController:viewController animated:YES completion:nil];
   
}




@end
