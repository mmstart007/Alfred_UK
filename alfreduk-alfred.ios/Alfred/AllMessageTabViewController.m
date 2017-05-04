//
//  AllMessageTabViewController.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 2/22/16.
//  Copyright © 2016 A Ascendanet Sun. All rights reserved.
//

#import <Parse/Parse.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <TWMessageBarManager/TWMessageBarManager.h>

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
    NSArray *messageData;
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
    
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadCityMessages:) forControlEvents:UIControlEventValueChanged];
    [self loadCityMessages:city];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadCityMessages:(NSString*)city{
    PFQuery *query = [PFQuery queryWithClassName:@"BoardMessage"];
    [query includeKey:@"author"]; //load user data also
    [query includeKey:@"author.userRating"];
    [query includeKey:@"author.driverRating"];
    
    //if user mode load driver messages
    [HUD showUIBlockingIndicator];
    
    [query  findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if(self.refreshControl.isRefreshing){
            [self.refreshControl endRefreshing];
        }
        [HUD hideUIBlockingIndicator];
        if(!error){
            messageData = objects;
            
            if(objects.count == 0){
                self.tableView.hidden = YES;
                return ;
            }else{
                self.tableView.hidden = NO;
                [self.tableView reloadData];
            }
        }else{
            
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
    PFUser *user = selectedMessageDict[@"author"];
    if (![user.objectId isEqualToString:[[PFUser currentUser] objectId]]) {
        bool driverMessage = [selectedMessageDict[@"driverMessage"] boolValue];
        if (!driverMessage) {
            [self performSegueWithIdentifier:@"MessagePriceSubmitSegueID" sender:self];
        } else {
            [self performSegueWithIdentifier:@"MessageBoardDriverDetailSegueID" sender:self];
        }
    } else {
        
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
