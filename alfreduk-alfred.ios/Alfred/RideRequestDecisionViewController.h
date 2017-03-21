//
//  RideRequestDecisionViewController.h
//  Alfred
//
//  Created by Arjun Busani on 02/03/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RideRequestDecisionViewController : UIViewController
@property BOOL isAccepted;
@property BOOL openRatingView;

@property (weak, nonatomic) IBOutlet UIView *popUpView;
@property (weak, nonatomic) IBOutlet UITextView *decisionTextView;
@property (weak, nonatomic) IBOutlet UIView *supportTeamView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftLayoutConstraint;
@property(strong,nonatomic) NSString* decision;

- (IBAction)closeTheView:(id)sender;
- (IBAction)contactToSupport:(id)sender;

@end
