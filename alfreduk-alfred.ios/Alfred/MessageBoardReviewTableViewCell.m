//
//  MessageBoardReviewTableViewCell.m
//  Alfred
//
//  Created by Arjun Busani on 26/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "MessageBoardReviewTableViewCell.h"
#import "NSDate+TimeAgo.h"


@implementation MessageBoardReviewTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCell:(PFObject*)reviewData {
    
    UIColor *borderColor = [UIColor colorWithRed:80.0f/255 green:180.0f/255 blue:190.0f/255 alpha:1.0f];
    self.cellBackgroundView.layer.borderColor = borderColor.CGColor;
    self.cellBackgroundView.layer.cornerRadius = 15;
    self.cellBackgroundView.layer.masksToBounds = YES;
    self.cellBackgroundView.layer.borderWidth = 1;
    
    // cell
    PFUser *fromUser = reviewData[@"from"];
    NSString *name = [NSString stringWithFormat:@"%@", fromUser[@"FullName"]];
    double ratingValue = [reviewData[@"rating"] doubleValue];
    NSString *rating = [NSString stringWithFormat:@"%2.1lf", ratingValue];
    NSDate *reviewDate = [reviewData createdAt];
    
    self.userName.text = name;
    self.ratingLabel.text = rating;
    self.ratingView.value = ratingValue;
    self.timeLabel.text = [reviewDate timeAgo];
}

@end
