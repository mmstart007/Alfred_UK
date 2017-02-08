//
//  MessageBoardDriverDetailTableViewController.m
//  Alfred
//
//  Created by Arjun Busani on 26/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "MessageBoardDriverDetailTableViewController.h"
#import "SWRevealViewController.h"
#import "MessageBoardDriverDetailPostTableViewCell.h"
#import "MessageBoardDriverDetailHeadTableViewCell.h"
#import "MessageBoardDriverDetailUserTableViewCell.h"
#import "MessageBoardBlankTableViewCell.h"
#import "MessageBoardDriverJoinTableViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Parse/Parse.h>


//this is show from message board when u are in user mode and
//viewing only your messages

@interface MessageBoardDriverDetailTableViewController ()

@end

@implementation MessageBoardDriverDetailTableViewController
@synthesize selectedMessage,driverMessageRequests;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    driverMessageRequests = [[NSArray alloc] init];
    driverMessageRequests = selectedMessage[@"driverMessageRequests"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForJoinAlfred:) name:@"didRequestForJoinAlfred" object:nil];
    
    id desiredColor = [UIColor whiteColor];
    self.tableView.backgroundColor = desiredColor;
    self.tableView.backgroundView.backgroundColor = desiredColor;
    
    //  self.tableView.backgroundView=[[UIImageView alloc] initWithImage:
    //                              [UIImage imageNamed:@"message_bg"]];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navigationItem.title = @"Driver Message";
    
 

}
-(void)viewDidAppear:(BOOL)animated{


}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    
    

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForJoinAlfred" object:nil];
    
}


-(void)didRequestForJoinAlfred:(id)sender{
    
    [self performSegueWithIdentifier:@"ShowDriverJoin" sender:self];
}

