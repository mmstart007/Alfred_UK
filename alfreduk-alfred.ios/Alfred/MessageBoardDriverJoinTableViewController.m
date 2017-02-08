//
//  MessageBoardDriverJoinTableViewController.m
//  Alfred
//
//  Created by Arjun Busani on 27/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "MessageBoardDriverJoinTableViewController.h"
#import "SWRevealViewController.h"
#import "MessageBoardDriverDetailHeadTableViewCell.h"
#import "MessageBoardNewMapTableViewCell.h"
#import "MessageBoardDriverJoinSeatsTableViewCell.h"
#import "MessageBoardDriverJoinBottomTableViewCell.h"

@interface MessageBoardDriverJoinTableViewController () <UIAlertViewDelegate>

@end

@implementation MessageBoardDriverJoinTableViewController
@synthesize pickLat,pickLong,dropLat,dropLong,pickupAddress,dropoffAddress,city,pickupButton,dropoffButton,confirmJoin,pickLocationViewController,seatsTextField,textFieldData,messageBoardId;
@synthesize message;
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    isPickupChecked = false;
    isDropoffChecked = false;
    
    pickupAddress = @"Pickup Location";
    dropoffAddress = @"Dropoff Location";

    
    id desiredColor = [UIColor whiteColor];
    
    self.tableView.backgroundColor = desiredColor;
    self.tableView.backgroundView.backgroundColor = desiredColor;
    
    //  self.tableView.backgroundView=[[UIImageView alloc] initWithImage:
    //                              [UIImage imageNamed:@"message_bg"]];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForLocation:) name:@"didRequestForLocation" object:nil];

    
    UIImage *drawerImage = [[UIImage imageNamed:@"menu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:drawerImage
                                                                         style:UIBarButtonItemStylePlain target:self action:@selector(revealToggle:)];
    
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithTitle:@"BACK" style:UIBarButtonItemStylePlain target:self action:@selector(backView:)];
    
    
    
    SWRevealViewController *revealViewController = self.revealViewController;

    self.navigationItem.rightBarButtonItem = nil;
    
    

    
    


    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
   
    
    
    if ( revealViewController ){
        [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
        
        
        [self.navigationItem.leftBarButtonItem setTarget:self.revealViewController];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    textFieldData = [[NSMutableArray alloc]init];
    
    for (int i=0; i<1; i++)
    {
        [textFieldData addObject:@""];
    }
    
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    int index  = buttonIndex;
    [self.navigationController popViewControllerAnimated:YES];
    

}
- (void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForLocation" object:nil];
    
    
    
}

-(void)didRequestForLocation:(NSNotification *)notification{
    
    NSMutableArray* locationArray = [notification object];
    
    if (isItPick) {
        pickLat = [locationArray[0] doubleValue];
        pickLong = [locationArray[1] doubleValue];
        city = locationArray[2];
        pickupAddress = locationArray[3];
        [pickupButton setTitle:pickupAddress forState:UIControlStateNormal];
        isPickupChecked = YES;
        
    }
    else{
        dropLat = [locationArray[0] doubleValue];
        dropLong = [locationArray[1] doubleValue];
        dropoffAddress = locationArray[3];
        [dropoffButton setTitle:dropoffAddress forState:UIControlStateNormal];
        isDropoffChecked = YES;
        
    }
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
    return 4;
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
    if (section==3) {
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
    [cell.driverLabel setText:@"JOIN ALFRED"];
    
    if ([indexPath section]==1) {
        static NSString *simpleTableIdentifier = @"MessageBoardNewMapTableViewCell";
        MessageBoardNewMapTableViewCell *cell = (MessageBoardNewMapTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageBoardNewMapTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        pickupButton = cell.pickupButton;
        [pickupButton setTitle:pickupAddress forState:UIControlStateNormal];
        
        [pickupButton addTarget:self action:@selector(pickupButton:) forControlEvents:UIControlEventTouchUpInside];
        dropoffButton = cell.dropoffButton;
        [dropoffButton setTitle:dropoffAddress forState:UIControlStateNormal];
        
        [dropoffButton addTarget:self action:@selector(dropoffButton:) forControlEvents:UIControlEventTouchUpInside];

        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell;
    }
    if ([indexPath section]==2) {
        static NSString *simpleTableIdentifier = @"MessageBoardDriverJoinSeatsTableViewCell";
        MessageBoardDriverJoinSeatsTableViewCell *cell = (MessageBoardDriverJoinSeatsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageBoardDriverJoinSeatsTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        seatsTextField = cell.seatsTextField;
        cell.seatsTextField.delegate = self;
        cell.seatsTextField.tag = 10;
        cell.seatsTextField.text = [textFieldData objectAtIndex:0];

        
        return cell;
    }
    if ([indexPath section]==3) {
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
    
    if (seatsTextField.text.length==0 || !isDropoffChecked || !isPickupChecked) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error "
                                                                                 message:@"Please fill all the fields before you can request to join this ride."
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        //We add buttons to the alert controller by creating UIAlertActions:
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Accept"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil]; //You can use a block here to handle a press on this button
        [alertController addAction:actionOk];
        [self presentViewController:alertController animated:YES completion:nil];

        
    }
    else{
        
        [HUD showUIBlockingIndicatorWithText:@"Requesting..."];
        
        
#warning what should happen here,  I dont know
                    int seats = [seatsTextField.text intValue];
        
        //
        PFObject *rideJoinRequest  = [PFObject objectWithClassName:@"JoinRideRequest"];
        rideJoinRequest[@"boardMessage"] = self.message;
        rideJoinRequest[@"pickLat"] = [NSNumber numberWithDouble:pickLat];
        rideJoinRequest[@"pickLong"] =[NSNumber numberWithDouble: pickLong];
        rideJoinRequest[@"dropLat"] = [NSNumber numberWithDouble:dropLat];
        rideJoinRequest[@"dropLong"] = [ NSNumber numberWithDouble:dropLong];
        rideJoinRequest[@"pickupAddress"] = pickupAddress;
        rideJoinRequest[@"dropoffAddress"] = dropoffAddress;
        rideJoinRequest[@"seats"] = [NSNumber numberWithInt:seats];
        rideJoinRequest[@"author"] = [PFUser currentUser];
        rideJoinRequest[@"status"] = @"waiting";
        
        [rideJoinRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                 [HUD hideUIBlockingIndicator];
            if(succeeded){
                [[[UIAlertView alloc] initWithTitle:@"Request saved sucessfully!" message:@"Your request to join this ride has been sucefully posted, you will be notified when the Alfred responds to it." delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil] show];
                
                //send push to Alfred
                
                
            }
            else{
                [[[UIAlertView alloc] initWithTitle:@"Error posting request" message:@"Can post your request right now, please try again later" delegate:nil cancelButtonTitle:@"Accept" otherButtonTitles:nil] show];
            }
            
            
        }];

        
        
       
        
    }
}

-(void)dropoffButton:(id)sender{

  
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    
    pickLocationViewController = [storyboard instantiateViewControllerWithIdentifier:@"PickLocationView"];
    
    
    pickLocationViewController.isPickup = NO;
    
    //    pickLocationViewController.isPickup = NO;
    isItPick = NO;
    
    [self.navigationController pushViewController:pickLocationViewController animated:YES];
    

    
    
}

-(void)pickupButton:(id)sender{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    
    pickLocationViewController = [storyboard instantiateViewControllerWithIdentifier:@"PickLocationView"];
    
    
    pickLocationViewController.isPickup = YES;
    
    //    pickLocationViewController.isPickup = NO;
    isItPick = YES;
    
    [self.navigationController pushViewController:pickLocationViewController animated:YES];
    

    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([indexPath section]==0) {
        return 105;
    }
    if ([indexPath section]==1) {
        return 130;
    }
    if ([indexPath section]==2) {
        return 60;
    }
    if ([indexPath section]==3) {
        return 60;
    }
    
    else
        return 0;
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
