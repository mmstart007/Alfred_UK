//
//  PhoneVerifyTableViewController.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 10/18/15.
//  Copyright © 2015 A Ascendanet Sun. All rights reserved.
//

#import "PhoneVerifyTableViewController.h"
#import <SinchVerification/SinchVerification.h>
#import "HUD.h"
#import <Parse/Parse.h>

@interface PhoneVerifyTableViewController ()

- (IBAction)verify:(id)sender;
- (IBAction)resentCode:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeLabel;
@property (weak, nonatomic) IBOutlet UIButton *resentVerificationButton;
@end

@implementation PhoneVerifyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.resentVerificationButton.hidden = YES;
   self.title = @"Phone Verification";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)verify:(id)sender {
    
    [HUD showUIBlockingIndicatorWithText:@"Verifying.."];
    [self.verificationCodeLabel resignFirstResponder];
    
    [self.verification
     verifyCode:self.verificationCodeLabel.text
     completionHandler:^(BOOL success, NSError* error) {
         if (success) {
            
             NSLog(@"Verification succeeded");
             // Phone number was successfully verified, you should
             //probably notify your backend or use the callbacks to store that the phone is
             //verified.
             PFUser * user = [PFUser currentUser];
             user[@"PhoneVerified"] = @YES;
             user[@"Phone"] = self.phoneNumber;
             [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                 if(succeeded){
                      [HUD hideUIBlockingIndicator];
                     [self performSegueWithIdentifier:@"ConfirmationView" sender:self];
                    
                 }else{
                     //TODO: check for invalid season and logout
                     
                     
                     
                     
                     
                 }
                  [HUD hideUIBlockingIndicator];
             }];
             
         } else {
             
             // Ask user to re-attempt verification
             [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Invalid verification code." delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil]show];
              NSLog(@"Error");
              [HUD hideUIBlockingIndicator];
         }
        
     }];
}

- (IBAction)resentCode:(id)sender {
}
@end
