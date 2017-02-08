//
//  AddCardCardDetailsTableViewCell.m
//  Alfred
//
//  Created by Arjun Busani on 26/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "AddCardCardDetailsTableViewCell.h"

@implementation AddCardCardDetailsTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.cardNumberTextField.delegate = self;
    
}
- (BOOL)                textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
    
    // All digits entered
    if (range.location == 19) {
        return NO;
    }
    
    // Reject appending non-digit characters
    if (range.length == 0 &&
        ![[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[string characterAtIndex:0]]) {
        return NO;
    }
    
    // Auto-add hyphen before appending 4rd or 7th digit
    if (range.length == 0 &&
        (range.location == 4 || range.location == 9  || range.location == 14 )) {
        textField.text = [NSString stringWithFormat:@"%@-%@", textField.text, string];
        return NO;
    }
    
    // Delete hyphen when deleting its trailing digit
    if (range.length == 1 &&
        (range.location == 5 || range.location == 10 || range.location == 15))  {
        range.location--;
        range.length = 2;
        textField.text = [textField.text stringByReplacingCharactersInRange:range withString:@""];
        return NO;
    }
    
    return YES;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
