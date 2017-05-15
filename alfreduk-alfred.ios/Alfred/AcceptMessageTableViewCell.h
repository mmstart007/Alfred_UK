//
//  AcceptMessageTableViewCell.h
//  Alfred
//
//  Created by Maxim on 5/10/17.
//  Copyright © 2017 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import "MGSwipeTableCell/MGSwipeTableCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TWMessageBarManager.h"


@interface AcceptMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *cellBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *alfredIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickupLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropoffLabel;
@property (weak, nonatomic) IBOutlet UILabel *seatsLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *ladiesOnlyLabel;

- (void) configureRequestMessageCell:(PFObject *)messageData;

@end
