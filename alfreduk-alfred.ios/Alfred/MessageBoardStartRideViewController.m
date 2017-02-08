//
//  MessageBoardStartRideViewController.m
//  Alfred
//
//  Created by Arjun Busani on 03/04/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "MessageBoardStartRideViewController.h"

@interface MessageBoardStartRideViewController ()

@end

@implementation MessageBoardStartRideViewController
@synthesize topLayoutConstraint,bottomLayoutConstraint,messageBoardDict,latNow,longNow;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.popupView.layer.cornerRadius = 0.5;
    self.popupView.layer.shadowOpacity = 0.8;
    self.popupView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ){
        
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        if( screenHeight < screenWidth ){
            screenHeight = screenWidth;
        }
        
        if( screenHeight > 480 && screenHeight < 667 ){
            topLayoutConstraint.constant = 40;
            bottomLayoutConstraint.constant = 40;
            
        } else if ( screenHeight > 480 && screenHeight < 736 ){
            topLayoutConstraint.constant = 90;
            bottomLayoutConstraint.constant = 90;
            
            
            
        } else if ( screenHeight > 480 ){
            topLayoutConstraint.constant = 120;
            bottomLayoutConstraint.constant = 120;
            
            
        } else {
            topLayoutConstraint.constant = 5;
            bottomLayoutConstraint.constant =5;
            
            
        }
    }
    
    else{
        topLayoutConstraint.constant = 270;
        bottomLayoutConstraint.constant = 270;
        self.leftLayoutConstraint.constant = 210;
        self.rightLayoutConstraint.constant = 210;
        
    }
    
    NSString* rideTime = messageBoardDict[@"rideTime"];
    int seats = [messageBoardDict[@"seats"] intValue];
    NSString* dropAddress = messageBoardDict[@"dropAddress"];
    NSString* originAddress = messageBoardDict[@"originAddress"];
    int pricePerMile = [messageBoardDict[@"pricePerMile"] intValue];
    NSString* title = messageBoardDict[@"title"];
    NSString* message = messageBoardDict[@"message"];
    int femaleOnly = [messageBoardDict[@"femaleOnly"] intValue];
    
    [self.titleLabel setText:title];
    [self.pickupLabel setText:originAddress];
    [self.dropoffLabel setText:dropAddress];
    [self.timeLabel setText:rideTime];
    [self.messageTextView setText:message];
    [self.messageTextView setTextAlignment:NSTextAlignmentCenter];
    [self.seatsLabel setText:[NSString stringWithFormat:@"%d",seats]];
    [self.priceLabel setText:[NSString stringWithFormat:@"%d/mile",pricePerMile]];
    
    if (femaleOnly==1) {
        [self.maleImageView setHidden:YES];
        
    }
    
    

    

    // Do any additional setup after loading the view from its nib.
}
- (IBAction)startTheRide:(id)sender {
    
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
        
        NSString* messageBoardId = messageBoardDict[@"messageId"];
        
        NSString* URL = @"http://ec2-52-74-6-189.ap-southeast-1.compute.amazonaws.com:8080/startBoardRide";
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:messageBoardId,@"messageBoardId",latNow,@"latitude",longNow,@"longitude",nil];
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
