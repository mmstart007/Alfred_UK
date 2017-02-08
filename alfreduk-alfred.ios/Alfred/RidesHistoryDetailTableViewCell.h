//
//  RidesHistoryDetailTableViewCell.h
//  Alfred
//
//  Created by Arjun Busani on 26/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RidesHistoryDetailTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *riderLabel;
@property (weak, nonatomic) IBOutlet UILabel *ridesLabel;
@property (weak, nonatomic) IBOutlet UILabel *spentLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;

@end
