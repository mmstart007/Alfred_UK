//
//  WithdrawalView.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 2/20/16.
//  Copyright © 2016 A Ascendanet Sun. All rights reserved.
//

#import "WithdrawalView.h"

@implementation WithdrawalView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)requestWitdrawal:(UIButton *)sender {
    
    NSNumber * amount =[NSNumber numberWithDouble: [self.amountTextField.text doubleValue]];
    
    [self.delegate withdrawalView:self didRequestWitdrawalWithAmount:amount];
    
    
}

@end
