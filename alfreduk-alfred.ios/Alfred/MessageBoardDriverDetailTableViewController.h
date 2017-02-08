//
//  MessageBoardDriverDetailTableViewController.h
//  Alfred
//
//  Created by Arjun Busani on 26/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlfredMessage.h"

/*!
 @summary This is the View controller for displaying the data that a passenger shall see when a message is posted from a driver
 */

@interface MessageBoardDriverDetailTableViewController : UITableViewController
@property(strong,nonatomic)PFObject* selectedMessage;
@property(strong,nonatomic)NSArray* driverMessageRequests;

@end
