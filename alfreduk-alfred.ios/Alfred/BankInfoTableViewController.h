//
//  BankInfoTableViewController.h
//  Alfred
//
//  Created by Miguel Angel Carvajal on 2/21/16.
//  Copyright © 2016 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BankInfoTableViewController : UITableViewController <UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UITextField *sortCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *accountNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmAccountNumberTextField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;


- (IBAction)cancelAction:(id)sender;
- (IBAction)saveAction:(id)sender;

@end
