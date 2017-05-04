//
//  MessageBoardUserDetailTableViewController.m
//  Alfred
//
//  Created by Arjun Busani on 27/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "MessageBoardUserDetailTableViewController.h"
#import "SWRevealViewController.h"
#import "MessageBoardDriverDetailHeadTableViewCell.h"
#import "MessageBoardUserPostTableViewCell.h"
#import "MessageBoardUserDetailDriverTableViewCell.h"
#import "MessageBoardBlankTableViewCell.h"
#import "MessageBoardUserJoinTableViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MessageBoardUserDetailTableViewController ()

@end

@implementation MessageBoardUserDetailTableViewController
@synthesize selectedMessage,userMessageRequests;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialView];
    
    userMessageRequests = [[NSArray alloc] init];
    userMessageRequests = selectedMessage[@"driverMessageRequests"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForBeTheAlfred:) name:@"didRequestForBeTheAlfred" object:nil];
    self.title = @"Profile";
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForBeTheAlfred" object:nil];
    
}

-(void)didRequestForBeTheAlfred:(id)sender{
    
    [self performSegueWithIdentifier:@"ShowUserJoin" sender:self];
}

-(void)backView:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIButton Action.
- (IBAction)acceptJourneyAction:(id)sender {

}

- (IBAction)declineJourneyAction:(id)sender {

}

- (void)initialView {
    
    NSDate *date = selectedMessage[@"date"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm MMM dd, yyyy"];
    NSString* rideTime = [formatter stringFromDate:date];
    int seats = [ selectedMessage[@"seats"] intValue];
    NSString* dropAddress = selectedMessage[@"dropoffAddress"];
    NSString* originAddress = selectedMessage[@"pickupAddress"];
    double pricePerSeat = [selectedMessage[@"pricePerSeat"] doubleValue];
    NSString* message = selectedMessage[@"desc"];
    BOOL femaleOnly = [selectedMessage[@"femaleOnly"] boolValue];
    //user data
    PFUser * user= selectedMessage[@"author"];
    //assert(user != nil);
    //NSString* mobile = user[@"Phone"];
    PFObject *driverRating = user[@"driverRating"];
    double rating = [driverRating[@"rating"] doubleValue];
    NSString* userName = [NSString stringWithFormat:@"%@ %c.",
                          user[@"FirstName"],
                          [ (NSString*)user[@"LastName"] characterAtIndex:0]];
    
    NSString* pic = user[@"ProfilePicUrl"];
    
    if (![pic isKindOfClass:[NSNull class]]) {
        [self.picImageView sd_setImageWithURL:[NSURL URLWithString:pic] placeholderImage:[UIImage imageNamed:@"blank profile"]];
    }
    [self.nameLabel setText:[NSString stringWithFormat:@"%@",userName]];
    [self.cellLabel setText:@""]; //this is a hack for now
    [self.ratingLabel setText:[NSString stringWithFormat:@"%.1f",rating]];
    [self.pickupLabel setText:originAddress];
    [self.dropoffLabel setText:dropAddress];
    [self.timeLabel setText:rideTime];
    [self.messagesTextView setText:message];
    [self.priceLabel setText:[NSString stringWithFormat:@"Price: £%3.2lf per seat", pricePerSeat]];
    self.picImageView.layer.cornerRadius = self.picImageView.frame.size.height /2;
    self.picImageView.layer.masksToBounds = YES;
    self.picImageView.layer.borderWidth = 0;
    self.seatsLabel.text = [NSString stringWithFormat:@"Seats available: %2d",seats];
    self.seatsSelectView.value = [selectedMessage[@"seats"] doubleValue];
    [self.seatsSelectView setNeedsDisplay];
    
    if (femaleOnly) {
        [self.ladiesOnlyLabel setHidden:NO];
    } else {
        [self.ladiesOnlyLabel setHidden:YES];
    }
}

#pragma mark - UITableView Data Source.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * cellIdentifier = @"AlfredReviewCell";
    MessageBoardReviewTableViewCell *cell = (MessageBoardReviewTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    [cell configureCell:selectedMessage];
    
    return cell;
}

#pragma mark - UITableView Delegate.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 92;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowUserJoin"]){
        
        MessageBoardUserJoinTableViewController *vc = [segue destinationViewController];
        
        vc.messageBoard = selectedMessage;
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
