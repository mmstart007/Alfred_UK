//
//  RequestRidePopupViewController.m
//  Alfred
//
//  Created by Arjun Busani on 01/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "RequestRidePopupViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Parse/Parse.h>
#import "HCSStarRatingView/HCSStarRatingView.h"


@interface RequestRidePopupViewController () {
    
    double pickupLatitude;
    double pickupLongitude;
    double dropoffLatitude;
    double dropoffLongitude;
}


@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;

@end

@implementation RequestRidePopupViewController
@synthesize pricePerSeat;
@synthesize pickupAddress,
dropoffAddress,
pickupLabel,
dropoffLabel,
rating,
mobile,
mobileLabel,
requestId,
riderName,
nameLabel,
seats,
userId,
requestRideId,
rideRequestDict,
profileImageView,
userPic;

@synthesize rideRequest;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.popUpView.layer.cornerRadius = 0.5;
    self.popUpView.layer.shadowOpacity = 0.8;
    self.popUpView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    if (![userPic isKindOfClass:[NSNull class]]) {
        [profileImageView sd_setImageWithURL:[NSURL URLWithString:userPic] placeholderImage:[UIImage imageNamed:@"blank profile"]];
    }
    [profileImageView setContentMode:UIViewContentModeScaleAspectFill];

    //rounded image
    profileImageView.layer.cornerRadius = profileImageView.frame.size.height * 0.5;
    profileImageView.layer.masksToBounds = YES;
    profileImageView.layer.borderWidth = 0;
    pickupLabel.text = pickupAddress;
    dropoffLabel.text = dropoffAddress;
    mobileLabel.text = mobile;
    nameLabel.text = riderName;
    self.ratingView.userInteractionEnabled = NO;
    self.ratingView.value = rating;
    
    [self.seatsLabel setText:[NSString stringWithFormat:@"%d",seats] ];
    double price = seats * pricePerSeat;
    [self.totalPrice setText:[NSString stringWithFormat:@"%3.1lf",price]];

    pickupLatitude = [rideRequest[@"pickupLatitude"] doubleValue];
    pickupLongitude = [rideRequest[@"pickupLongitude"] doubleValue];
    dropoffLatitude = [rideRequest[@"dropoffLatitude"] doubleValue];
    dropoffLongitude = [rideRequest[@"dropoffLongitude"] doubleValue];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForRideRequestCancel" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForRideRequestCancel:) name:@"didRequestForRideRequestCancel" object:nil];
}

-(void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForRideRequestCancel" object:nil];

}

-(void)didRequestForRideRequestCancel:(NSNotification *)notification
{
    NSString *rideID = [notification object];
    if ([rideID isEqualToString:requestId]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        NSLog(@"Invalid RideID ============ ");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showAnimate {
    self.view.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.view.alpha = 0;
    [UIView animateWithDuration:.25 animations:^{
        self.view.alpha = 1;
        self.view.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)removeAnimate {
    [UIView animateWithDuration:.25 animations:^{
        self.view.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.view removeFromSuperview];
        }
    }];
}


- (IBAction)declineRequest:(id)sender {

    [self acceptOrRejectRideRequest:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)acceptRequest:(id)sender {
    
    [self acceptOrRejectRideRequest:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)pickupButtonTap:(id)sender {
    NSString *urlString;
    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"comgooglemaps:"]]) {
        urlString = [NSString stringWithFormat:@"comgooglemaps://?center=%f,%f&q=%f,%f",pickupLatitude,pickupLongitude,pickupLatitude,pickupLongitude];
    } else {
        urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?ll=%f,%f",pickupLatitude,pickupLongitude];
    }
    NSLog(@"%@", urlString);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (IBAction)dropOffButtonTap:(id)sender {
    NSString *urlString;
    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"comgooglemaps:"]]) {
        urlString = [NSString stringWithFormat:@"comgooglemaps://?center=%f,%f&q=%f,%f",dropoffLatitude,dropoffLongitude,dropoffLatitude,dropoffLongitude];
    } else {
        urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?ll=%f,%f",dropoffLatitude,dropoffLongitude];
    }
    NSLog(@"%@", urlString);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

-(void)acceptOrRejectRideRequest:(BOOL)accepted{
    
    //make user active
    if(accepted){
        [PFCloud callFunctionInBackground:@"AcceptRide"
                           withParameters:@{@"rideId": requestId}
                                    block:^(PFObject *object, NSError *error) {
                                        if (!error) {
                                            NSLog(@"%@ accepted the %@'s ride !!!!", object[@"driver"][@"FullName"], riderName);
                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"didAcceptRide" object:nil];
                                        } else {
                                            NSLog(@"AcceptRide request Failed !!!!");
                                            [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Accept" otherButtonTitles:nil] show];
                                        }
                                    }];
        
    } else {
        NSLog(@"Ride declined by driver");
        [PFCloud callFunctionInBackground:@"DeleteRide"
                           withParameters:@{@"rideId": requestId,
                                            @"reason": @"RIDE_REJECTED"}
                                    block:^(NSString *success, NSError *error) {
                                        if (!error) {
                                            NSLog(@"Ride request rejected by Driver ========= ");
                                        } else {
                                            NSLog(@"Decline Ride request Failed !!!!");
                                        }
                                    }];
        
    }
}

