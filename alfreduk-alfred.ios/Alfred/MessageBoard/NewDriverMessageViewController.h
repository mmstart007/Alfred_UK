//
//  NewDriverMessageViewController.h
//  Pods
//
//  Created by Miguel Angel Carvajal on 2/15/16.
//
//

#import <UIKit/UIKit.h>
#import "PickLocationViewController.h"



@interface NewDriverMessageViewController : UITableViewController
@property NSString * pickupAddress;
@property NSString *dropoffAddress;
@property double pickLat, pickLong, dropLat, dropLong;
@property NSString * city;
@property(strong,nonatomic)PickLocationViewController *pickLocationViewController;
@end
