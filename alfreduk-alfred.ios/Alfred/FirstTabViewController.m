//
//  FirstTabViewController.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 2/28/16.
//  Copyright © 2016 A Ascendanet Sun. All rights reserved.
//

#import "FirstTabViewController.h"
#import "HUD.h"
#import "Parse/Parse.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface FirstTabViewController ()<UITableViewDelegate>{
    NSArray *_rideJoinRequest;
    NSArray *_rideTakeRequest;
    int _rideTakeCount;
    int _rideJoinCount;
}

@end

@implementation FirstTabViewController

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

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    _rideJoinCount =(_rideJoinRequest!= nil)? (int)_rideJoinRequest.count :0;
    _rideTakeCount = (_rideTakeRequest!= nil)? (int)_rideTakeRequest.count:0;
    return _rideJoinCount + _rideTakeCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    int row = (int)indexPath.row;
    if(row < _rideJoinCount) {

        //ride join request
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"RideJoinRequestCell"];
        UIImageView *profileImageView = [cell viewWithTag:3];
        UILabel *pickupAddressLabel = [cell viewWithTag:20];
        UILabel *dropoffAddressLabel = [cell viewWithTag:21];
        UILabel *nameLabel = [cell viewWithTag:4];
        //UILabel *ratingLabel = [cell viewWithTag:5];
        UILabel *seatsLabel = [cell viewWithTag:7];
        PFObject *rideJoinRequest = [_rideJoinRequest objectAtIndex:indexPath.row];
        
        pickupAddressLabel.text =  rideJoinRequest[@"pickupAddress"];
        dropoffAddressLabel.text = rideJoinRequest[@"dropoffAddress"];
        PFUser * author = rideJoinRequest[@"author"];
        nameLabel.text = [NSString stringWithFormat:@"%@ %c", author[@"FirstName"] , [author[@"LastName"] characterAtIndex:0]];
        seatsLabel.text = [NSString stringWithFormat:@"%d", [rideJoinRequest[@"seats"] intValue] ];
        
        [profileImageView sd_setImageWithURL:[NSURL URLWithString:author[@"ProfilePicUrl"]] placeholderImage:[UIImage imageNamed:@"blank profile"]];
        //make the image rounded
        profileImageView.layer.cornerRadius = profileImageView.layer.frame.size.width/2;
        profileImageView.layer.masksToBounds = YES;
        
        return cell;
        
    } else {
        row = row - _rideJoinCount;
        //ride take cell
        
        UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"RideTakeRequestCell"];
        assert(cell!= nil);
        
        UILabel *dateLabel =  [cell viewWithTag:3];
        UILabel *seatsLabel = [cell viewWithTag:4];
        UILabel *priceLabel = [cell viewWithTag:5];

        UIImageView *profileImageView = [cell viewWithTag:6];
        UILabel *nameLabel = [cell viewWithTag:7];
        UILabel *ratingLabel = [cell viewWithTag:8];
        
        UILabel *pickAddressLabel = [cell viewWithTag:9];
        UILabel *dropAddressLabel = [cell viewWithTag:10];
        
        PFObject * takeRideRequest = _rideTakeRequest[row];
        PFObject *messsage = takeRideRequest[@"BoardMessage"];
        PFObject *author = takeRideRequest[@"author"];
        PFObject *rating = author[@"driverRating"];
        
        NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"MMM dd, HH:mm"];

        seatsLabel.text = [NSString stringWithFormat:@"%2d", [messsage[@"seats"] intValue] ];
        dateLabel.text = [formatter stringFromDate:messsage[@"date"]];;
        priceLabel.text = [NSString stringWithFormat:@"%5.2lf", [takeRideRequest[@"pricePerSeat"] doubleValue]];
        nameLabel.text = author[@"FullName"];
        ratingLabel.text = [NSString stringWithFormat:@"%2.1lf",[rating[@"rating"] doubleValue]];
        
        pickAddressLabel.text = messsage[@"pickupAddress"];
        dropAddressLabel.text = messsage[@"dropoffAddress"];
        
        [profileImageView sd_setImageWithURL:[NSURL URLWithString:author[@"ProfilePicUrl"]] placeholderImage:[UIImage imageNamed:@"blank profile"]];
        //make the image rounded
        profileImageView.layer.cornerRadius = profileImageView.layer.frame.size.width/2;
        profileImageView.layer.masksToBounds = YES;
        
        return  cell;
        
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSLog(@"Tapped request");
    int row = (int)indexPath.row;
    if(row < _rideJoinCount){
        //the user wants to join a ride request

    } else {
        row = row - _rideJoinCount;
        //the driver wants to join a ride request
        //PFObject *request = _rideTakeRequest;
        //double price = [request[@"pricePerSeat"] doubleValue];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Hello, I am available to do this travel in the selected date, would you like me to be your driver in this journey?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Accept",@"Deny", nil];
        [alert show];
        
    }
}

/* load the data to fill the table view*/
-(void)loadUserMessages{
    
    //this are the messages targeted to the user
    PFQuery *innerQuery = [PFQuery queryWithClassName:@"BoardMessage"];
    [innerQuery whereKey:@"author" equalTo:[PFUser currentUser]];
    PFQuery *joinRequestQuery = [PFQuery queryWithClassName:@"JoinRideRequest"];
    [joinRequestQuery whereKey:@"boardMessage" matchesQuery:innerQuery];
    [joinRequestQuery includeKey:@"author"];
    [joinRequestQuery includeKey:@"author.userRating"];
    [joinRequestQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error){
            
            if(objects.count == 0)
            {
                self.tableView.hidden = YES;
                return ;
            }
            else{
                
                _rideJoinRequest = objects;
                [self.tableView reloadData];
                self.tableView.hidden = NO;
            }
            
        }
    }];
    PFQuery *takeRideQuery = [PFQuery queryWithClassName:@"TakeRideRequest"];
    [takeRideQuery whereKey:@"BoardMessage" matchesQuery: innerQuery];
    [takeRideQuery includeKey:@"author"];
    [takeRideQuery includeKey:@"BoardMessage"];
    [takeRideQuery includeKey:@"author.driverRating"];
    
    [takeRideQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error){
            
            _rideTakeRequest = objects;
            [self.tableView reloadData];
            self.tableView.hidden = NO;

        }
    }];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 200;
}

@end
