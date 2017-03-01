//
//  MessageBoardNewTimeTableViewCell.m
//  Alfred
//
//  Created by Arjun Busani on 26/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "MessageBoardNewTimeTableViewCell.h"

@implementation MessageBoardNewTimeTableViewCell
@synthesize datePicker,dateString;
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged]; // method to respond to changes in the picker value
    
    NSDate *selectedDate = datePicker.date;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"YYYY-MM-d hh:mm"];
    dateString = [NSString stringWithFormat:@"%@:00",[df stringFromDate:selectedDate]];

    
}

- (void)datePickerValueChanged:(id)sender{
    NSDate *selectedDate = datePicker.date;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"YYYY-MM-d hh:mm"];
    dateString = [NSString stringWithFormat:@"%@:00",[df stringFromDate:selectedDate]];

   // NSLog(@"%@:00",[df stringFromDate:selectedDate]);
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
