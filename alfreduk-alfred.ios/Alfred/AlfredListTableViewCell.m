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
    // Initialization code
 
    
    
}

-(void)updateData{
    
    
    
    PFUser * user = driverLocation[@"user"];
    PFObject *ratingObject = user[@"driverRating"];
    PFObject * driverStatus = user[@"driverStatus"];
    NSAssert(user!=nil, @"User in cell cant be nil");
    NSString *driverName = user[@"FirstName"];
    NSAssert(driverName!=nil, @"Driver name can't be nil");
    NSString *profilePicURL = user[@"ProfilePicUrl"];
    
    int numberOfSeats = [driverStatus[@"numberOfSeats" ] intValue];
    double pricePerSeat = [driverStatus[@"pricePerSeat"] doubleValue];
    NSString* destinationAddress = driverStatus[@"destinationAddress"];
    self.dropoffAddressLabel.text = destinationAddress;
    
    [ self.profilePicImageView sd_setImageWithURL:[NSURL URLWithString:profilePicURL] placeholderImage:[UIImage imageNamed:@"blank profile"]];
    self.nameLabel.text = driverName;
    
    //make rounded image
    self.profilePicImageView.layer.cornerRadius = self.profilePicImageView.layer.bounds.size.width/2;
    self.profilePicImageView.layer.masksToBounds = YES;
    
    
    
    self.ratingView.userInteractionEnabled = NO;
    [self.ratingLabel setText:[NSString stringWithFormat:@"%2.1lf",[ratingObject[@"rating"] doubleValue]]];
    
    //    self.picukAdressLabel =
    //  self.dropoffAddressLabel =
    [self.pricePerSeatLabel setText:[NSString stringWithFormat:@"%3.1lf",pricePerSeat]];
    [self.availableSeatsLabel setText: [NSString stringWithFormat:@"%1d", numberOfSeats]];
    bool ladiesOnly = [driverStatus[@"ladiesOnly"] boolValue];
    
    //check if the ride if only for ladies
    self.ladiesOnlyLabel.hidden = !ladiesOnly ;
     
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
