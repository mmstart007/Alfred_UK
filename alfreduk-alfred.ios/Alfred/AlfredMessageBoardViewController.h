//
//  AlfredMessageBoardViewController.h
//  Alfred
//
//  Created by Miguel Angel Carvajal on 7/15/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "RideRequestDecisionViewController.h"


@interface AlfredMessageBoardViewController : UIViewController

@property(strong,nonatomic) RideRequestDecisionViewController *requestRideDecisionPopupViewController;


- (IBAction)postANewMessage:(id)sender;


@end
