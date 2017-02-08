//
//  MessageBoardUserDetailTableViewController.h
//  Alfred
//
//  Created by Arjun Busani on 27/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlfredMessage.h"

@interface MessageBoardUserDetailTableViewController : UITableViewController
@property(strong,nonatomic)PFObject* selectedMessage;

@property(strong,nonatomic)NSArray* userMessageRequests;

@end
