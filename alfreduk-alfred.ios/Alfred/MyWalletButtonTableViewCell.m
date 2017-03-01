//
//  MyWalletButtonTableViewCell.m
//  Alfred
//
//  Created by Arjun Busani on 26/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "MyWalletButtonTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
@implementation MyWalletButtonTableViewCell
@synthesize myWalletButton;
- (void)awakeFromNib {
    [super awakeFromNib];
    [[myWalletButton layer] setBorderWidth:1.0f];
    [[myWalletButton layer] setBorderColor:[UIColor blackColor].CGColor];
    

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)addCard:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForAddCard" object:nil];

}

@end
