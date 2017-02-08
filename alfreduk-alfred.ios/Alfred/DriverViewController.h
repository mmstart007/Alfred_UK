


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
#import "MessageBoardStartRideViewController.h"
#import "MessageBoardUsersViewController.h"
#import "UserAnnotation.h"

#import "HCSStarRatingView/HCSStarRatingView.h"


@interface DriverViewController : UIViewController<UIGestureRecognizerDelegate,MKMapViewDelegate,CLLocationManagerDelegate,UIActionSheetDelegate>
{
    BOOL mapChangedFromUserInteraction;
    double latitude;
    double driverLong;
    BOOL isItRetrieval;

}
@property (weak, nonatomic) IBOutlet UIButton *locationSearchButton;

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;

- (IBAction)startRideButtonTouchUpInside:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *dropOffButton;
@property (weak, nonatomic) IBOutlet UIImageView *dropOffPinImage;



@property (weak, nonatomic) IBOutlet UIButton *endMessageBoardButton;
@property (weak, nonatomic) IBOutlet UIView *messageBoardUsersBGView;
- (IBAction)messageBoardUsers:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *cancelRideButton;
@property (weak, nonatomic) IBOutlet UIButton *callButton;

@property(strong,nonatomic)MessageBoardUsersViewController *messageBoardUsersViewController;

@property (weak, nonatomic) IBOutlet UIView *userView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutConstrint;
@property (weak, nonatomic) IBOutlet UIImageView *userProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userMobile;
@property (weak, nonatomic) IBOutlet UILabel *userRating;

@property(strong,nonatomic) NSString* userPhone;

- (IBAction)rejectRideForUser:(id)sender;
- (IBAction)callUser:(id)sender;

@property(strong,nonatomic)RideRatingViewController *rideRatingViewController;

@property BOOL isDriverAccepted;
@property double userLat,userLong;
@property double destLat,destLong;

@property double driverStartLat,driverStartLong;

@property(strong,nonatomic)RideRequestDecisionViewController *requestRideDecisionPopupViewController;

@property(strong,nonatomic)RequestRidePopupViewController *requestRidePopupViewController;

@property(strong,nonatomic)MessageBoardStartRideViewController *messageBoardStartRideViewController;

@property(strong,nonatomic)    NSString* pickupAddress;
@property(strong,nonatomic)    NSString* dropoffAddress;

@property(strong,nonatomic)    NSString* rideID;

@property(strong,nonatomic)CLPlacemark *pickupPlacemark;
@property(strong,nonatomic)CLPlacemark *dropoffPlacemark;

@property(strong,nonatomic)NSArray *rideEndArray;
@property (strong,nonatomic)NSArray* rideRequestArray;

@property(strong,nonatomic) NSTimer *calucaltateDistanceTimer;
@property CLLocationDistance driverDistanceTravelled;
@property double distanceCovered;

@property(strong,nonatomic) NSTimer *driverLocationTimer;
@property (strong,nonatomic)NSString* driverLatLoc;
@property (strong,nonatomic)NSString* driverLongLoc;

@property(nonatomic)CLLocationCoordinate2D pickUpCoord;

@property(nonatomic)CLLocationCoordinate2D dropOffCoord;
@property(strong,nonatomic)DropoffAnnotation *dropOffAnnotation;
@property(strong,nonatomic)NSString *dropOffAddress;

@property(strong,nonatomic)MKRoute *routeDetails;

@property (strong,nonatomic)NSString* userCity;

@property(strong,nonatomic)UIBarButtonItem *cancelButton;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property(nonatomic)MKCoordinateRegion region;

@property (weak, nonatomic) IBOutlet UILabel *currentLocationLabel;
- (IBAction)centerOnUsersLocation:(id)sender;

@property(strong,nonatomic)NSString *currentAddress;
@property (weak, nonatomic) IBOutlet UIButton *startRideButton;

@property(strong,nonatomic)NSDictionary* messageBoardDict;
@property(strong,nonatomic)NSDictionary* selectedUserDict;
@property PFObject *driverStatus;

@end
