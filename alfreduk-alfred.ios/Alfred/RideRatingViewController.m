

#import "RideRatingViewController.h"
#import <Parse/Parse.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "HUD.h"

@interface RideRatingViewController ()<UITableViewDataSource>{
    PFUser *ratedUser;
    NSString *endRideId;
    double price;
    int seats;
    BOOL isDriver;
    BOOL isDriverMessage;
}


@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITableView *ratingTableView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation RideRatingViewController


@synthesize rideRequest, rideMessage;
@synthesize isBoardMessage;

- (void)viewDidLoad {

    [super viewDidLoad];

    if (isBoardMessage) {
        PFUser *from, *to;
        from = rideMessage[@"from"];
        to = rideMessage[@"to"];
        PFObject *requestMessageObj = rideMessage[@"rideMessage"];
        endRideId = [rideMessage objectId];
        isDriverMessage = [requestMessageObj[@"driverMessage"] boolValue];
        
        if ([from.objectId isEqualToString:[[PFUser currentUser] objectId]]) {
            ratedUser = to;
            if(isDriverMessage) {
                isDriver = YES;
            } else {
                isDriver = NO;
            }
        } else {
            ratedUser = from;
            if(isDriverMessage) {
                isDriver = NO;
            } else {
                isDriver = YES;
            }
        }
        price = [self.rideMessage[@"price"] doubleValue];
        seats = [self.rideMessage[@"seats"] intValue];
        double totalPrice = price * seats;
        
        self.priceLabel.text = [NSString stringWithFormat:@"£%5.2lf",totalPrice];

    } else {
        if([[PFUser currentUser][@"UserMode"] boolValue]){
            
            //show driver info
            ratedUser = rideRequest[@"driver"];
            isDriver = YES;
            
        } else {
            //show user info
            ratedUser = rideRequest[@"passenger"];
            isDriver = NO;
        };
        assert(ratedUser!= nil);
        price = [self.rideRequest[@"price"] doubleValue] / 100;
        seats = [self.rideMessage[@"seats"] intValue];
        self.priceLabel.text = [NSString stringWithFormat:@"£%5.2lf",price];
    }

    [ratedUser fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        [self.ratingTableView reloadData];
        NSString * firstName = ratedUser[@"FirstName"];
        NSString *lastName = ratedUser[@"LastName"];
        
        self.nameLabel.text  = [NSString stringWithFormat:@"%@ %@",firstName, lastName];
        
        self.rideCostLabel.text = [NSString stringWithFormat:@"Ride cost: £%4.2lf",[self.rideRequest[@"ridePrice"] doubleValue]/100];
        NSString *profilePicUrl = ratedUser[@"ProfilePicUrl"];
        
        //set profile pic
        self.profilePicImageView.layer.cornerRadius = self.profilePicImageView.frame.size.width *0.5;
        self.profilePicImageView.layer.masksToBounds = YES;
        self.profilePicImageView.layer.borderWidth = 2.0f;
        self.profilePicImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        
        if (![profilePicUrl isKindOfClass:[NSNull class]]) {
            
            [self.profilePicImageView sd_setImageWithURL:[NSURL URLWithString:profilePicUrl] placeholderImage:[UIImage imageNamed:@"blank profile"]];
        }
        self.rate1View.maximumValue = self.rate2View.maximumValue = self.rate3View.maximumValue = 5;
        self.rate1View.minimumValue = self.rate2View.minimumValue = self.rate3View.minimumValue = 1;
        self.rate1View.value = self.rate2View.value = self.rate3View.value = 1;
        self.ratingTableView.dataSource = self;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)rateAction:(id)sender {
    
    double computeRate = [self computeRating];

    [HUD showUIBlockingIndicatorWithText:@"Rating ..."];

    [PFCloud callFunctionInBackground:@"CreateRating"
                       withParameters:@{@"to": ratedUser.objectId,
                                        @"isDriver": [NSNumber numberWithBool:isDriver],
                                        @"rating": [NSNumber numberWithDouble:computeRate],
                                        @"pricePerSeat": [NSNumber numberWithDouble:price],
                                        @"seats":[NSNumber numberWithInt:seats]}
                                block:^(NSString *success, NSError *error) {
                                    
                                    if(error) {
                                        NSLog(@"Rating save failed =========================== \n %@", error.localizedDescription);
                                    } else {

                                        if (isBoardMessage) {
                                            
                                            /* Delete ride message when user ended rate to each other. */
                                            [PFCloud callFunctionInBackground:@"DeleteRideMessage"
                                                               withParameters:@{@"deleteMessageObjId": endRideId,
                                                                                @"reason": @"END_RIDE_MESSAGE"}
                                                                        block:^(NSString *success, NSError *error) {
                                                                            
                                                                            [HUD hideUIBlockingIndicator];
                                                                            [self dismissViewControllerAnimated:YES completion:nil];
                                                                            if (!error) {
                                                                                
                                                                                NSLog(@"delete request board message sucessfully");
                                                                                
                                                                            } else {
                                                                                
                                                                                NSLog(@"Getting request message failed");
                                                                                
                                                                            }
                                            }];
                                        } else {
                                            [HUD hideUIBlockingIndicator];
                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"didEndedRating" object:nil];
                                            [self dismissViewControllerAnimated:YES completion:nil];
                                        }
                                    }
    }];
}

- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"RatingCell"];
    
    UILabel *titleLabel =(UILabel*) [cell viewWithTag:1];
    UILabel *subtitleLabel = (UILabel*)[cell viewWithTag:2];
    HCSStarRatingView *ratingView = (HCSStarRatingView*)[cell viewWithTag:3];
    
    if(![[PFUser currentUser][@"UserMode"] boolValue]) {
        //it is user
        switch (indexPath.row) {
            case 0:
                titleLabel.text = @"Punctuality";
                subtitleLabel.text = [NSString stringWithFormat:@"How punctual was %@?" ,ratedUser[@"FirstName"]];
                self.rate1View = ratingView;
                break;
            case 1:
                titleLabel.text = @"Driver Skills";
                subtitleLabel.text = @"How safe did you feel?";
                self.rate2View = ratingView;
                break;
            case 2:
                titleLabel.text = @"Cleanliness";
                subtitleLabel.text = @"Where your surroundings clean?";
                self.rate3View = ratingView;
                
                break;
            default:
                break;
        }
        
    }else{
        //it is driver
        switch (indexPath.row) {
            case 0:
                titleLabel.text = @"Punctuality";
                subtitleLabel.text = [NSString stringWithFormat:@"How punctual was %@?" ,ratedUser[@"FirstName"]];
                self.rate1View = ratingView;
                break;
            case 1:
                titleLabel.text = @"Friendliness";
                subtitleLabel.text = @"Did you enjoy driving this passenger?";
                self.rate2View = ratingView;
                break;
            case 2:
                titleLabel.text = @"Respectability";
                subtitleLabel.text = [NSString stringWithFormat:@
                                   "Was %@ Respectful of your car?", ratedUser[@"FirstName"]];
                self.rate3View = ratingView;
                break;
            default:
                break;
        }
    }
    
    return cell;
    
}

- (void)didChangeValue:(HCSStarRatingView *)sender {
    rating = sender.value;
}

-(double)computeRating {
    
    double rating1 = self.rate1View.value;
    double rating2 = self.rate2View.value;
    double rating3 = self.rate3View.value;
    
    return (rating1 + rating2 + rating3)/3;

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
