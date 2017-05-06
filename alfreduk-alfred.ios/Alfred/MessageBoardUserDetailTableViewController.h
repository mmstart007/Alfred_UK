//
//  MessageBoardUserDetailTableViewController.h
//  Alfred
//
//  Created by Arjun Busani on 27/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlfredMessage.h"

#import "MessageBoardDriverDetailTableViewController.h"
#import "MessageBoardReviewTableViewCell.h"

@interface MessageBoardUserDetailTableViewController : UITableViewController <MKMapViewDelegate>

@property(strong,nonatomic)PFObject* selectedMessage;
@property(strong,nonatomic)NSArray* arrUserReview;

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

- (IBAction)acceptJourneyAction:(id)sender;
- (IBAction)declineJourneyAction:(id)sender;

@end
