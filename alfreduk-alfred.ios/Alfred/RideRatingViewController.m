

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
       
                ratedUser =  self.rideRequest[@"driver"];
        
    
    }else{
        //show user info
        ratedUser = self.rideRequest[@"requestedBy"];

    };
    assert(ratedUser!= nil);
    double price = [self.rideRequest[@"ridePrice"] doubleValue] /100;
    
    
    self.priceLabel.text = [NSString stringWithFormat:@"%5.2lf £",price];
    
    
    CGRect frame = self.contentView.layer.frame;
    frame.size.width = self.view.bounds.size.width ;
    self.contentView.layer.frame = frame;
    
    [ratedUser fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        [self.ratingTableView reloadData];
        NSString * firstName = ratedUser[@"FirstName"];
        NSString *lastName = ratedUser[@"LastName"];
        
        self.nameLabel.text  = [NSString stringWithFormat:@"%@ %@",firstName, lastName];
        
        
        //set profile pic
        
        self.rideCostLabel.text = [NSString stringWithFormat:@"Ride cost: %4.2lf £",[self.rideRequest[@"ridePrice"] doubleValue]/100];
        
        
        NSString *profilePicUrl = ratedUser[@"ProfilePicUrl"];
        
        self.profilePicImageView.layer.cornerRadius = self.profilePicImageView.frame.size.width *0.5;
        self.profilePicImageView.layer.masksToBounds = YES;
        self.profilePicImageView.layer.borderWidth = 2.0f;
        self.profilePicImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        
        
        if (![profilePicUrl isKindOfClass:[NSNull class]]) {
            
            [self.profilePicImageView sd_setImageWithURL:[NSURL URLWithString:profilePicUrl] placeholderImage:[UIImage imageNamed:@"blank profile"]];
        }
        // [self.profilePicImageView sd_setImageWithURL:[NSURL URLWithString:profilePicUrl] placeholderImage:[UIImage imageNamed:@"blanck profile"]];
        
        
        
        
        self.rate1View.maximumValue = self.rate2View.maximumValue = self.rate3View.maximumValue = 5;
        self.rate1View.minimumValue = self.rate2View.minimumValue = self.rate3View.minimumValue = 1;
        self.rate1View.value = self.rate2View.value = self.rate3View.value = 1;
        
        
     
        
        self.ratingTableView.dataSource = self;
       

        //[HUD showConfirmationWithText:@"completed" delay:3];
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
    
   
    
    [self rateTheRide];
    

    
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

-(double)computeRating{
    double rating1 = self.rate1View.value;
    double rating2 = self.rate2View.value;
    double rating3 = self.rate3View.value;
    
    return (rating1 + rating2 + rating3)/3;

}
-(void)rateTheRide{
    

    bool isUser = [[PFUser currentUser][@"UserMode"] boolValue];
    PFObject *user;
    PFObject* ratingData;
    assert(self.rideRequest!= nil);
    if(isUser) {
        
        //rate the driver
        
        
        user= self.rideRequest[@"driver"];
        ratingData = user[@"driverRating"];
       
        
    }else{
        user = self.rideRequest[@"requestedBy"];

        ratingData = user[@"userRating"];
    }
    

     assert(ratingData!= nil);

    [HUD showUIBlockingIndicator];
    [ratingData fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        
       
        double currentRating = [ ratingData[@"rating"] doubleValue];
        int rideCount = [ratingData[@"rideCount"] intValue];
        
        
        double rating = [self computeRating];
        
        currentRating = currentRating * rideCount + rating;
        rideCount++;
        currentRating = currentRating/rideCount;
        ratingData[@"rideCount"] = [NSNumber numberWithInt:rideCount];
        ratingData[@"rating"] = [NSNumber numberWithDouble:currentRating];
        
        
        [ratingData saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            

            if(error){
                [HUD hideUIBlockingIndicator];
                NSLog(@"%@", error.localizedDescription);
            }else{
                
                self.rideRequest[@"rated"] = @YES;
                [self.rideRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    [HUD hideUIBlockingIndicator];
                    if(succeeded){
                        [self dismissViewControllerAnimated:YES completion:nil];
                        
                    }else{
                        NSLog(@"Failed to save ride rating for ride %@", self.rideRequest.objectId);
                        NSLog(@"%@", error.localizedDescription);
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Something went wrong and we couldn't send your feedback.\nPlease try again" delegate:nil cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil];
                        [alert show];
                        
                    }
                }];
                
            }
            
            
        }]; //ratingData saved
        
    }];
    
    
    
    
    
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
