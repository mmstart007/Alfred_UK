//
//  ProfileTableViewController.h
//  Alfred
//
//  Created by Arjun Busani on 26/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "HUD.h"
#import "HCSStarRatingView/HCSStarRatingView.h"


@interface ProfileTableViewController : UITableViewController<UIGestureRecognizerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profilePicImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingView;
@property (weak, nonatomic) IBOutlet UILabel *mailLabel;

@property (weak, nonatomic) IBOutlet UILabel *ridesAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
- (IBAction)updateProfile:(id)sender;
- (IBAction)editProfile:(id)sender;


@end
