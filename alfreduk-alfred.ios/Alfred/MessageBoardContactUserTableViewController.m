//
//  MessageBoardContactUserTableViewController.m
//  Alfred
//
//  Created by Maxim on 4/27/17.
//  Copyright © 2017 A Ascendanet Sun. All rights reserved.
//

#import "MessageBoardContactUserTableViewController.h"
#import "MessageBoardReviewTableViewCell.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface MessageBoardContactUserTableViewController ()

@end

@implementation MessageBoardContactUserTableViewController

@synthesize selectedMessage,driverMessageRequests;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialView];
    
    driverMessageRequests = [[NSArray alloc] init];
    driverMessageRequests = selectedMessage[@"driverMessageRequests"];

    self.navigationItem.title = @"Profile";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