-(void)addMessageBoardRequest{
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *tokenID = [prefs stringForKey:@"token"];
        NSString *driverID = [prefs stringForKey:@"driverId"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString* pickLatLoc = [NSString stringWithFormat:@"%@", rideRequestDict[@"originLatitude"]];
        NSString*  pickLongLoc = [NSString stringWithFormat:@"%@", rideRequestDict[@"originLongitude"]];
        NSString* dropLatLoc = [NSString stringWithFormat:@"%@", rideRequestDict[@"destinationLatitude"]];
        NSString*  dropLongLoc = [NSString stringWithFormat:@"%@", rideRequestDict[@"destinationLongitude"]];
        
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-d hh:mm"];
        NSLog(@"%@",[dateFormatter stringFromDate:[NSDate date]]);
        NSString* dateString = [NSString stringWithFormat:@"%@:00",[dateFormatter stringFromDate:[NSDate date]]];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        [manager.requestSerializer setValue:tokenID forHTTPHeaderField:@"tokenId"];
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];

        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:driverID,@"id",pickLatLoc,@"originLatitude",pickLongLoc,@"originLongitude",pickupAddress,@"originAddress",dropoffAddress,@"dropAddress",dropLatLoc,@"dropLatitude",dropLongLoc,@"dropLongitude",@"Start from an Inactive Ride",@"message",dateString,@"rideTime",@"Starting from Inactive Ride",@"title",nil];
        [params setValue:[NSNumber numberWithInt:4] forKey:@"seats"];
        [params setObject:[NSNumber numberWithBool:false] forKey:@"femaleOnly"];
        [params setValue:[NSNumber numberWithInt:5] forKey:@"pricePerMile"];

        NSString* URL_SIGNIN = @"http://ec2-52-74-6-189.ap-southeast-1.compute.amazonaws.com:8080/addMessage";
        
        [manager POST:URL_SIGNIN parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Success: %@", responseObject);
            
            NSString* message =responseObject[@"message"];
            
            if ([message isEqualToString:@"Message posted successfully."]) {
                NSString* messageBoardId =responseObject[@"messageBoardId"];
                [self joinTheMessageBoard:messageBoardId];
            }
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", [error localizedDescription]);
            
        }];
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
        });
    });
}


-(void)joinTheMessageBoard:(NSString*)messageBoardID{
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{

        NSString* pickLatLoc = [NSString stringWithFormat:@"%@", rideRequestDict[@"originLatitude"]];
        NSString*  pickLongLoc = [NSString stringWithFormat:@"%@", rideRequestDict[@"originLongitude"]];
        NSString* dropLatLoc = [NSString stringWithFormat:@"%@", rideRequestDict[@"destinationLatitude"]];
        NSString*  dropLongLoc = [NSString stringWithFormat:@"%@", rideRequestDict[@"destinationLongitude"]];

        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        //        [manager.requestSerializer setValue:user forHTTPHeaderField:@"tokenId"];
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        NSString* userNow = rideRequestDict[@"userId"];
        NSLog(@"User %@",userNow);
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:userNow,@"id",pickLatLoc,@"originLatitude",pickLongLoc,@"originLongitude",pickupAddress,@"originAddress",dropoffAddress,@"dropAddress",dropLatLoc,@"dropLatitude",dropLongLoc,@"dropLongitude",messageBoardID,@"messageBoardId",nil];
        [params setValue:[NSNumber numberWithInt:seats] forKey:@"seats"];
        
        NSString* URL_SIGNIN = @"http://ec2-52-74-6-189.ap-southeast-1.compute.amazonaws.com:8080/requestMessageBoard";
        
        [manager POST:URL_SIGNIN parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Success: %@", responseObject);
            
            NSString* message =responseObject[@"message"];
            
            if ([message isEqualToString:@"Request registered successfully."]) {
                [self startTheMessageBoardRide:messageBoardID];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", [error localizedDescription]);
            
        }];
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
        });
    });
}

- (void)startTheMessageBoardRide:(NSString*)messageBoardID{
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *token = [prefs stringForKey:@"token"];
        NSString *driverId = [prefs stringForKey:@"driverId"];
        int driverIdInt = [driverId intValue];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        [manager.requestSerializer setValue:token forHTTPHeaderField:@"tokenId"];
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        NSString* pickLatLoc = [NSString stringWithFormat:@"%@", rideRequestDict[@"originLatitude"]];
        NSString*  pickLongLoc = [NSString stringWithFormat:@"%@", rideRequestDict[@"originLongitude"]];
        NSString* URL = @"http://ec2-52-74-6-189.ap-southeast-1.compute.amazonaws.com:8080/startBoardRide";
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:messageBoardID,@"messageBoardId",pickLatLoc,@"latitude",pickLongLoc,@"longitude",nil];
        [params setValue:[NSNumber numberWithInt:driverIdInt] forKey:@"driverId"];
        
        [manager POST:URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"Success: %@", responseObject);
            
            NSString* message = responseObject[@"message"];
            NSString* rideId = responseObject[@"requestRideId"];
            
            if ([message isEqualToString:@"Message Board Ride started."]) {
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                [prefs setObject:rideId forKey:@"requestRideId"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForMessageBoardStartAccepted" object:nil];
                
            }
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", [error localizedDescription]);
            
        }];
        [self dismissViewControllerAnimated:YES completion:nil];
        
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            
            
        });
    });
    
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
