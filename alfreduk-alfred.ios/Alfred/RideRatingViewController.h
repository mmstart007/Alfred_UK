

#import <UIKit/UIKit.h>
#import "HCSStarRatingView.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import <Parse/Parse.h>



@interface RideRatingViewController : UIViewController{
    float rating;
}

@property (weak, nonatomic) IBOutlet UILabel *rideCostLabel;

- (IBAction)rateAction:(id)sender;

@property(strong,nonatomic)PFObject *rideRequest;




@property (weak, nonatomic) IBOutlet UIImageView *profilePicImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profileBackgroundImageView;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *rate1View;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *rate2View;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *rate3View;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;


@end
