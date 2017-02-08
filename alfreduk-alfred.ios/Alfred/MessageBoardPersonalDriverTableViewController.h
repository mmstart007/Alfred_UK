//
//  MessageBoardPersonalDriverTableViewController.h
//  Alfred
//
//  Created by Arjun Busani on 27/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "HUD.h"
#import "AlfredMessage.h"


@interface MessageBoardPersonalDriverTableViewController : UITableViewController
@property(strong,nonatomic)AlfredMessage* selectedMessage;
@property(strong,nonatomic)NSArray* driverMessageRequests;
@property (weak, nonatomic)  UIButton *startRideButton;

@end
