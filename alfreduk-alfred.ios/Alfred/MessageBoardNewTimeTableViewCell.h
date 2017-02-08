//
//  MessageBoardNewTimeTableViewCell.h
//  Alfred
//
//  Created by Arjun Busani on 26/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageBoardNewTimeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property(strong,nonatomic)NSString* dateString;

@end
