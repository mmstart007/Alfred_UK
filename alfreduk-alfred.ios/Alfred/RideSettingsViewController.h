//
//  RideSettingsViewController.h
//  Alfred
//
//  Created by Miguel Angel Carvajal on 9/23/15.
//  Copyright © 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface RideSettingsViewController : UITableViewController


- (IBAction)saveRideData:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *ladiesOnly;


@property PFGeoPoint *destination;
@property NSString *destinationAddress;


@end
