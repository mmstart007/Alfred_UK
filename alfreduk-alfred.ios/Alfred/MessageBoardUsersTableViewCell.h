//
//  MessageBoardUsersTableViewCell.h
//  Alfred
//
//  Created by Arjun Busani on 07/04/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageBoardUsersTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *pickLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropLabel;
@property (weak, nonatomic) IBOutlet UILabel *seatsLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicImageView;

@end
