//
//  BookedRideTabViewController.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 3/12/16.
//  Copyright © 2016 A Ascendanet Sun. All rights reserved.
//

#import <Parse/Parse.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <TWMessageBarManager/TWMessageBarManager.h>

#import "BookedRideTabViewController.h"
#import "MessageBoardMessageTableViewCell.h"
#import "RequestMessageTableViewCell.h"
#import "AcceptMessageTableViewCell.h"
#import "MessageBoardContactUserTableViewController.h"
#import "AlfredMessage.h"
#import "HUD.h"


@interface BookedRideTabViewController (){

    NSMutableArray *messageData;
    bool inDriverMode;
    BOOL myMessages;
    AlfredMessage  * selectedMessageDict;
    NSString * city;
    
}

@end

@implementation BookedRideTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForAcceptBoardMessage:) name:@"didRequestForAcceptBoardMessage" object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadAcceptedMessages) forControlEvents:UIControlEventValueChanged];
    
    [self loadAcceptedMessages];
}

- (void)didRequestForAcceptBoardMessage:(NSNotification *)notification {
    [self loadAcceptedMessages];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadAcceptedMessages {
    
    [PFCloud callFunctionInBackground:@"GetAllMessages"
                       withParameters:@{@"isRequest": @NO}
                                block:^(NSArray *object, NSError *error) {
                                    
                                    [HUD hideUIBlockingIndicator];
                                    if(self.refreshControl.isRefreshing){
                                        [self.refreshControl endRefreshing];
                                    }
                                    if (!error) {
                                        
                                        NSLog(@"get all request board message sucessfully");
                                        
                                        messageData = [object mutableCopy];
                                        [self.tableView reloadData];
                                        
                                    } else {
                                        
                                        NSLog(@"Getting request message failed");
                                        
                                        [[[UIAlertView alloc] initWithTitle:@"Ooops!" message:@"Can't get messages right now." delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil] show];
                                    }
                                }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return messageData.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 210;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PFObject *message = messageData[indexPath.row];

    static NSString * cellIdentifier = @"AcceptRideCell";
    AcceptMessageTableViewCell *cell = (AcceptMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    [cell configureRequestMessageCell:message];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    selectedMessageDict = messageData[indexPath.row];
    [self performSegueWithIdentifier:@"BookedRideSegueID" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([[segue identifier] isEqualToString:@"BookedRideSegueID"]){
        MessageBoardContactUserTableViewController *vc = [segue destinationViewController];
        vc.selectedMessage = selectedMessageDict;
    }
}



@end
