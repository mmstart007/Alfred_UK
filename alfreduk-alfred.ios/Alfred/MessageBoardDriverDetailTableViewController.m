//
//  MessageBoardDriverDetailTableViewController.m
//  Alfred
//
//  Created by Arjun Busani on 26/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "MessageBoardDriverDetailTableViewController.h"
#import "SWRevealViewController.h"
#import "MessageBoardReviewTableViewCell.h"
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
    [self initialView];
    
    driverMessageRequests = [[NSArray alloc] init];
    driverMessageRequests = selectedMessage[@"driverMessageRequests"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForJoinAlfred:) name:@"didRequestForJoinAlfred" object:nil];
    
    self.navigationItem.title = @"Profile";
}

-(void)viewDidAppear:(BOOL)animated{

}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForJoinAlfred" object:nil];
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
    if ([[segue identifier] isEqualToString:@"ShowDriverJoin"]){
        MessageBoardDriverJoinTableViewController *vc = [segue destinationViewController];

        vc.message = selectedMessage;
    }
}

#pragma mark - UIButton Action.
- (IBAction)joinAlfredAction:(id)sender {
    
}





@end
