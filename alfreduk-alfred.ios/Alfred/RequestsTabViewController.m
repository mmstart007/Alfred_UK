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
    NSMutableArray *arrRideJoinRequest;
    NSMutableArray *arrMyBoardMessage;
    int _rideTakeCount;
    int _rideJoinCount;
}

@end

@implementation RequestsTabViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    arrRideJoinRequest = [[NSMutableArray alloc]init];
    arrMyBoardMessage = [[NSMutableArray alloc]init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForRequestPriceBoardMessage:) name:@"didRequestForRequestPriceBoardMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForAcceptBoardMessage:) name:@"didRequestForAcceptBoardMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForDeleteBoardMessage:) name:@"didRequestForDeleteBoardMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForAutoDeclineBoardMessage:) name:@"didRequestForAutoDeclineBoardMessage" object:nil];

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

- (void)didRequestForAcceptBoardMessage:(NSNotification *)notification {
    [self loadRequestMessages];
}

- (void)didRequestForDeleteBoardMessage:(NSNotification *)notification {
    [self loadRequestMessages];
}

- (void)didRequestForAutoDeclineBoardMessage:(NSNotification *)notification {
    [self loadRequestMessages];
}

#pragma mark - Load all request messages
-(void)loadRequestMessages {
    
    [PFCloud callFunctionInBackground:@"GetAllMessages"
                       withParameters:@{@"requestType": @"request"}
                                block:^(NSArray *object, NSError *error) {
                                    
                                    [HUD hideUIBlockingIndicator];
                                    if(self.refreshControl.isRefreshing){
                                        [self.refreshControl endRefreshing];
                                    }
                                    if (!error) {
                                        
                                        NSLog(@"get all request board message sucessfully");
                                        
                                        arrMyBoardMessage = [object objectAtIndex:1];
                                        arrRideJoinRequest = [object objectAtIndex:0];
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
                                        
                                        [self loadRequestMessages];
                                        
                                    } else {
                                        
                                        NSLog(@"Getting request message failed");
                                        
                                        [[[UIAlertView alloc] initWithTitle:@"Getting request message failed" message:@"Check your network connection and try again." delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil] show];
                                    }
                                }];
}

#pragma mark - UITableView Delegate.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (section) {
        case 0:
            return arrMyBoardMessage.count;
            break;
        case 1:
            return arrRideJoinRequest.count;
            break;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
            case 0:
                return 210;
                break;
            case 1:
                return 210;
                break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * cellIdentifier = @"RequestRideCell";
    RequestMessageTableViewCell *cell = (RequestMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (indexPath.section == 0) {
        /* Delete button */
        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"delete"] backgroundColor:[UIColor redColor]  callback:^BOOL(MGSwipeTableCell *sender) {
            
            NSLog(@"Convenience callback for swipe buttons!");
            
            PFObject *deleteMessage = arrMyBoardMessage[indexPath.row];
            NSString *messageObjectId = deleteMessage.objectId;
            NSString *status = deleteMessage[@"status"];
            
            if ([status isEqualToString:@"accept"])
            {
                [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Alfred "
                                                               description:@"You can't delete this message right now."
                                                                      type:TWMessageBarMessageTypeError];
            } else {
                [self deleteRequestMessage:messageObjectId indexPathForDelete:indexPath];
            }
            
            return true;
            
        }]];
        
        cell.rightSwipeSettings.transition = MGSwipeStateSwipingRightToLeft;
        
        PFObject *myMessageObj = arrMyBoardMessage[indexPath.row];
        [cell configureMyMessageCell:myMessageObj];
        
    } else if (indexPath.section == 1) {
        PFObject *requestMessageObj = arrRideJoinRequest[indexPath.row];
        [cell configureRequestMessageCell:requestMessageObj];
    }
    
    return cell;
    
}

#pragma mark - Table view data source
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if(indexPath.section == 1) {
        selectedMessage = arrRideJoinRequest[indexPath.row];
        [self performSegueWithIdentifier:@"MessageRequestSegueID" sender:self];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch (section) {
            case 0:
                if (arrMyBoardMessage.count > 0) {
                    return @"MY MESSAGES";
                } else {
                    return nil;
                }
                break;
            case 1:
                if (arrRideJoinRequest.count > 0) {
                    return @"REQUEST MESSAGES";
                } else {
                    return nil;
                }
            break;
            
        default:
            break;
    }
    return nil;
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

