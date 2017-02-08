//
//  RedeemBottomTableViewCell.h
//  Alfred
//
//  Created by Arjun Busani on 16/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RedeemBottomTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *redeemButton;
- (IBAction)redeemAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

@end
