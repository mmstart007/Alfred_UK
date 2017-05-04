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
#import "MessageBoardContactUserTableViewController.h"
#import "AlfredMessage.h"
#import "HUD.h"


@interface BookedRideTabViewController (){

    NSArray *messageData;
    bool inDriverMode;
    BOOL myMessages;
    AlfredMessage  * selectedMessageDict;
    NSString * city;
    NSArray *_rideJoinRequests;
    NSArray *_userBoardMessages;
}

@end

@implementation BookedRideTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadCityMessages:) forControlEvents:UIControlEventValueChanged];
    
    [self loadCityMessages:city];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

    static NSString * cellIdentifier = @"RideOfferCell";
    MessageBoardMessageTableViewCell *cell = (MessageBoardMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    [cell configureMessageCell: message];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    selectedMessageDict = messageData[indexPath.row];
    [self performSegueWithIdentifier:@"BookedRideSegueID" sender:self];
}

-(void)loadCityMessages:(NSString*)city {
    
    PFQuery *query = [PFQuery queryWithClassName:@"BoardMessage"];
    
    [query includeKey:@"author"]; //load user data also
    [query whereKey:@"author" equalTo:[PFUser currentUser]];
    [query includeKey:@"author.userRating"];
    [query includeKey:@"author.driverRating"];
    // if user mode load driver messages
    [HUD showUIBlockingIndicator];
    
    [query  findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if(self.refreshControl.isRefreshing){
            [self.refreshControl endRefreshing];
        }
        [HUD hideUIBlockingIndicator];
        if(!error) {
            messageData = objects;
            
            if(objects.count == 0) {
                self.tableView.hidden = YES;
                return ;
            } else {
                self.tableView.hidden = NO;
                [self.tableView reloadData];
            }
        } else {
            if(error.code == 209){
                //TODO: Login user again
            }
            self.tableView.hidden = YES;
            messageData = nil;
            
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Ooops! "
                                                           description:@"Can't get messages right now."
                                                                  type:TWMessageBarMessageTypeError];
            
            NSLog(@"Failed to get city messages");
        }
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([[segue identifier] isEqualToString:@"BookedRideSegueID"]){
        MessageBoardContactUserTableViewController *vc = [segue destinationViewController];
        vc.selectedMessage = selectedMessageDict;
    }
}


@end