-(void)backView:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 5;
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
        return [driverMessageRequests count];
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
    
    if ([indexPath section]==1) {
        
        static NSString *simpleTableIdentifier = @"MessageBoardDriverDetailPostTableViewCell";
        MessageBoardDriverDetailPostTableViewCell *cell = (MessageBoardDriverDetailPostTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageBoardDriverDetailPostTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        
        CGFloat widFloat = 0;
        
        if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ){
            
            CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
            CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
            if( screenHeight < screenWidth ){
                screenHeight = screenWidth;
            }
            
            if( screenHeight > 480 && screenHeight < 667 ){
                widFloat = -40.0f;
                
            } else if ( screenHeight > 480 && screenHeight < 736 ){
                widFloat = 20.0f;
            } else if ( screenHeight > 480 ){
                widFloat = 20.0f;
            } else {
                widFloat = -40.0f;
                
                
            }
        }
        else{
            widFloat = 410.0f;
            
        }
        
        if (indexPath.row == 0) {
            UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(20.0f, 0, cell.bounds.size.width+widFloat, 0.5f)];
            topLineView.backgroundColor = [UIColor grayColor];
            [cell.contentView addSubview:topLineView];
        }
        
        UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(20.0f, 450.0f, cell.bounds.size.width+widFloat, 0.5f)];
        bottomLineView.backgroundColor = [UIColor grayColor];
        [cell.contentView addSubview:bottomLineView];

        NSDate *date = selectedMessage[@"date"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"hh:mm MMM dd, yyyy"];
        NSString* rideTime = [formatter stringFromDate:date];
        
        
        int   seats = [ selectedMessage[@"seats"] intValue];
        NSString* dropAddress = selectedMessage[@"dropoffAddress"];
        NSString* originAddress = selectedMessage[@"pickupAddress"];
        double pricePerSeat = [selectedMessage[@"pricePerSeat"] doubleValue];
        NSString* title = selectedMessage[@"title"];
        
        NSString* message = selectedMessage[@"desc"];
        
        BOOL femaleOnly = [selectedMessage[@"femaleOnly"] boolValue];
        

        
        //user data
        PFUser * user= selectedMessage[@"author"];
        assert(user != nil);
        NSString* mobile = user[@"Phone"];
        

        PFObject *driverRating = user[@"driverRating"];
        double rating = [driverRating[@"rating"] doubleValue];
        
        NSString* userName = [NSString stringWithFormat:@"%@ %c.",
                              user[@"FirstName"],
                              [ (NSString*)user[@"LastName"] characterAtIndex:0]];
                              
        NSString* pic = user[@"ProfilePicUrl"];
        
        
        if (![pic isKindOfClass:[NSNull class]]) {
            
            
            [cell.picImageView sd_setImageWithURL:[NSURL URLWithString:pic] placeholderImage:[UIImage imageNamed:@"blank profile"]];
        }
        cell.picImageView.layer.cornerRadius = cell.picImageView.frame.size.height /2;
        cell.picImageView.layer.masksToBounds = YES;
        cell.picImageView.layer.borderWidth = 0;
        [cell.nameLabel setText:[NSString stringWithFormat:@"%@",userName]];

        
        
        [cell.cellLabel setText:@""]; //this is a hack for now
        
        
        [cell.ratingLabel setText:[NSString stringWithFormat:@"Rating: %.2f",rating]];

        [cell.titleLabel setText:title];
        [cell.pickupLabel setText:originAddress];
        [cell.dropoffLabel setText:dropAddress];
        [cell.timeLabel setText:rideTime];
        [cell.messagesTextView setText:message];
        [cell.messagesTextView setTextAlignment:NSTextAlignmentCenter];
         cell.seatsLabel.text = [NSString stringWithFormat:@"%2d",seats];
        [cell.priceLabel setText:[NSString stringWithFormat:@"%3.2lf/mile", pricePerSeat]];
        
        if (femaleOnly==1) {
            [cell.maleImageView setHidden:YES];
        }
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell;
    }
    
    if ([indexPath section]==2) {
        static NSString *simpleTableIdentifier = @"MessageBoardDriverDetailUserTableViewCell";
        MessageBoardDriverDetailUserTableViewCell *cell = (MessageBoardDriverDetailUserTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageBoardDriverDetailUserTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        
        CGFloat widFloat = 0;
        
        if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ){
            
            CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
            CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
            if( screenHeight < screenWidth ){
                screenHeight = screenWidth;
            }
            
            if( screenHeight > 480 && screenHeight < 667 ){
                widFloat = -40.0f;
                
            } else if ( screenHeight > 480 && screenHeight < 736 ){
                widFloat = 20.0f;
            } else if ( screenHeight > 480 ){
                widFloat = 20.0f;
            } else {
                widFloat = -40.0f;
                
                
            }
        }
        else{
            widFloat = 410.0f;
            
        }
        
        UIView *bottomLineView1 = [[UIView alloc] initWithFrame:CGRectMake(20.0f, 90.0f, cell.bounds.size.width+widFloat, 0.5f)];
        bottomLineView1.backgroundColor = [UIColor grayColor];
        [cell.contentView addSubview:bottomLineView1];
        
        
        NSDictionary* driverMessageRequestsDict = driverMessageRequests[indexPath.row];
        NSString* destinationAddress =driverMessageRequestsDict[@"destinationAddress"];
        NSString* originAddress =driverMessageRequestsDict[@"originAddress"];
        int seats = [driverMessageRequestsDict[@"seats"] intValue];

        [cell.pickupLabel setText:originAddress];
        [cell.dropoffLabel setText:destinationAddress];
        [cell.seatsLabel setText:[NSString stringWithFormat:@"%d",seats]];

        return cell;
    }
    
    if ([indexPath section]==3) {
        static NSString *simpleTableIdentifier = @"MessageBoardBlankTableViewCell";
        MessageBoardBlankTableViewCell *cell = (MessageBoardBlankTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageBoardBlankTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }


    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([indexPath section]==0) {
        return 105;
    }

    if ([indexPath section]==1) {
        return 450;
    }
    
    if ([indexPath section]==2) {
        return 90;
    }
    if ([indexPath section]==3) {
        return 30;
    }

    else
        return 0;
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowDriverJoin"]){
        MessageBoardDriverJoinTableViewController *vc = [segue destinationViewController];

        vc.message = selectedMessage;
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

*/

@end
