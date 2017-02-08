//
//  MyWalletRedeemBottomTableViewCell.h
//  Alfred
//
//  Created by Arjun Busani on 26/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyWalletRedeemBottomTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *redeemButton;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
- (IBAction)redeemRewardsAction:(id)sender;

@end
