//
//  MessageBoardDriverJoinTableViewController.h
//  Alfred
//
//  Created by Arjun Busani on 27/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickLocationViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "HUD.h"
#import <Parse/Parse.h>

/*!
 @abstract Handle a user that want to join an alfred who postes a message in message board
 
 */

@interface MessageBoardDriverJoinTableViewController : UITableViewController<UITextFieldDelegate>
{
    BOOL isItPick;
    
    BOOL isPickupChecked,isDropoffChecked;

}
@property (strong,nonatomic) PFObject *message;
@property(strong,nonatomic)PickLocationViewController* pickLocationViewController;

@property double pickLat,pickLong,dropLat,dropLong;
@property(strong,nonatomic)NSString* city;
@property(strong,nonatomic) NSString* pickupAddress,*dropoffAddress;

@property (weak, nonatomic)  UIButton *pickupButton;
@property (weak, nonatomic)  UIButton *dropoffButton;

@property (weak, nonatomic)  UIButton *confirmJoin;
@property (nonatomic, strong) UITextField *seatsTextField;
@property (retain, nonatomic) NSMutableArray *textFieldData;
@property(strong,nonatomic)NSString* messageBoardId;
@end
