//
//  ExpiryAndCVVSplitCellTableViewCell.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 10/6/15.
//  Copyright © 2015 A Ascendanet Sun. All rights reserved.
//

#import "ExpiryAndCVVSplitCellTableViewCell.h"

@implementation ExpiryAndCVVSplitCellTableViewCell


- (void)awakeFromNib {
    
    [super awakeFromNib];
    // Initialization code
    self.leftTextField.delegate = self;
    self.rightTextField.delegate = self;
    
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    //reject non numbers
    
    // Reject appending non-digit characters
    if (range.length == 0 &&
        ![[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[string characterAtIndex:0]]) {
        return NO;
    }
    
    if(textField == self.leftTextField){
        
    }
    else{
        
        if(range.location == 3){
            return NO;
        }
    }
    
    
    return YES;
    
}

@end
