//
//  MessageBoardPersonalUserTableViewController.h
//  Alfred
//
//  Created by Arjun Busani on 27/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "HUD.h"
#import <Parse/Parse.h>


@interface MessageBoardPersonalUserTableViewController : UITableViewController
@property(strong,nonatomic)PFObject* selectedMessage;
@property(strong,nonatomic)NSArray* userMessageRequests;

@end
