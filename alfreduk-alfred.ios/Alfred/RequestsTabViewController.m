//
//  RequestsTabViewController.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 2/28/16.
//  Copyright © 2016 A Ascendanet Sun. All rights reserved.
//

#import "RequestsTabViewController.h"
#import "RequestMessageTableViewCell.h"
#import "MessageBoardUserDetailTableViewController.h"

#import "HUD.h"

#import <Parse/Parse.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface RequestsTabViewController ()<UITableViewDelegate> {
    PFObject *selectedMessage;
    NSMutableArray *_arrRideJoinRequest;
    int _rideTakeCount;
    int _rideJoinCount;
}

@end

@implementation RequestsTabViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    _arrRideJoinRequest = [[NSMutableArray alloc] init];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForRequestPriceBoardMessage:) name:@"didRequestForRequestPriceBoardMessage" object:nil];

    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadRequestMessages) forControlEvents:UIControlEventValueChanged];
    
    [self loadRequestMessages];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Get new request message from push notification
-(void)didRequestForRequestPriceBoardMessage:(NSNotification *)notification {
    
    [self loadRequestMessages];
}

#pragma mark - Load all request messages
-(void)loadRequestMessages {
    
    [PFCloud callFunctionInBackground:@"GetAllMessages"
                       withParameters:@{@"isRequest": @YES}
                                block:^(NSArray *object, NSError *error) {
                                    
                                    [HUD hideUIBlockingIndicator];
                                    if(self.refreshControl.isRefreshing){
                                        [self.refreshControl endRefreshing];
                                    }
                                    if (!error) {
                                        
                                        NSLog(@"get all request board message sucessfully");
                                        
                                        _arrRideJoinRequest = [object mutableCopy];
                                        [self.tableView reloadData];
                                        
                                    } else {
                                        
                                        NSLog(@"Getting request message failed");
                                        
                                        [[[UIAlertView alloc] initWithTitle:@"Getting request message failed" message:@"Check your network connection and try again." delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil] show];
                                    }
                                }];
}

#pragma mark - Delete request message
- (void)deleteRequestMessage:(NSString *)deleteMessageObjId indexPathForDelete:(NSIndexPath *)indexPath {
    [HUD showUIBlockingIndicatorWithText:@"Deleting..."];
    [PFCloud callFunctionInBackground:@"DeleteRideMessage"
                       withParameters:@{@"deleteMessageObjId": deleteMessageObjId,
                                        @"reason": @"DELETE_RIDE_MESSAGE"}
                                block:^(NSString *success, NSError *error) {
                                    [HUD hideUIBlockingIndicator];
                                    if (!error) {
                                        
                                        NSLog(@"delete request board message sucessfully");
                                        
                                        [_arrRideJoinRequest removeObjectAtIndex:indexPath.row];
                                        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                        [self.tableView reloadData];
                                        
                                    } else {
                                        
                                        NSLog(@"Getting request message failed");
                                        
                                        [[[UIAlertView alloc] initWithTitle:@"Getting request message failed" message:@"Check your network connection and try again." delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil] show];
                                    }
                                }];
}

#pragma mark - UITableView Delegate.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _arrRideJoinRequest.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 210;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PFObject *rideJoinRequest = [_arrRideJoinRequest objectAtIndex:indexPath.row];
    
    static NSString * cellIdentifier = @"RequestRideCell";
    RequestMessageTableViewCell *cell = (RequestMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    /* Delete button */
    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"delete"] backgroundColor:[UIColor redColor]  callback:^BOOL(MGSwipeTableCell *sender) {
        
        NSLog(@"Convenience callback for swipe buttons!");
        
        PFObject *deleteMessage = _arrRideJoinRequest[indexPath.row];
        NSString *messageObjectId = deleteMessage.objectId;
        
        [self deleteRequestMessage:messageObjectId indexPathForDelete:indexPath];
        
        return true;
        
    }]];
    
    cell.rightSwipeSettings.transition = MGSwipeTransition3D;
    
    [cell configureRequestMessageCell:rideJoinRequest];
    
    return cell;
    
}

#pragma mark - Table view data source
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    selectedMessage = _arrRideJoinRequest[indexPath.row];
    [self performSegueWithIdentifier:@"MessageRequestSegueID" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"MessageRequestSegueID"]){
        MessageBoardUserDetailTableViewController *vc = [segue destinationViewController];
        vc.selectedMessage = selectedMessage;
    }
}



@end

