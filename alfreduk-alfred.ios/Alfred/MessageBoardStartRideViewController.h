//
//  MessageBoardStartRideViewController.h
//  Alfred
//
//  Created by Arjun Busani on 03/04/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "HUD.h"
@interface MessageBoardStartRideViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightLayoutConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickupLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropoffLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *seatsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *maleImageView;
- (IBAction)startTheRide:(id)sender;

@property (strong, nonatomic)NSString* latNow;
@property (strong, nonatomic)NSString* longNow;
@property(strong,nonatomic)NSDictionary* messageBoardDict;

@end
