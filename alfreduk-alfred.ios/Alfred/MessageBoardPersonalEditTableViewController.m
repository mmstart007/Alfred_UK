//
//  MessageBoardPersonalEditTableViewController.m
//  Alfred
//
//  Created by Arjun Busani on 27/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "MessageBoardPersonalEditTableViewController.h"
#import "SWRevealViewController.h"
#import "MessageBoardDriverDetailHeadTableViewCell.h"
#import "MessageBoardEditMessageTableViewCell.h"

@interface MessageBoardPersonalEditTableViewController ()

@end

@implementation MessageBoardPersonalEditTableViewController
@synthesize messageBoardId,subject,messageTextView,textFieldData,confirmEdit,isItDriver;
- (void)viewDidLoad {
    [super viewDidLoad];
    id desiredColor = [UIColor whiteColor];
    self.tableView.backgroundColor = desiredColor;
    self.tableView.backgroundView.backgroundColor = desiredColor;
    
    //  self.tableView.backgroundView=[[UIImageView alloc] initWithImage:
    //                              [UIImage imageNamed:@"message_bg"]];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    
    UIImage *image1 = [[UIImage imageNamed:@"menu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:image1
                                                                         style:UIBarButtonItemStylePlain target:self action:@selector(revealToggle:)];
    
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithTitle:@"BACK" style:UIBarButtonItemStylePlain target:self action:@selector(backView:)];
    
    
    
    SWRevealViewController *revealViewController = self.revealViewController;
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    self.navigationItem.rightBarButtonItem = rightButton;
    
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    
    [self.navigationController.navigationBar setTranslucent:YES];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    
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
    
    [textFieldData replaceObjectAtIndex:0 withObject:@"Message"];


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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section==0) {
        return 1;
    }
    if (section==1) {
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
    [cell.driverLabel setText:@"EDIT POST"];

    if ([indexPath section]==1) {
        static NSString *simpleTableIdentifier = @"MessageBoardEditMessageTableViewCell";
        MessageBoardEditMessageTableViewCell *cell = (MessageBoardEditMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageBoardEditMessageTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        [cell.subjectLabel setText:subject];
        
        messageTextView = cell.messageTextView;
        
        cell.messageTextView.delegate = self;
        cell.messageTextView.tag = 10;
        
        cell.messageTextView.text = [textFieldData objectAtIndex:0];
        
        
        if ([[textFieldData objectAtIndex:0] isEqualToString:@"Message"]) {
            cell.messageTextView.textColor = [UIColor lightGrayColor];
            
        }
        else{
            cell.messageTextView.textColor = [UIColor blackColor];
            
        }

        confirmEdit =   cell.editButton;
        [confirmEdit addTarget:self action:@selector(confirmEdit:) forControlEvents:UIControlEventTouchUpInside];
        
        

        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return cell;
}

-(void)confirmEdit:(id)sender{
    if (messageTextView.text.length==0 ) {
        
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
        
        [HUD showUIBlockingIndicatorWithText:@"Editing Post.."];
        
        
        
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *tokenID = [prefs stringForKey:@"token"];
            
            NSString *driverID = [prefs stringForKey:@"driverId"];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            NSString* whichID;
            
            if (isItDriver) {
                whichID = driverID;
            }
            else{
                whichID = tokenID;
            }
            

            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
            [manager.requestSerializer setValue:tokenID forHTTPHeaderField:@"tokenId"];
            
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            
            
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:tokenID,@"id",messageBoardId,@"messageBoardId",messageTextView.text,@"message",nil];
            NSString* URL = @"http://ec2-52-74-6-189.ap-southeast-1.compute.amazonaws.com:8080/editMessage";

            [manager POST:URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"Success: %@", responseObject);
                
                NSString* message =responseObject[@"message"];
                
                if ([message isEqualToString:@"Message edited successfully."]) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                [HUD hideUIBlockingIndicator];
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", [error localizedDescription]);
                [HUD hideUIBlockingIndicator];

            }];
            
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                
                
                
            });
        });
        
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    if (textView.tag == 10) {
        [textFieldData replaceObjectAtIndex:0 withObject:textView.text];
        
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([[textView text] isEqualToString:@"Message"]) {
        [textFieldData replaceObjectAtIndex:0 withObject:@""];
        textView.text = [textFieldData objectAtIndex:0];
        textView.textColor = [UIColor blackColor];
    }
    
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([[textView text] length] == 0) {
        [textFieldData replaceObjectAtIndex:0 withObject:@"Message"];
        textView.text = [textFieldData objectAtIndex:0];
        textView.textColor = [UIColor lightGrayColor];
        
    }
    return YES;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([indexPath section]==0) {
        return 105;
    }
    if ([indexPath section]==1) {
        return 180;
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
