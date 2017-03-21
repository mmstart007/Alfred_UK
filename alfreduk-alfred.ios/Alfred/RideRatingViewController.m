

#import "RideRatingViewController.h"
#import <Parse/Parse.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "HUD.h"

@interface RideRatingViewController ()<UITableViewDataSource>{
    PFUser *ratedUser;
}


@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITableView *ratingTableView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation RideRatingViewController


@synthesize rideRequest;

- (void)viewDidLoad {

    [super viewDidLoad];

    if([[PFUser currentUser][@"UserMode"] boolValue]){
    
        //show driver info
        ratedUser = rideRequest[@"driver"];
        
    } else {
        //show user info
        ratedUser = rideRequest[@"passenger"];

    };
    assert(ratedUser!= nil);
    double price = [self.rideRequest[@"price"] doubleValue] /100;
    self.priceLabel.text = [NSString stringWithFormat:@"£%5.2lf",price];
    
    [ratedUser fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        [self.ratingTableView reloadData];
        NSString * firstName = ratedUser[@"FirstName"];
        NSString *lastName = ratedUser[@"LastName"];
        
        self.nameLabel.text  = [NSString stringWithFormat:@"%@ %@",firstName, lastName];
        
        //set profile pic
        
        self.rideCostLabel.text = [NSString stringWithFormat:@"Ride cost: £%4.2lf",[self.rideRequest[@"ridePrice"] doubleValue]/100];
        NSString *profilePicUrl = ratedUser[@"ProfilePicUrl"];
        
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

- (void)didChangeValue:(HCSStarRatingView *)sender {
    rating = sender.value;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)rateAction:(id)sender {
    
    bool isUser = [[PFUser currentUser][@"UserMode"] boolValue];
    PFObject *user;
    PFObject* ratingData;
    assert(rideRequest!= nil);
    if(isUser) {
        //rate the driver
        user= rideRequest[@"driver"];
        ratingData = user[@"driverRating"];
    }else{
        user = rideRequest[@"passenger"];
        ratingData = user[@"userRating"];
    }
    
    assert(ratingData!= nil);
    
    [HUD showUIBlockingIndicatorWithText:@"Rating ..."];
    [ratingData fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        double currentRating = [ratingData[@"rating"] doubleValue];
        int rideCount = [ratingData[@"rideCount"] intValue];
        
        double computeRate = [self computeRating];
        
        currentRating = currentRating * rideCount + computeRate;
        rideCount++;
        currentRating = currentRating / rideCount;
        ratingData[@"rideCount"] = [NSNumber numberWithInt:rideCount];
        ratingData[@"rating"] = [NSNumber numberWithDouble:currentRating];
        
        [ratingData saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(error){
                NSLog(@"Rating save failed =========================== \n %@", error.localizedDescription);
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"didEndedRating" object:nil];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }]; //ratingData saved
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
    
    if([[PFUser currentUser][@"UserMode"] boolValue]){
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
