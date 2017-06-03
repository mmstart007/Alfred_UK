//
//  AddBalanceView.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 10/11/15.
//  Copyright © 2015 A Ascendanet Sun. All rights reserved.
//

#import "AddBalanceView.h"

@implementation AddBalanceView
@synthesize delegate;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self endEditing:YES];
    
}

- (void) shake {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 0.6;
    animation.values = @[ @(-20), @(20), @(-20), @(20), @(-10), @(10), @(-5), @(5), @(0) ];
    [self.layer addAnimation:animation forKey:@"shake"];
}

- (IBAction)addBalance:(id)sender {
    
    [self.amountTextField resignFirstResponder];
    if(self.amountTextField.text.length == 0) {
        [self shake];
    } else if([self.amountTextField.text doubleValue] >500) {
        [self shake];
    } else {
        [delegate addBalanceView:self didAddedBalance:[self.amountTextField.text doubleValue]];
    }
}

-(void )setCardString:(NSString *)cardString{
    [self.cardTextField setText:cardString];
}

- (IBAction)cancel:(id)sender {
    [delegate addBalanceViewCanceled:self];
}




@end
