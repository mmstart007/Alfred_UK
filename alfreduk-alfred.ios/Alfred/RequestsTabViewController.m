//
//  RequestsTabViewController.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 2/28/16.
//  Copyright © 2016 A Ascendanet Sun. All rights reserved.
//

#import "RequestsTabViewController.h"
#import "MessageBoardMessageTableViewCell.h"
#import "MessageBoardUserDetailTableViewController.h"

#import "HUD.h"

#import <Parse/Parse.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface RequestsTabViewController ()<UITableViewDelegate> {
    PFObject *selectedMessage;
    NSMutableArray *_rideJoinRequest;
    NSArray *_rideTakeRequest;
    int _rideTakeCount;
    int _rideJoinCount;
}

@end

@implementation RequestsTabViewController

- (void)viewDidLoad {
    
    _rideJoinRequest = nil;
    [super viewDidLoad];

    [self loadUserMessages];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* load the data to fill the table view*/
-(void)loadUserMessages{
    
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
            _rideJoinRequest = [objects mutableCopy];
            
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
            _rideJoinRequest = nil;
            
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Ooops! "
                                                           description:@"Can't get messages right now."
                                                                  type:TWMessageBarMessageTypeError];
            
            NSLog(@"Failed to get city messages");
        }
    }];
}

#pragma mark - UITableView Delegate.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _rideJoinRequest.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 210;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PFObject *rideJoinRequest = [_rideJoinRequest objectAtIndex:indexPath.row];
    static NSString * cellIdentifier = @"RideOfferCell";
    MessageBoardMessageTableViewCell *cell = (MessageBoardMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"delete"] backgroundColor:[UIColor redColor]  callback:^BOOL(MGSwipeTableCell *sender) {
        
        NSLog(@"Convenience callback for swipe buttons!");
        
        [_rideJoinRequest removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        return true;
        
    }]];
    cell.rightSwipeSettings.transition = MGSwipeTransition3D;
    
    [cell configureMessageCell:rideJoinRequest];
    
    return cell;
    
}

#pragma mark - Table view data source
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    selectedMessage = _rideJoinRequest[indexPath.row];
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

