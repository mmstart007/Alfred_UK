//
//  MessageBoardUserJoinTableViewController.m
//  Alfred
//
//  Created by Arjun Busani on 06/04/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "MessageBoardUserJoinTableViewController.h"
#import "SWRevealViewController.h"
#import "MessageBoardDriverDetailHeadTableViewCell.h"
#import "MessageBoardNewMapTableViewCell.h"
#import "MessageBoardDriverJoinSeatsTableViewCell.h"
#import "MessageBoardDriverJoinBottomTableViewCell.h"

#import <Parse/Parse.h>


static int POST_SUCCESS= 122323;

@interface MessageBoardUserJoinTableViewController ()<UIAlertViewDelegate>

@end

@implementation MessageBoardUserJoinTableViewController
@synthesize confirmJoin,priceTextField,textFieldData;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    textFieldData = [[NSMutableArray alloc]init];
    for (int i=0; i<1; i++)
    {
        [textFieldData addObject:@""];
    }
    
    
    id desiredColor = [UIColor whiteColor];
    self.tableView.backgroundColor = desiredColor;
    self.tableView.backgroundView.backgroundColor = desiredColor;
    
    //  self.tableView.backgroundView=[[UIImageView alloc] initWithImage:
    //                              [UIImage imageNamed:@"message_bg"]];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)backView:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section==0) {
        return 1;
    }
    if (section==1) {
        return 1;
    }
    if (section==2) {
        return 1;
    }
    
    else
        return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"MessageBoardDriverDetailHeadTableViewCell";
    MessageBoardDriverDetailHeadTableViewCell *cell = (MessageBoardDriverDetailHeadTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageBoardDriverDetailHeadTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.driverLabel setText:@"BE THE ALFRED"];
    
    if ([indexPath section]==1) {
        static NSString *simpleTableIdentifier = @"MessageBoardDriverJoinSeatsTableViewCell";
        MessageBoardDriverJoinSeatsTableViewCell *cell = (MessageBoardDriverJoinSeatsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageBoardDriverJoinSeatsTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        priceTextField = cell.seatsTextField;
        cell.seatsTextField.delegate = self;
        cell.seatsTextField.tag = 10;
        cell.seatsTextField.text = [textFieldData objectAtIndex:0];
        [cell.numberOfSeatsLabel setText:@"Price per seat:"];
        
        return cell;
    }
    if ([indexPath section]==2) {
        static NSString *simpleTableIdentifier = @"MessageBoardDriverJoinBottomTableViewCell";
        MessageBoardDriverJoinBottomTableViewCell *cell = (MessageBoardDriverJoinBottomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageBoardDriverJoinBottomTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        confirmJoin =   cell.confirmButton;
        [confirmJoin addTarget:self action:@selector(confirmJoin:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        return cell;
    }
    
    
    
    
    
    return cell;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField.tag == 10) {
        [textFieldData replaceObjectAtIndex:0 withObject:textField.text];
        
    }
}

-(void)confirmJoin:(id)sender{
    if (priceTextField.text.length==0 ) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                 message:@"All fields required"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        //We add buttons to the alert controller by creating UIAlertActions:
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil]; //You can use a block here to handle a press on this button
        [alertController addAction:actionOk];
        [self presentViewController:alertController animated:YES completion:nil];
        
        
    }
    else{
        
        [HUD showUIBlockingIndicatorWithText:@"Requesting.."];
        
        //here post a be the alfred request and display info
        
        PFObject *takeRideRequest = [PFObject objectWithClassName:@"TakeRideRequest"];
        takeRideRequest[@"BoardMessage"] = _messageBoard;
        takeRideRequest[@"author"] = [PFUser currentUser];
        takeRideRequest[@"pricePerSeat"] = [NSNumber numberWithDouble:[priceTextField.text doubleValue]];
        [takeRideRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            
            if(succeeded){
                
                [_messageBoard addUniqueObjectsFromArray:@[takeRideRequest.objectId] forKey:@"driverOffers"];
                [_messageBoard saveEventually:^(BOOL succeeded, NSError * _Nullable error) {
                    [HUD hideUIBlockingIndicator];
                    if(succeeded){
                        
                        
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message posted sucessfully" message:@"The client has been informed that you are ready to take this ride, will be notified when he responds" delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil] ;
                        [alertView setTag: POST_SUCCESS];
                        [alertView show];
                        
                      
                    }else{
                        
                        
                        [[[UIAlertView alloc] initWithTitle:@"Failed to post message" message:@"Can post your response now, please try again later" delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil] show];
                    }
                }];
                
                
            }else{
                [HUD hideUIBlockingIndicator];
                [[[UIAlertView alloc] initWithTitle:@"Failed to post message" message:@"Can post your response now, please try again later" delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil] show];
                
                
            }
        }];
        
        
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([indexPath section]==0) {
        return 105;
    }
    
    if ([indexPath section]==1) {
        return 60;
    }
    if ([indexPath section]==2) {
        return 60;
    }
    
    else
        return 0;
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if(alertView.tag == POST_SUCCESS){
        [self.navigationController popViewControllerAnimated:YES];
    }

}
@end
