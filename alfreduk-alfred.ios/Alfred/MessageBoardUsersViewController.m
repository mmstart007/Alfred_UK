//
//  MessageBoardUsersViewController.m
//  Alfred
//
//  Created by Arjun Busani on 06/04/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "MessageBoardUsersViewController.h"
#import "MessageBoardUsersTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MessageBoardUsersViewController ()

@end

@implementation MessageBoardUsersViewController
@synthesize topLayoutConstraint,bottomLayoutConstraint,usersTabelView,usersArray,latNow,longNow,pickupConstraint,requestRideId,dropoffConstraint,pickupButton,dropButton,selectButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    //userRideStatus
    //
    //started
    //ended
    self.popUpView.layer.cornerRadius = 0.5;
    self.popUpView.layer.shadowOpacity = 0.8;
    self.popUpView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);

    [pickupButton setEnabled:NO];
    [dropButton setEnabled:NO];
    [selectButton setEnabled:NO];

self.view.backgroundColor = [UIColor clearColor];
    
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ){
        
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        if( screenHeight < screenWidth ){
            screenHeight = screenWidth;
        }
        
        if( screenHeight > 480 && screenHeight < 667 ){
            topLayoutConstraint.constant = 70;
            bottomLayoutConstraint.constant = 70;
            pickupConstraint.constant = 65;
            dropoffConstraint.constant = -65;

            
        } else if ( screenHeight > 480 && screenHeight < 736 ){
            topLayoutConstraint.constant = 120;
            bottomLayoutConstraint.constant = 120;
            pickupConstraint.constant = 75;
            dropoffConstraint.constant = -75;
            
            
        } else if ( screenHeight > 480 ){
            topLayoutConstraint.constant = 120;
            bottomLayoutConstraint.constant = 120;
            pickupConstraint.constant = 75;
            dropoffConstraint.constant = -75;
            
        } else {
            topLayoutConstraint.constant = 30;
            bottomLayoutConstraint.constant =30;
            pickupConstraint.constant = 65;
            dropoffConstraint.constant = -65;
            
        }
    }
    
    else{
        topLayoutConstraint.constant = 270;
        bottomLayoutConstraint.constant = 270;
        self.leftLayoutConstraint.constant = 210;
        self.rightLayoutConstraint.constant = 210;
        
    }
    
    usersTabelView.delegate = self;
    usersTabelView.dataSource = self;
    self.usersTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;

    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section==0) {
        return [usersArray count];
    }
    else
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"MessageBoardUsersTableViewCell";
    MessageBoardUsersTableViewCell *cell = (MessageBoardUsersTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageBoardUsersTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    
    CGFloat widFloat = 0;
    
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ){
        
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        if( screenHeight < screenWidth ){
            screenHeight = screenWidth;
        }
        
        if( screenHeight > 480 && screenHeight < 667 ){
            widFloat = -70.0f;
            
        } else if ( screenHeight > 480 && screenHeight < 736 ){
            widFloat = 0.0f;
        } else if ( screenHeight > 480 ){
            widFloat = 0.0f;
        } else {
            widFloat = -70.0f;
            
            
        }
    }
    
    
    UIView *bottomLineView1 = [[UIView alloc] initWithFrame:CGRectMake(20.0f, 120.0f, cell.bounds.size.width+widFloat, 0.5f)];
    bottomLineView1.backgroundColor = [UIColor grayColor];
    [cell.contentView addSubview:bottomLineView1];
    
    
    NSDictionary* driverMessageRequestsDict = usersArray[indexPath.row];
    NSString* destinationAddress =driverMessageRequestsDict[@"destinationAddress"];
    NSString* originAddress =driverMessageRequestsDict[@"originAddress"];
    int seats = [driverMessageRequestsDict[@"seats"] intValue];
    NSString* userName =driverMessageRequestsDict[@"userName"];

    NSString* userRideStatus =driverMessageRequestsDict[@"userRideStatus"];
    
    if ([userRideStatus isEqualToString:@"started"]) {
        [cell.statusLabel setText:@"PICKED UP"];

    }
    if ([userRideStatus isEqualToString:@"ended"]) {
        [cell.statusLabel setText:@"DROPPED OFF"];
    }
    if ([userRideStatus isEqualToString:@"not yet started"]) {
        [cell.statusLabel setText:@"YET TO START"];
    }

    NSString* userProfilePic = driverMessageRequestsDict[@"userProfilePic"];

    if (![userProfilePic isKindOfClass:[NSNull class]]) {
        
        
        [cell.profilePicImageView sd_setImageWithURL:[NSURL URLWithString:userProfilePic] placeholderImage:[UIImage imageNamed:@"blank profile"]];
    }
    
    [cell.profilePicImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    cell.profilePicImageView.layer.cornerRadius = cell.profilePicImageView.frame.size.height /2;
    cell.profilePicImageView.layer.masksToBounds = YES;
    cell.profilePicImageView.layer.borderWidth = 0;

   
    [cell.nameLabel setText:userName];
    [cell.pickLabel setText:originAddress];
    [cell.dropLabel setText:destinationAddress];
    [cell.seatsLabel setText:[NSString stringWithFormat:@"%d",seats]];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [selectButton setEnabled:YES];

    NSDictionary* driverMessageRequestsDict = usersArray[indexPath.row];
    NSString* userRideStatus =driverMessageRequestsDict[@"userRideStatus"];
    if ([userRideStatus isEqualToString:@"started"]) {
        [pickupButton setEnabled:NO];
        [dropButton setEnabled:YES];

    }
    if ([userRideStatus isEqualToString:@"ended"]) {
        [pickupButton setEnabled:NO];
        [dropButton setEnabled:NO];
        
    }
    if ([userRideStatus isEqualToString:@"not yet started"]) {
        [pickupButton setEnabled:YES];
        [dropButton setEnabled:NO];
        
    }
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    
    if ([indexPath section]==0) {
        return 120;
    }
 
    
    else
        return 0;
    
}


