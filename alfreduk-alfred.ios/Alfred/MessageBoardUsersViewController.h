//
//  MessageBoardUsersViewController.h
//  Alfred
//
//  Created by Arjun Busani on 06/04/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "HUD.h"
#import <CoreLocation/CoreLocation.h>

@interface MessageBoardUsersViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dropoffConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickupConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIView *popUpView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftLayoutConstraint;
@property (weak, nonatomic) IBOutlet UITableView *usersTabelView;
@property (strong, nonatomic) NSArray *usersArray;
- (IBAction)userSelected:(id)sender;
- (IBAction)dropUser:(id)sender;
- (IBAction)pickUser:(id)sender;
@property (strong, nonatomic)NSString* latNow;
@property (strong, nonatomic)NSString* longNow;
@property (weak, nonatomic) IBOutlet UIButton *dropButton;
@property (weak, nonatomic) IBOutlet UIButton *pickupButton;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;

@property (strong, nonatomic) NSString* requestRideId;
@end
