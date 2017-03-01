//
//  RegisterTableViewController.m
//  Alfred
//
//  Created by Arjun Busani on 19/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "RegisterTableViewController.h"
#import "LogoTableViewCell.h"
#import "RegisterTextTableViewCell.h"
#import "RegisterButtonTableViewCell.h"
#import "RegisterFieldTableViewCell.h"
#import "JSONHelper.h"
#import "HUD.h"
#import "ResendEmailViewController.h"
#include <Parse/Parse.h>
#import "AlfredUser.h"


@interface RegisterTableViewController ()

@end

@implementation RegisterTableViewController
@synthesize firstNameLabel,lastNameLabel,emailLabel,passwordLabel,retypePasswordLabel,phoneLabel,textFieldData,successRegistration,validations,useridForNext,submitButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTranslucent:YES];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    self.navigationController.navigationBar.topItem.title = @"";

    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                    style:UIBarButtonItemStyleDone target:self action:@selector(cancelPage:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];

    
   // self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alfred bg"]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    textFieldData = [[NSMutableArray alloc]init];
    for (int i=0; i<6; i++)
    {
        [textFieldData addObject:@""];
    }
    

    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)cancelPage:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section==0) {
        return 2;
    }
    else if (section==1){
        return 1;
    }
    else if (section==2){
        return 6;
    }
    else
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"LogoTableViewCell";
    LogoTableViewCell *cell = (LogoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LogoTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    if ([indexPath section]==0) {
        if (indexPath.row==0) {
            cell.logoImageView.hidden = YES;
            
        }
        
        if (indexPath.row==1) {
            cell.logoImageView.hidden = NO;

        }
    }
    cell.backgroundColor = [UIColor clearColor];

    if ([indexPath section]==1) {
        static NSString *simpleTableIdentifier = @"RegisterTextTableViewCell";
        RegisterTextTableViewCell *cell = (RegisterTextTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RegisterTextTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        cell.backgroundColor = [UIColor clearColor];

        return cell;
    }
    
    if ([indexPath section]==2) {
        static NSString *simpleTableIdentifier = @"RegisterFieldTableViewCell";
        RegisterFieldTableViewCell *cell = (RegisterFieldTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RegisterFieldTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.backgroundColor = [UIColor clearColor];

        if (indexPath.row==0) {
            [cell.nameTextLabel setText:@"First Name:"];
            
            firstNameLabel = cell.registerTextField;
            cell.registerTextField.delegate = self;
            cell.registerTextField.tag = 10;
            cell.registerTextField.text = [textFieldData objectAtIndex:0];

        }
        if (indexPath.row==1) {
            [cell.nameTextLabel setText:@"Last Name:"];
            
            lastNameLabel = cell.registerTextField;
            cell.registerTextField.delegate = self;
            cell.registerTextField.tag = 11;
            cell.registerTextField.text = [textFieldData objectAtIndex:1];

        }
        if (indexPath.row==2) {
            [cell.nameTextLabel setText:@"Mobile Number:"];
            
            phoneLabel = cell.registerTextField;
            cell.registerTextField.delegate = self;
            cell.registerTextField.tag = 12;
            cell.registerTextField.text = [textFieldData objectAtIndex:2];
            cell.registerTextField.keyboardType = UIKeyboardTypePhonePad;

        }
        if (indexPath.row==3) {
            [cell.nameTextLabel setText:@"Email:"];
            
            emailLabel = cell.registerTextField;
            cell.registerTextField.delegate = self;
            cell.registerTextField.tag = 13;
            cell.registerTextField.text = [textFieldData objectAtIndex:3];
            cell.registerTextField.keyboardType = UIKeyboardTypeEmailAddress;

        }
        if (indexPath.row==4) {
            [cell.nameTextLabel setText:@"Password:"];
            cell.registerTextField.secureTextEntry = YES;

            passwordLabel = cell.registerTextField;
            cell.registerTextField.delegate = self;
            cell.registerTextField.tag = 14;
            cell.registerTextField.text = [textFieldData objectAtIndex:4];

        }
        if (indexPath.row==5) {
            [cell.nameTextLabel setText:@"Retype Password:"];
            cell.registerTextField.secureTextEntry = YES;
            
            retypePasswordLabel = cell.registerTextField;
            cell.registerTextField.delegate = self;
            cell.registerTextField.tag = 15;
            cell.registerTextField.text = [textFieldData objectAtIndex:5];
        }
        cell.selectionStyle = UITableViewCellEditingStyleNone;

        return cell;

    }
    
    if ([indexPath section]==3) {
        static NSString *simpleTableIdentifier = @"RegisterButtonTableViewCell";
        RegisterButtonTableViewCell *cell = (RegisterButtonTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RegisterButtonTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.backgroundColor = [UIColor clearColor];

        if (indexPath.row==0 || indexPath.row==2) {
            cell.submitButton.hidden = YES;
        }
        
        if (indexPath.row==2){
            cell.validationsLabel.text = validations;
            
                       
        }
        
        if (indexPath.row==1) {
           // cell.submitButton.hidden = YES;
            
            cell.selectionStyle = UITableViewCellEditingStyleNone;
            submitButton = cell.submitButton;
            
            [submitButton addTarget:self action:@selector(subCheck) forControlEvents:UIControlEventTouchUpInside];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            
            
        }

        cell.selectionStyle = UITableViewCellEditingStyleNone;

        return cell;
    }
    //cell.logoImageView.hidden = YES;
    cell.selectionStyle = UITableViewCellEditingStyleNone;

    return cell;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField.tag == 10) {
        [textFieldData replaceObjectAtIndex:0 withObject:textField.text];
        
    }
    if (textField.tag == 11) {
        [textFieldData replaceObjectAtIndex:1 withObject:textField.text];
        
    }
    if (textField.tag == 12) {
        [textFieldData replaceObjectAtIndex:2 withObject:textField.text];
        
    }
    if (textField.tag == 13) {
        [textFieldData replaceObjectAtIndex:3 withObject:textField.text];
        
    }
    if (textField.tag == 14) {
        [textFieldData replaceObjectAtIndex:4 withObject:textField.text];
        
    }
    if (textField.tag == 15) {
        [textFieldData replaceObjectAtIndex:5 withObject:textField.text];
        
    }
    
   
    
}

-(BOOL)checkAlphas:(NSString*)string{
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"];
    set = [set invertedSet];
    
    
    NSRange r = [string rangeOfCharacterFromSet:set];
    
    if (r.location != NSNotFound) {
        return NO;
    }
    else{
        return YES;
    }
}

-(BOOL)checkNumbers:(NSString*)string{
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
    set = [set invertedSet];
    
    
    NSRange r = [string rangeOfCharacterFromSet:set];
    
    if (r.location != NSNotFound) {
        return NO;
    }
    else{
        return YES;
    }
}

-(BOOL)checkEmail:(NSString*)string{
    
    if ([string rangeOfString:@"@"].location == NSNotFound) {
        return NO;
    } else {
        return YES;
    }
    
    
}

-(BOOL)checkBasicValidations{
    
    if (firstNameLabel.text.length<2) {
        validations = @"First Name must have at least 2 characters";
        [self.tableView reloadData];
        return NO;
    }
    
    else if (![self checkAlphas:firstNameLabel.text]){
        validations = @"First name contains illegal characters";
        [self.tableView reloadData];

        return NO;
    }
    
    else if (lastNameLabel.text.length<2) {
        validations = @"Last Name must have atleast 2 characters";
        [self.tableView reloadData];

        return NO;

    }
    
    
    else if (![self checkAlphas:lastNameLabel.text]){
        validations = @"Last name contains illegal characters";
        [self.tableView reloadData];
        
        return NO;
    }
    
    
    else if (phoneLabel.text.length<10||phoneLabel.text.length>15) {
        validations = @"Phone number must be between 10 and 15 numbers";
        [self.tableView reloadData];

        return NO;

    }
    else if (![self checkNumbers:phoneLabel.text]){
        validations = @"Phone number contains illegal characters";
        [self.tableView reloadData];
        
        return NO;
    }
    
    else if (![self checkEmail:emailLabel.text]){
        validations = @"Please enter a valid email id";
        [self.tableView reloadData];
        
        return NO;
    }
    
    else if (passwordLabel.text.length<5||retypePasswordLabel.text.length<5) {
        validations = @"Password must have minimum 5 characters";
        [self.tableView reloadData];

        return NO;

    }
    else{
        validations = @"";
        [self.tableView reloadData];

    return YES;
    }
}

-(BOOL) isMailAvailable:(NSString*)email{

    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"Email" equalTo:email];
    

    NSArray *objects = [query findObjects];
    return objects.count == 0;
}



-(void)subCheck{
    
    
    if (firstNameLabel.text.length==0 ||
        lastNameLabel.text.length ==0 ||
        phoneLabel.text.length==0     ||
        emailLabel.text.length==0     ||
        passwordLabel.text.length==0  ||
        retypePasswordLabel.text.length==0) {
    
        
        
        NSString *messages = @"All the fields are required for registration.";
        
        
        validations = messages;
        [self.tableView reloadData];
        
    }
    
    
    else if (![passwordLabel.text isEqualToString:retypePasswordLabel.text]){
   
        
        
        NSString *messages = @"Password do not match.";
        
        
        validations = messages;
        [self.tableView reloadData];
        

    }
    
    else {
        
        
        
        if ([self checkBasicValidations]) {
          
            [HUD showUIBlockingIndicatorWithText:@"Registering ..."];
            PFUser *user = [PFUser user];
            user.username = emailLabel.text;
            
            user.password = passwordLabel.text;
            user.email = emailLabel.text;
            user[@"FullName"] =   [NSString stringWithFormat:@"%@ %@",
                                             [firstNameLabel.text capitalizedString],
                                             [lastNameLabel.text capitalizedString]];

            
            
            // other fields can be set just like with PFObject
            user[@"Phone"] = phoneLabel.text;
            user[@"PromoCode"] = @1234;
            user[@"UserMode"] = @YES;
            user[@"EnabledAsDriver"] = @NO;
            user[@"Rating"] = @0.0;
            user[@"Balance"] = @0.0;
            user[@"Email"] = emailLabel.text;
            user[@"location"] = [PFGeoPoint geoPointWithLatitude:0 longitude:0];
            user[@"locationAddress"] = @"Undetermined";
            
            
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {   // Hooray! Let them use the app now.
                    //generate wallet
                    
                    PFObject *userRating  = [PFObject objectWithClassName:@"UserRating"];
                    userRating[@"rating"]= @0.0;
                    userRating[@"rideCount"] = @0;
                    userRating[@"user"]= user;
                    [userRating saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if(succeeded){
                            user[@"userRating"] = userRating;
                            [user saveEventually];
                        }
                    }];
                    PFObject *driverRating  = [PFObject objectWithClassName:@"DriverRating"];
                    driverRating[@"rating"]= @0.0;
                    driverRating[@"rideCount"] = @0;
                    driverRating[@"user"]= user;
                    [driverRating saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if(succeeded){
                            user[@"driverRating"] = driverRating;
                            [user saveEventually];
                        }
                    }];
                    
                    
                    
                    
                    PFInstallation *installation = [PFInstallation currentInstallation];
                    installation[@"user"] = [PFUser currentUser];
                    
                    [installation saveInBackground];
                    
                    
                    //[self generateWallet];
                    [self performSegueWithIdentifier:@"ResendPassPush" sender:self];
                    
                } else {
                    
                    if([error code] == kPFErrorUsernameTaken){
                        [[[UIAlertView alloc] initWithTitle:@"Registration failed" message:@"Email is already in use, try another mail or log in" delegate:nil cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil]show ];
                    
                    }
                    else if([error code] == kPFErrorConnectionFailed){
                        
                        [[[UIAlertView alloc] initWithTitle:@"Registration failed" message:@"Check your network connection and try again." delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil] show];
                    
                    }
                    //NSString *errorString = [error userInfo][@"error"];   // Show the errorString somewhere and let the user try again.
                    
                }
                [HUD hideUIBlockingIndicator];
            }];
            
           
            
            
            //generate promo code fron stripe
            
           
            
            //first check is user exist
        }
}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ResendPassPush"])
    {
        
        
        ResendEmailViewController *detailViewController = [segue destinationViewController];
        detailViewController.firstName = [PFUser currentUser][@"FullName"];
        //this is email
        detailViewController.userid =[PFUser currentUser][@"Email"];

    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([indexPath section]==0) {
        if (indexPath.row==0) {
            return 10;
        }
        else
        return 97;
        
    }
    if ([indexPath section]==1) {
        return 98;
    }
    if ([indexPath section]==2) {
       
        return 95;
    }
    else if ([indexPath section]==3){
        if (indexPath.row==0) {
            return 90;
        }
        else if (indexPath.row==1){
            return 95;
        }
        else
            return 90;
    }
    return 95;
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UIView * txt in self.view.subviews){
        if ([txt isKindOfClass:[UITextField class]] && [txt isFirstResponder]) {
            [txt resignFirstResponder];
        }
    }
    
    
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

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

@end
