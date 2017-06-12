//
//  BankInfoTableViewController.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 2/21/16.
//  Copyright © 2016 A Ascendanet Sun. All rights reserved.
//

#import "BankInfoTableViewController.h"

@interface BankInfoTableViewController ()

@end

@implementation BankInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveAction:(id)sender {
    
    [self.errorLabel setText:@""];
    
    [self.sortCodeTextField resignFirstResponder];
    [self.accountNumberTextField resignFirstResponder];
    [self.confirmAccountNumberTextField resignFirstResponder];
    
    if(self.sortCodeTextField.text.length == 0){
        [self.errorLabel setText:@"Sort code is required."];
        return;
        
    }else if(self.accountNumberTextField.text.length ==0){
        [self.errorLabel setText:@"Account number is required."];
        return;
    }else if(self.confirmAccountNumberTextField.text.length == 0){
        [self.errorLabel setText:@"Confirm account Number is required."];
        return;
        
    } else if (![self.accountNumberTextField.text isEqualToString:self.confirmAccountNumberTextField.text]) {
        [self.errorLabel setText:@"Account numbers don't match!"];
        return;
    }
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.sortCodeTextField) {
        [self.accountNumberTextField becomeFirstResponder];
    } else if (textField == self.accountNumberTextField) {
        [self.confirmAccountNumberTextField becomeFirstResponder];
    } else if (textField == self.confirmAccountNumberTextField) {
        [self.confirmAccountNumberTextField resignFirstResponder];
    }
    return YES;
}



@end
