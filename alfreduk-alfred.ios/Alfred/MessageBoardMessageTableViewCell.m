//
//  MessageBoardMessageTableViewCell.m
//  Alfred
//
//  Created by Arjun Busani on 26/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "MessageBoardMessageTableViewCell.h"

@implementation MessageBoardMessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureMessageCell:(PFObject *)message {
    
    PFUser *user = message[@"author"];
    PFObject *ratingObject = user[@"driverRating"];

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

    self.dateLabel.text = [formatter stringFromDate:date];
    self.nameLabel.text = userName;
    self.titleLabel.text = title;
    self.pickupLabel.text = originAddress;
    self.dropoffLabel.text = dropAddress;
    self.ratingLabel.text = [NSString stringWithFormat:@"%2.1lf", [ratingObject[@"rating"] doubleValue]];
    self.profilePicImageView.layer.cornerRadius = self.profilePicImageView.frame.size.height /2;
    self.profilePicImageView.layer.masksToBounds = YES;
    self.profilePicImageView.layer.borderWidth = 0;
    self.cellBackgroundView.layer.cornerRadius = 15;
    self.cellBackgroundView.layer.masksToBounds = YES;
    self.cellBackgroundView.layer.borderWidth = 0;

    if([message[@"driverMessage"] boolValue] == YES){
        self.alfredIconImageView.hidden = NO;
        self.seatsLabel.text = [NSString stringWithFormat:@"%2d SEAT,",seats];
        self.priceLabel.text = [NSString stringWithFormat:@"£%5.2lf",pricePerSeat];
    } else {
        self.alfredIconImageView.hidden = YES;
        self.seatsLabel.text = [NSString stringWithFormat:@"%2d SEAT",seats];
        self.priceLabel.text = @"";
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
