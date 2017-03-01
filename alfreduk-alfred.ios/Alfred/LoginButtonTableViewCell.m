//
//  LoginButtonTableViewCell.m
//  Alfred
//
//  Created by Arjun Busani on 26/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "LoginButtonTableViewCell.h"

@implementation LoginButtonTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    /*
    [[self.registerButton layer] setBorderWidth:1.0f];
    [[self.registerButton layer] setBorderColor:[UIColor blackColor].CGColor];
    
    
    [[self.forgotPasswordButton layer] setBorderWidth:1.0f];
    [[self.forgotPasswordButton layer] setBorderColor:[UIColor blackColor].CGColor];
    */
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)passwordPush:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForPassword" object:nil];

}
- (IBAction)registerPush:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRegistration" object:nil];

}

@end
