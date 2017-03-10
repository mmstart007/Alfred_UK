//
//  AlfredListTableViewCell.h
//  Alfred
//
//  Created by Miguel Angel Carvajal on 10/10/15.
//  Copyright © 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import "HCSStarRatingView.h"
@interface AlfredListTableViewCell : UITableViewCell
@property (nonatomic,strong) PFObject *driverLocation;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ladiesOnlyLabel;


@property (weak, nonatomic) IBOutlet UILabel *dropoffAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *pricePerSeatLabel;
@property (weak, nonatomic) IBOutlet UILabel *availableSeatsLabel;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;

-(void)updateData;

@end
