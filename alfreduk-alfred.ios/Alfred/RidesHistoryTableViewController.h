//
//  RidesHistoryTableViewController.h
//  Alfred
//
//  Created by Arjun Busani on 26/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "HUD.h"
#import <Parse/Parse.h>

@interface RidesHistoryTableViewController : UITableViewController

@property(strong,nonatomic) PFUser* currentUser;
@property(strong,nonatomic) NSString* profilePic;
@property (strong,nonatomic) NSString* name;

@end
