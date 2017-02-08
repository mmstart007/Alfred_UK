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
@interface EditProfileTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emaiTextField;
@property (weak, nonatomic) IBOutlet UISwitch *femaleSwitch;

@end


@implementation EditProfileTableViewController
- (IBAction)cancelEdit:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}
- (IBAction)doneEdit:(id)sender {
    
    NSString * firstName = _firstNameTextField.text;
    NSString * lastName = _lastNameTextField.text;
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    NSString *emailAddress = _emaiTextField.text;
    
    NSNumber *isFemale = [NSNumber numberWithBool:_femaleSwitch.on];
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
    if(![emailAddress containsString:@"\@"]){
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



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [ _femaleSwitch setEnabled:    [[PFUser currentUser][@"Female"] boolValue] ];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
