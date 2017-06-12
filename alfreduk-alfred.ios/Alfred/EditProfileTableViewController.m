//
//  EditProfileTableViewController.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 11/4/15.
//  Copyright © 2015 A Ascendanet Sun. All rights reserved.
//

#import "EditProfileTableViewController.h"
#import <Parse/Parse.h>
#import "HUD.h"

@interface EditProfileTableViewController () {
    UIBarButtonItem *doneButton;
}

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emaiTextField;
@property (weak, nonatomic) IBOutlet UISwitch *femaleSwitch;


@end



@implementation EditProfileTableViewController

@synthesize firstNameTextField,lastNameTextField,emaiTextField,femaleSwitch;


- (IBAction)cancelEdit:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneEdit:(id)sender {
    
    NSString * firstName = firstNameTextField.text;
    NSString * lastName = lastNameTextField.text;
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    NSString *emailAddress = emaiTextField.text;
    NSNumber *isFemale = [NSNumber numberWithBool:femaleSwitch.isOn];

    if(firstName.length == 0){
        //shake view
        return ;
    }
    if(lastName.length == 0){
        //shake view
        return;
    }
    if(emailAddress.length == 0){
        //shake view
        return;
    }
    //TODO: improve email validation here
    if(![emailAddress containsString:@"@"]) {
        //shake view
        return;
    }
    
    PFUser *user = [PFUser currentUser];
    user[@"FirstName"] = firstName;
    user[@"LastName"] = lastName;
    user[@"FullName"] = fullName;
    user[@"Female"] = isFemale;
    [HUD showUIBlockingIndicatorWithText:@"Updating..."];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [HUD hideUIBlockingIndicator];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)switchAction:(id)sender {
    self.navigationItem.rightBarButtonItem = doneButton;
    UISwitch *s = (UISwitch*)sender;
    //Change value on second switch
    [femaleSwitch setOn:!s.isOn];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    PFUser *currentUser = [PFUser currentUser];
    firstNameTextField.text = currentUser[@"FirstName"];
    lastNameTextField.text  = currentUser[@"LastName"];
    emaiTextField.text = currentUser[@"email"];
    BOOL gender = [currentUser[@"Female"] boolValue];
    if (gender) {
        [femaleSwitch setOn:YES];
    } else {
        [femaleSwitch setOn:NO];
    }
    doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneEdit:)];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextField Delegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.navigationItem.rightBarButtonItem = doneButton;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == firstNameTextField) {
        [lastNameTextField becomeFirstResponder];
    } else if (textField == lastNameTextField) {
        [emaiTextField becomeFirstResponder];
    } else if (textField == emaiTextField) {
        [emaiTextField resignFirstResponder];
    }
    return YES;
}


/*
// Override to support conditional editing of the table view.

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