- (IBAction)userSelected:(id)sender {
    
    NSIndexPath *selectedIndexPath = [usersTabelView indexPathForSelectedRow];
    NSDictionary* usersDict = usersArray[selectedIndexPath.row];

    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForUserSelected" object:usersDict];

    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)dropUser:(id)sender {
    
    
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
     
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *driverId = [prefs stringForKey:@"driverId"];
        int driverIdInt = [driverId intValue];
        //NSString *rideID = [prefs stringForKey:@"requestRideId"];

        NSLog(@"requestRideId:: %@",requestRideId);
        NSIndexPath *selectedIndexPath = [usersTabelView indexPathForSelectedRow];
        NSDictionary* usersDict = usersArray[selectedIndexPath.row];
        NSString* userID = usersDict[@"userId"];
       
        
        NSString *originLatitude = usersDict[@"originLatitude"];
        NSString *originLongitude = usersDict[@"originLongitude"];
        NSString *destinationLatitude = usersDict[@"destinationLatitude"];
        NSString *destinationLongitude = usersDict[@"destinationLongitude"];
        

        double originLatitudeDouble =[originLatitude doubleValue];
        double originLongitudeDouble =[originLongitude doubleValue];
        double destinationLatitudeDouble =[destinationLatitude doubleValue];
        double destinationLongitudeDouble =[destinationLongitude doubleValue];

        CLLocation *locA = [[CLLocation alloc] initWithLatitude:originLatitudeDouble longitude:originLongitudeDouble];
        
        CLLocation *locB = [[CLLocation alloc] initWithLatitude:destinationLatitudeDouble longitude:destinationLongitudeDouble];
        double distance = [locA distanceFromLocation:locB];
        
        NSString* totalDist = [NSString stringWithFormat:@"%f",distance];

        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        
        NSString* URL_SIGNIN = @"http://ec2-52-74-6-189.ap-southeast-1.compute.amazonaws.com:8080/dropOffUser";
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:requestRideId,@"rideId",userID,@"userId",latNow,@"latitude",longNow,@"longitude",totalDist,@"distance",nil];
        [params setValue:[NSNumber numberWithInt:driverIdInt] forKey:@"driverId"];

        
        [manager POST:URL_SIGNIN parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Success: %@", responseObject);
            
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForMessageBoardStartAccepted" object:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", [error localizedDescription]);
            
        }];
        
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            
            
        });
    });
    

    
}

- (IBAction)pickUser:(id)sender {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *driverId = [prefs stringForKey:@"driverId"];
        //NSString *rideID = [prefs stringForKey:@"requestRideId"];
        NSLog(@"requestRideId:: %@",requestRideId);

        int driverIdInt = [driverId intValue];
        
        NSIndexPath *selectedIndexPath = [usersTabelView indexPathForSelectedRow];
        NSDictionary* usersDict = usersArray[selectedIndexPath.row];
        NSString* userID = usersDict[@"userId"];

        [[NSUserDefaults standardUserDefaults] synchronize];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        
        NSString* URL_SIGNIN = @"http://ec2-52-74-6-189.ap-southeast-1.compute.amazonaws.com:8080/pickUpUser";
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:requestRideId,@"rideId",userID,@"userId",latNow,@"latitude",longNow,@"longitude",nil];
        [params setValue:[NSNumber numberWithInt:driverIdInt] forKey:@"driverId"];
        
        
        [manager POST:URL_SIGNIN parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Success: %@", responseObject);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForMessageBoardStartAccepted" object:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", [error localizedDescription]);
            
        }];
        
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            
            
        });
    });
    

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
