//
//  RegisterButtonTableViewCell.m
//  Alfred
//
//  Created by Arjun Busani on 19/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "RegisterButtonTableViewCell.h"

@implementation RegisterButtonTableViewCell
@synthesize submitButton;
- (void)awakeFromNib {
   // [[submitButton layer] setBorderWidth:1.0f];
   // [[submitButton layer] setBorderColor:[UIColor blackColor].CGColor];
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
