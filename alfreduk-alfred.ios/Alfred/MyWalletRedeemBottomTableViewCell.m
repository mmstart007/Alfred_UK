//
//  MyWalletRedeemBottomTableViewCell.m
//  Alfred
//
//  Created by Arjun Busani on 26/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "MyWalletRedeemBottomTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
@implementation MyWalletRedeemBottomTableViewCell
@synthesize redeemButton;
- (void)awakeFromNib {
    [[redeemButton layer] setBorderWidth:1.0f];
    [[redeemButton layer] setBorderColor:[UIColor blackColor].CGColor];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)redeemRewardsAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForRedeemRewardsPush" object:nil];

}
@end
