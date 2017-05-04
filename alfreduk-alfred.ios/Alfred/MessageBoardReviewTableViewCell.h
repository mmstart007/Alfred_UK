//
//  MessageBoardReviewTableViewCell.h
//  Alfred
//
//  Created by Arjun Busani on 26/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlfredMessage.h"

#import "HCSStarRatingView.h"

@interface MessageBoardReviewTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *cellBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;

- (void)configureCell:(PFObject*)reviewData;

@end
