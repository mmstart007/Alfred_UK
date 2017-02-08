//
//  MessageBoardNewNumberOfSeatsTableViewCell.h
//  Alfred
//
//  Created by Arjun Busani on 26/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckBoxButton.h"
@interface MessageBoardNewNumberOfSeatsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *seatsTextField;
@property (weak, nonatomic) IBOutlet CheckBoxButton *femaleCheckButton;

@end
