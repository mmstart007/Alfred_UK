


#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "RequestRidePopupViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "HUD.h"
#import "RideRequestDecisionViewController.h"
#import "DropoffAnnotation.h"
#import "CMMapLauncher.h"
#import "RideRatingViewController.h"
#import "UserAnnotation.h"

#import "HCSStarRatingView/HCSStarRatingView.h"


@interface DriverViewController : UIViewController<UIGestureRecognizerDelegate,MKMapViewDelegate,CLLocationManagerDelegate,UIActionSheetDelegate>
{
    BOOL mapChangedFromUserInteraction;
    BOOL isItRetrieval;
    double latitude;
    double driverLong;
}

@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;

@property (weak, nonatomic) IBOutlet UIButton *dropOffButton;
@property (weak, nonatomic) IBOutlet UIButton *startRideButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelRideButton;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *locationSearchButton;
@property (weak, nonatomic) IBOutlet UIButton *endMessageBoardButton;

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userMobile;

@property (weak, nonatomic) IBOutlet UIImageView *dropOffPinImage;
@property (weak, nonatomic) IBOutlet UIImageView *userProfilePic;
@property (weak, nonatomic) IBOutlet UIView *userView;
@property (weak, nonatomic) IBOutlet UIView *messageBoardUsersBGView;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutConstrint;

- (IBAction)startRideButtonTouchUpInside:(id)sender;
- (IBAction)callUser:(id)sender;
- (IBAction)centerOnUsersLocation:(id)sender;
- (IBAction)messageBoardUsers:(id)sender;
- (IBAction)rejectRideForUser:(id)sender;

@property(strong,nonatomic) NSTimer *driverLocationTimer;
@property(strong,nonatomic) NSTimer *cancelRideRequestTimer;
@property(strong,nonatomic) NSTimer *cancelRideTimer;

@property(strong,nonatomic) DropoffAnnotation *dropOffAnnotation;
@property(strong,nonatomic) RequestRidePopupViewController *requestRidePopupViewController;
@property(strong,nonatomic) RideRequestDecisionViewController *requestRideDecisionPopupViewController;

@property(strong,nonatomic) NSString *dropOffAddress;
@property(strong,nonatomic) NSString *userPhone;
@property(strong,nonatomic) NSString *rideID;

@property(strong,nonatomic) UIBarButtonItem *cancelButton;
@property(strong,nonatomic) CLLocationManager *locationManager;
@property(strong,nonatomic) MKRoute *routeDetails;

@property(nonatomic) MKCoordinateRegion region;

@end
