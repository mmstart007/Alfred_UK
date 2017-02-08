//
//  DriverCalloutNotActiveViewController.h
//  Alfred
//
//  Created by Arjun Busani on 09/04/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DriverCalloutNotActiveViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *picImageView;
@property (weak, nonatomic) IBOutlet UILabel *seatsLabel;
- (IBAction)requestAlfred:(id)sender;
- (IBAction)dismissAlfred:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *picLayoutConstraint;


@property(nonatomic,strong)NSString* requestRideId;
@property(nonatomic,strong)NSString* availbleSeats;

@property(nonatomic,strong)NSString* driverRating;
@property(nonatomic,strong)NSString* driverMobile;
@property(nonatomic,strong)NSString* driverProfilePic;
@property(strong,nonatomic) NSString *driverName;
@property(nonatomic,strong) NSString * driverID;
@end
