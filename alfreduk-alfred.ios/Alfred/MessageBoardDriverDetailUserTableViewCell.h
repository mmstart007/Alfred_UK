//
//  MessageBoardDriverDetailUserTableViewCell.h
//  Alfred
//
//  Created by Arjun Busani on 27/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageBoardDriverDetailUserTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *pickupLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropoffLabel;
@property (weak, nonatomic) IBOutlet UILabel *seatsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *picImageView;

@end
