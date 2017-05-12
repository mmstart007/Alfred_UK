//
//  MessageBoardContactUserTableViewController.h
//  Alfred
//
//  Created by Maxim on 4/27/17.
//  Copyright © 2017 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

#import "HCSStarRatingView.h"
#import "AlfredMessage.h"
#import "MessageBoardDriverDetailTableViewController.h"

@interface MessageBoardContactUserTableViewController : UITableViewController <MKMapViewDelegate>

@property(strong,nonatomic)PFObject* selectedMessage;
@property(strong,nonatomic)NSArray* driverMessageRequests;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *picImageView;
@property (weak, nonatomic) IBOutlet UILabel *pickupLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropoffLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITextView *messagesTextView;
@property (weak, nonatomic) IBOutlet UILabel *seatsLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *ladiesOnlyLabel;
@property (weak, nonatomic) IBOutlet MKMapView *alfredMapView;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *seatsSelectView;


- (IBAction)cancelJourneyAction:(id)sender;

@end
