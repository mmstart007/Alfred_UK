//
//  SecondTabViewController.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 2/22/16.
//  Copyright © 2016 A Ascendanet Sun. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import <Parse/Parse.h>
#import <TWMessageBarManager/TWMessageBarManager.h>

#import "SecondTabViewController.h"
#import "AlfredMessageBoardViewController.h"
#import "MessageBoardMessageTableViewCell.h"
#import "MessageBoardLogoTableViewCell.h"
#import "MessageBoardDriverDetailTableViewController.h"
#import "MessageBoardUserDetailTableViewController.h"
#import "MessageBoardPersonalUserTableViewController.h"
#import "MessageBoardPersonalDriverTableViewController.h"
#import "AlfredMessage.h"
#import "MDButton.h"
#import "MDConstants.h"
#import "SecondTabViewController.h"
#import "MDTabBarViewController.h"
#import "SWRevealViewController.h"

@interface SecondTabViewController (){
    NSArray *messageData;
    bool inDriverMode;
    
    BOOL myMessages;
    AlfredMessage  * selectedMessageDict;
    NSString * city;
    NSArray *_rideJoinRequests;
    NSArray *_userBoardMessages;
}

@end

@implementation SecondTabViewController

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

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return messageData.count;
    
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //long row = indexPath.row;
    PFObject *message = messageData[indexPath.row];

    if([message[@"driverMessage"] boolValue] == YES){
        
        static NSString * cellIdentifier = @"RideOfferCell";
        MessageBoardMessageTableViewCell *cell = (MessageBoardMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        //BOOL driver= [message[@"driverMessage"] boolValue];
        int seats = [message[@"seats"] intValue];
        
        //int driver = [messageDict[@"driver"] intValue];
        NSString* dropAddress = message[@"dropoffAddress"];
        NSString* originAddress = message[@"pickupAddress"];
        double pricePerSeat = [message[@"pricePerSeat"] doubleValue];
        
        NSString* title = message[@"title"];
        
        NSDate *date = message[@"date"];
        bool femaleOnly = [message[@"femaleOnly"] boolValue];

        PFUser *user = message[@"author"];
        PFObject *ratingObject = user[@"driverRating"];
        NSString *pic = user[@"ProfilePicUrl"];
        NSString *firstName  = user[@"FirstName"];
        NSString *lastName = user[@"LastName"];
        NSString *userName = [NSString stringWithFormat:@"%@ %c.",firstName, [lastName characterAtIndex:0]];
        UILabel *priceLabel = (UILabel*) [cell viewWithTag:8];
        UILabel *seatsLabel = (UILabel*) [cell viewWithTag:7];
        UILabel *nameLabel = (UILabel*) [cell viewWithTag:4];
        UILabel *ratingLabel = (UILabel*) [cell viewWithTag:5];
        UILabel *titleLabel = (UILabel*) [cell viewWithTag:6];
        UILabel *dateLabel = (UILabel*) [cell viewWithTag:1];
        UILabel *ladiesOnlyLabel = (UILabel*) [cell viewWithTag:2];
        UIImageView *profilePicImageView =  (UIImageView*)[cell viewWithTag:3];
        UILabel *pickupLabel  = (UILabel*)[cell viewWithTag:20];
        UILabel *dropoffLabel = (UILabel*)[cell viewWithTag:21];
        
        NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"MMM dd, HH:mm"];
        
        dateLabel.text = [formatter stringFromDate:date];
        
        nameLabel.text = userName;
        priceLabel.text = [NSString stringWithFormat:@"%5.2lf",pricePerSeat];
        seatsLabel.text = [NSString stringWithFormat:@"%2d",seats];
        titleLabel.text = title;
        pickupLabel.text = originAddress;
        dropoffLabel.text = dropAddress;
        ratingLabel.text = [NSString stringWithFormat:@"%2.1lf", [ratingObject[@"rating"] doubleValue]];
        
        if(femaleOnly){
            ladiesOnlyLabel.hidden = NO;
        }else{
            ladiesOnlyLabel.hidden = YES;
        }
        if (![pic isKindOfClass:[NSNull class]]) {
            
            [profilePicImageView sd_setImageWithURL:[NSURL URLWithString:pic] placeholderImage:[UIImage imageNamed:@"blank profile"]];
        }
        profilePicImageView.layer.cornerRadius = profilePicImageView.frame.size.height /2;
        profilePicImageView.layer.masksToBounds = YES;
        profilePicImageView.layer.borderWidth = 0;
        
        
        return cell;
        
    } else {
        
        PFObject *message = messageData[indexPath.row];
        PFUser *user = message[@"author"];
        PFObject *ratingObject = user[@"userRating"];
        
        //showing ride request cells
        static NSString * cellIdentifier = @"RideRequestCell";
        MessageBoardMessageTableViewCell *cell = (MessageBoardMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        int seats = (int)[message[@"seats"] integerValue];
        NSString* dropAddress = message[@"dropoffAddress"];
        NSString* originAddress = message[@"pickupAddress"];
        NSString* title = message[@"title"];
        NSDate *date = message[@"date"];
        bool femaleOnly = [message[@"femaleOnly"] boolValue];
        NSString *pic = user[@"ProfilePicUrl"];
        NSString *firstName  = user[@"FirstName"];
        NSString *lastName = user[@"LastName"];
        NSString *userName = [NSString stringWithFormat:@"%@ %c.",firstName, [lastName characterAtIndex:0]];
        UILabel *seatsLabel = (UILabel*) [cell viewWithTag:7];
        UILabel *nameLabel = (UILabel*) [cell viewWithTag:4];
        UILabel *titleLabel = (UILabel*) [cell viewWithTag:6];
        UILabel *dateLabel = (UILabel*) [cell viewWithTag:1];
        UILabel *ladiesOnlyLabel = (UILabel*) [cell viewWithTag:2];
        UIImageView *profilePicImageView =  (UIImageView*)[cell viewWithTag:3];
        UILabel *ratingLabel = (UILabel*)[cell viewWithTag:5];
        UILabel *pickupLabel = (UILabel*)[cell viewWithTag:20];
        UILabel *dropoffLabel = (UILabel*)[cell viewWithTag:21];
        pickupLabel.text = originAddress;
        dropoffLabel.text = dropAddress;
        
        NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"MMM dd, HH:mm"];
        dateLabel.text = [formatter stringFromDate:date];
        
        nameLabel.text = userName;
        
        seatsLabel.text = [NSString stringWithFormat:@"%2d",seats];
        titleLabel.text = title;
        ratingLabel.text = [NSString stringWithFormat:@"%2.1lf", [ratingObject[@"rating"] doubleValue]];
        
        if(femaleOnly){
            ladiesOnlyLabel.hidden = NO;
        }else{
            ladiesOnlyLabel.hidden = YES;
        }
        if (![pic isKindOfClass:[NSNull class]]) {
            
            [profilePicImageView sd_setImageWithURL:[NSURL URLWithString:pic] placeholderImage:[UIImage imageNamed:@"blank profile"]];
        }
        profilePicImageView.layer.cornerRadius = profilePicImageView.frame.size.height /2;
        profilePicImageView.layer.masksToBounds = YES;
        profilePicImageView.layer.borderWidth = 0;
        
        
        return cell;
    }
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
            
            if(objects.count == 0)
            {
                self.tableView.hidden = YES;
                return ;
            }
            else{
                
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 180;
}


@end
