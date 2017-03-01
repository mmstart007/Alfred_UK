//
//  MessageBoardNewLogoTableViewCell.m
//  Alfred
//
//  Created by Arjun Busani on 26/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "MessageBoardNewLogoTableViewCell.h"

@implementation MessageBoardNewLogoTableViewCell
@synthesize userButton,driverButton;
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)driverSelected:(id)sender {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    
    if([prefs boolForKey:@"isDriver"]) {
        
    userButton.alpha = 0.5;
    driverButton.alpha = 1;
    }

    
}
- (IBAction)userSelected:(id)sender {
    userButton.alpha = 1;
    driverButton.alpha = 0.5;
}

@end
