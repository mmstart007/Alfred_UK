//
//  ForgotPassEmailTableViewController.m
//  Alfred
//
//  Created by Arjun Busani on 19/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "ForgotPassEmailTableViewController.h"
#import "LogoTableViewCell.h"
#import "RegisterTextTableViewCell.h"
#import "RegisterButtonTableViewCell.h"
#import "RegisterFieldTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "ForgotPassCodeViewController.h"
@interface ForgotPassEmailTableViewController ()

@end

@implementation ForgotPassEmailTableViewController
@synthesize emailLabel,successData,validations,submitButton;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // hide navigation bar
    [self.navigationController.navigationBar setTranslucent:YES];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
        
    self.navigationController.navigationBar.topItem.title = @"";
    
    // add cancel button
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                    style:UIBarButtonItemStyleDone target:self action:@selector(cancelPage:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];

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
        return 1;
    }
    else
        return 3;
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
        return 58;
    }
    if ([indexPath section]==2) {
        
        return 45;
    }
    else if ([indexPath section]==3){
        if (indexPath.row==0) {
            return 10;
        }
        else if (indexPath.row==1){
            return 45;
        }
        else
            return 40;
    }
    return 45;
    
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
        
        if (indexPath.row==0) {
            [cell.nameTextLabel setText:@"Email:"];
            
            emailLabel = cell.registerTextField;
            cell.registerTextField.delegate = self;
            cell.registerTextField.tag = 10;
            cell.registerTextField.keyboardType = UIKeyboardTypeEmailAddress;

        }
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        cell.backgroundColor = [UIColor clearColor];

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
        
        if (indexPath.row==0 || indexPath.row==2) {
            cell.selectionStyle = UITableViewCellEditingStyleNone;

            cell.submitButton.hidden = YES;
        }
        
        if (indexPath.row==2) {
            cell.validationsLabel.text = validations;

        }

        if (indexPath.row==1) {
            //cell.submitButton.hidden = YES;
            submitButton = cell.submitButton;
            cell.selectionStyle = UITableViewCellEditingStyleNone;
            [submitButton addTarget:self action:@selector(subCheck) forControlEvents:UIControlEventTouchUpInside];

            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            

            
        }
        
        cell.backgroundColor = [UIColor clearColor];

        return cell;
    }
    //cell.logoImageView.hidden = YES;
    cell.selectionStyle = UITableViewCellEditingStyleNone;
    
    return cell;
}


//check if the field are filled and log in
-(void)subCheck{
    
    if (emailLabel.text.length==0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Please enter your email"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

    }
    else{
        
        [HUD showUIBlockingIndicatorWithText:@"Please wait.."];
        
        
        
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            
            
            
            NSString* URL_SIGNIN = [NSString stringWithFormat: @"http://ec2-52-74-6-189.ap-southeast-1.compute.amazonaws.com:8080/forgotPassword?email=%@",emailLabel.text];
            
            [manager POST:URL_SIGNIN parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                successData =responseObject;

                NSLog(@"Success: %@", successData);
                
                NSString* message = successData[@"message"];
                

                if ([message isEqualToString:@"An email has been sent to your email address."]) {
                    [self performSegueWithIdentifier:@"RequestCodePush" sender:self];

                }
                else{
                    validations = message;
                    [self.tableView reloadData];

                }
                
                [HUD hideUIBlockingIndicator];

                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error while sending data"
                                                                    message:@"Sorry, try again."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                [alertView show];
                
                NSLog(@"Error: %@", [error localizedDescription]);
                [HUD hideUIBlockingIndicator];
               

            }];

                       dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                
                
                
            });
        });

        
        
      }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"RequestCodePush"])
    {
        
        
        ForgotPassCodeViewController *detailViewController = [segue destinationViewController];
        detailViewController.email = emailLabel.text;
        
    }
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
