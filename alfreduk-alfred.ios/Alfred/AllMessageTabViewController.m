//
//  AllMessageTabViewController.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 2/22/16.
//  Copyright © 2016 A Ascendanet Sun. All rights reserved.
//

#import <Parse/Parse.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "TWMessageBarManager.h"

#import "AllMessageTabViewController.h"
#import "AlfredMessageBoardViewController.h"
#import "MessageBoardMessageTableViewCell.h"
#import "MessageBoardDriverDetailTableViewController.h"
#import "MessageBoardUserDetailTableViewController.h"
#import "MessageBoardPersonalUserTableViewController.h"
#import "MessageBoardPersonalDriverTableViewController.h"
#import "AlfredMessage.h"
#import "MDButton.h"
#import "MDConstants.h"
#import "MDTabBarViewController.h"
#import "SWRevealViewController.h"
#import "MessagePriceSubmitViewController.h"

@interface AllMessageTabViewController (){
    NSMutableArray *messageData;
    bool inDriverMode;
    
    BOOL myMessages;
    AlfredMessage  * selectedMessageDict;
    NSString * city;
    NSArray *_rideJoinRequests;
    NSArray *_userBoardMessages;

}

@end

@implementation AllMessageTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    messageData = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForCreateBoardMessage:) name:@"didRequestForCreateBoardMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForAcceptBoardMessage:) name:@"didRequestForAcceptBoardMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForDeleteBoardMessage:) name:@"didRequestForDeleteBoardMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForAutoDeclineBoardMessage:) name:@"didRequestForAutoDeclineBoardMessage" object:nil];

    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadAllMessages) forControlEvents:UIControlEventValueChanged];
    
    [self loadAllMessages];
}

-(void)didRequestForCreateBoardMessage:(NSNotification *)notification {

    [self loadAllMessages];
}

- (void)didRequestForAcceptBoardMessage:(NSNotification *)notification {
    [self loadAllMessages];
}

- (void)didRequestForDeleteBoardMessage:(NSNotification *)notification {
    [self loadAllMessages];
}

- (void)didRequestForAutoDeclineBoardMessage:(NSNotification *)notification {
    [self loadAllMessages];
}

-(void)loadAllMessages {
    
    [PFCloud callFunctionInBackground:@"GetAllMessages"
                       withParameters:@{@"requestType": @"all"}
                                block:^(NSArray *objects, NSError *error) {
                                    
                                    if(self.refreshControl.isRefreshing) {
                                        [self.refreshControl endRefreshing];
                                    }
                                    if(!error){
                                        messageData = [objects mutableCopy];
                                        [self.tableView reloadData];
                                    }else{
                                        [[[UIAlertView alloc] initWithTitle:@"Getting all message failed" message:@"Check your network connection and try again." delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil] show];
                                        NSLog(@"Failed to get city messages");
                                    }
                                }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return messageData.count;
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PFObject *message = messageData[indexPath.row];

    static NSString * cellIdentifier = @"RideOfferCell";
    MessageBoardMessageTableViewCell *cell = (MessageBoardMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    [cell configureMessageCell:message];

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 210;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    selectedMessageDict = messageData[indexPath.row];
    bool driverMessage = [selectedMessageDict[@"driverMessage"] boolValue];
    
    if (driverMessage) {
        [self performSegueWithIdentifier:@"MessageBoardDriverDetailSegueID" sender:self];
    } else {
        if ([[PFUser currentUser][@"EnabledAsDriver"] boolValue]) {
            [self performSegueWithIdentifier:@"MessagePriceSubmitSegueID" sender:self];
        } else {
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Alfred "
                                                           description:@"You should register as Driver."
                                                                  type:TWMessageBarMessageTypeError];
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"MessageBoardDriverDetailSegueID"]){
        MessageBoardDriverDetailTableViewController *vc = [segue destinationViewController];
        vc.selectedMessage = selectedMessageDict;
    }
    if ([[segue identifier] isEqualToString:@"MessagePriceSubmitSegueID"]){
        MessagePriceSubmitViewController *vc = [segue destinationViewController];
        vc.selectedMessage = selectedMessageDict;
    }
}



@end
