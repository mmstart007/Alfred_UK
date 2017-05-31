//
//  RequestMessageTableViewCell.m
//  Alfred
//
//  Created by Maxim on 5/6/17.
//  Copyright © 2017 A Ascendanet Sun. All rights reserved.
//

#import "RequestMessageTableViewCell.h"

@implementation RequestMessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureRequestMessageCell:(PFObject *)message {
    
    PFUser *user;
    PFObject *rideMessage = message[@"rideMessage"];
    BOOL isDriverMessage = [rideMessage[@"driverMessage"] boolValue];
    
    PFUser *from, *to;
    from = message[@"from"];
    to = message[@"to"];
    if ([from.objectId isEqualToString:[[PFUser currentUser] objectId]]) {
        user = to;
        if(isDriverMessage) {
            self.alfredIconImageView.hidden = NO;
        } else {
            self.alfredIconImageView.hidden = YES;
        }
    } else {
        user = from;
        if(isDriverMessage) {
            self.alfredIconImageView.hidden = YES;
        } else {
            self.alfredIconImageView.hidden = NO;
        }
    }
    
    int seats = [message[@"seats"] intValue];
    NSString* dropAddress = rideMessage[@"dropoffAddress"];
    NSString* originAddress = rideMessage[@"pickupAddress"];
    double pricePerSeat = [message[@"price"] doubleValue];
    NSString* title = rideMessage[@"title"];
    NSDate *date = rideMessage[@"date"];
    bool femaleOnly = [rideMessage[@"femaleOnly"] boolValue];
    NSString *pic = user[@"ProfilePicUrl"];
    NSString *firstName  = user[@"FirstName"];
    NSString *lastName = user[@"LastName"];
    NSString *userName = [NSString stringWithFormat:@"%@ %c.",firstName, [lastName characterAtIndex:0]];
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MMM dd, HH:mm"];
    NSString *reason = message[@"status"];
    
    self.dateLabel.text = [formatter stringFromDate:date];
    self.nameLabel.text = userName;
    self.titleLabel.text = title;
    self.pickupLabel.text = originAddress;
    self.dropoffLabel.text = dropAddress;
    self.profilePicImageView.layer.cornerRadius = self.profilePicImageView.frame.size.height /2;
    self.profilePicImageView.layer.masksToBounds = YES;
    self.profilePicImageView.layer.borderWidth = 0;
    self.cellBackgroundView.layer.cornerRadius = 15;
    self.cellBackgroundView.layer.masksToBounds = YES;
    self.cellBackgroundView.layer.borderWidth = 0;
    self.seatsLabel.text = [NSString stringWithFormat:@"%2d SEAT,",seats];
    self.priceLabel.text = [NSString stringWithFormat:@"£%5.2lf",pricePerSeat];
    
    if ([reason isEqualToString:@"request"]) {
        self.ratingLabel.text = [NSString stringWithFormat:@"%.1f", [user[@"driverRating"] doubleValue]];
    } else {
        self.ratingLabel.text = [NSString stringWithFormat:@"%.1f", [user[@"passengerRating"] doubleValue]];
    }
    if(femaleOnly) {
        self.ladiesOnlyLabel.hidden = NO;
    } else {
        self.ladiesOnlyLabel.hidden = YES;
    }
    if (![pic isKindOfClass:[NSNull class]]) {
        [self.profilePicImageView sd_setImageWithURL:[NSURL URLWithString:pic] placeholderImage:[UIImage imageNamed:@"blank profile"]];
    }
}

- (void)configureMyMessageCell:(PFObject *)message {

    PFUser *user = message[@"author"];
    BOOL isDriverMessage = [message[@"driverMessage"] boolValue];
    
    int seats = [message[@"seats"] intValue];
    NSString* dropAddress = message[@"dropoffAddress"];
    NSString* originAddress = message[@"pickupAddress"];
    double pricePerSeat = [message[@"pricePerSeat"] doubleValue];
    NSString* title = message[@"title"];
    NSDate *date = message[@"date"];
    bool femaleOnly = [message[@"femaleOnly"] boolValue];
    NSString *pic = user[@"ProfilePicUrl"];
    NSString *firstName  = user[@"FirstName"];
    NSString *lastName = user[@"LastName"];
    NSString *userName = [NSString stringWithFormat:@"%@ %c.",firstName, [lastName characterAtIndex:0]];
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MMM dd, HH:mm"];
    
    self.showmoreLabel.hidden = YES;
    self.dateLabel.text = [formatter stringFromDate:date];
    self.nameLabel.text = userName;
    self.titleLabel.text = title;
    self.pickupLabel.text = originAddress;
    self.dropoffLabel.text = dropAddress;
    self.profilePicImageView.layer.cornerRadius = self.profilePicImageView.frame.size.height /2;
    self.profilePicImageView.layer.masksToBounds = YES;
    self.profilePicImageView.layer.borderWidth = 0;
    self.cellBackgroundView.layer.cornerRadius = 15;
    self.cellBackgroundView.layer.masksToBounds = YES;
    self.cellBackgroundView.layer.borderWidth = 0;
    
    if(isDriverMessage) {
        self.alfredIconImageView.hidden = NO;
        self.ratingLabel.text = [NSString stringWithFormat:@"%.1f", [user[@"driverRating"] doubleValue]];
        self.seatsLabel.text = [NSString stringWithFormat:@"%2d SEAT,",seats];
        self.priceLabel.text = [NSString stringWithFormat:@"£%5.2lf",pricePerSeat];
    } else {
        self.alfredIconImageView.hidden = YES;
        self.seatsLabel.text = [NSString stringWithFormat:@"%2d SEAT",seats];
        self.priceLabel.text = @"";
        self.ratingLabel.text = [NSString stringWithFormat:@"%.1f", [user[@"passengerRating"] doubleValue]];
    }
    
    if(femaleOnly) {
        self.ladiesOnlyLabel.hidden = NO;
    } else {
        self.ladiesOnlyLabel.hidden = YES;
    }
    if (![pic isKindOfClass:[NSNull class]]) {
        [self.profilePicImageView sd_setImageWithURL:[NSURL URLWithString:pic] placeholderImage:[UIImage imageNamed:@"blank profile"]];
    }
}




@end
