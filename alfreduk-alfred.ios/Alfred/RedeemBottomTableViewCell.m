//
//  RedeemBottomTableViewCell.m
//  Alfred
//
//  Created by Arjun Busani on 16/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "RedeemBottomTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation RedeemBottomTableViewCell
@synthesize redeemButton;
- (void)awakeFromNib {
    // Initialization code
    [[redeemButton layer] setBorderWidth:1.0f];
    [[redeemButton layer] setBorderColor:[UIColor blackColor].CGColor];
    

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)redeemAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForEnterPromoCode" object:nil];

}
@end
