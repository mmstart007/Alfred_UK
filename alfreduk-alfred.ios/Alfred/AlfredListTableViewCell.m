//
//  AlfredListTableViewCell.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 10/10/15.
//  Copyright © 2015 A Ascendanet Sun. All rights reserved.
//

#import "AlfredListTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation AlfredListTableViewCell
@synthesize driverLocation;
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

}

-(void)updateData{
    
    PFUser * user = driverLocation[@"driver"];
    PFObject *ratingObject = user[@"driverRating"];
    NSAssert(user!=nil, @"User in cell cant be nil");
    NSString *driverName = user[@"FullName"];
    NSAssert(driverName!=nil, @"Driver name can't be nil");
    NSString *profilePicURL = user[@"ProfilePicUrl"];
    
    int numberOfSeats = [driverLocation[@"availableSeats" ] intValue];
    double pricePerSeat = [driverLocation[@"pricePerSeat"] doubleValue] / 100;
    NSString* destinationAddress = driverLocation[@"destinationAddress"];
    self.dropoffAddressLabel.text = destinationAddress;
    
    [self.profilePicImageView sd_setImageWithURL:[NSURL URLWithString:profilePicURL] placeholderImage:[UIImage imageNamed:@"blank profile"]];
    self.nameLabel.text = driverName;
    
    //make rounded image
    self.profilePicImageView.layer.cornerRadius = self.profilePicImageView.layer.bounds.size.width/2;
    self.profilePicImageView.layer.masksToBounds = YES;
    
    NSString *ratingValue = [NSString stringWithFormat:@"%2.1lf",[ratingObject[@"rating"] doubleValue]];
    self.ratingView.userInteractionEnabled = NO;
    self.ratingView.value = [ratingValue doubleValue];
    [self.ratingLabel setText:ratingValue];
    
    [self.pricePerSeatLabel setText:[NSString stringWithFormat:@"%3.1lf",pricePerSeat]];
    [self.availableSeatsLabel setText: [NSString stringWithFormat:@"%1d", numberOfSeats]];
    bool ladiesOnly = [driverLocation[@"ladiesOnly"] boolValue];
    
    //check if the ride if only for ladies
    self.ladiesOnlyLabel.hidden = !ladiesOnly ;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
