//
//  AlfredMessageBoardViewController.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 7/15/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "TWMessageBarManager.h"
#import <Parse/Parse.h>

#import "AlfredMessageBoardViewController.h"
#import "MessageBoardMessageTableViewCell.h"
#import "MessageBoardDriverDetailTableViewController.h"
#import "MessageBoardUserDetailTableViewController.h"
#import "MessageBoardPersonalUserTableViewController.h"
#import "MessageBoardPersonalDriverTableViewController.h"
#import "RideRatingViewController.h"
#import "AlfredMessage.h"
#import "MDButton.h"
#import "MDConstants.h"
#import "RequestsTabViewController.h"
#import "AllMessageTabViewController.h"
#import "BookedRideTabViewController.h"
#import "MDTabBarViewController.h"
#import "SWRevealViewController.h"

const int RIDE_END_EXPIRATION_TIME = 1*60; // in seconds

@interface AlfredMessageBoardViewController () <UITabBarDelegate, UIActionSheetDelegate, MDTabBarViewControllerDelegate> {
    
    MDTabBarViewController *tabBarViewController;
    
    NSArray *messageData;
    NSTimer *endRideTimer;
    NSString *endRideId;
    PFObject *selectedMessage;
    NSString *coast;
    NSUserDefaults *userDefault;
}

@end

@implementation AlfredMessageBoardViewController

@synthesize requestRideDecisionPopupViewController;


- (void)viewDidLoad {

    [super viewDidLoad];
    
    userDefault = [NSUserDefaults standardUserDefaults];
    
    tabBarViewController = [[MDTabBarViewController alloc] initWithDelegate:self];
    NSArray *names = @[@"All messages",@"Requests", @"Boooked rides"];
    
    [tabBarViewController setItems:names];
    tabBarViewController.tabBar.backgroundColor = [UIColor colorWithRed:80.0f/255 green:180.0f/255 blue:190.0f/255 alpha:1.0f];
    
    [self addChildViewController:tabBarViewController];
    [self.view addSubview:tabBarViewController.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForCreateBoardMessage:) name:@"didRequestForCreateBoardMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForRequestPriceBoardMessage:) name:@"didRequestForRequestPriceBoardMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForAcceptBoardMessage:) name:@"didRequestForAcceptBoardMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForDeleteBoardMessage:) name:@"didRequestForDeleteBoardMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForAutoDeclineBoardMessage:) name:@"didRequestForAutoDeclineBoardMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForEndBoardMessage:) name:@"didRequestForEndBoardMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForOpenRatingView:) name:@"didRequestForOpenRatingView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForGetSelectedMessageObject:) name:@"didRequestForGetSelectedMessageObject" object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated{

    [tabBarViewController didMoveToParentViewController:self];
    
    UIView *controllerView = tabBarViewController.view;
    
    id<UILayoutSupport> rootTopLayoutGuide = self.topLayoutGuide;
    id<UILayoutSupport> rootBottomLayoutGuide = self.bottomLayoutGuide;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(rootTopLayoutGuide, rootBottomLayoutGuide, controllerView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[rootTopLayoutGuide]["@"controllerView][" @"rootBottomLayoutGuide]" options:0 metrics:nil views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[controllerView]|" options:0 metrics:nil views:viewsDictionary]];

    UIImage *drawerImage = [[UIImage imageNamed:@"menu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:drawerImage
                                                                         style:UIBarButtonItemStylePlain target:self.revealViewController action:@selector(revealToggle:)];
    UIImage *addImange = [[UIImage imageNamed:@"add"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithImage:addImange
                                                                         style:UIBarButtonItemStylePlain target:self action:@selector(postANewMessage:)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    self.navigationItem.rightBarButtonItem = addButtonItem;
    self.navigationItem.title = @"Message Board";
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:80.0f/255 green:180.0f/255 blue:190.0f/255 alpha:1.0f];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Push Notifications.
-(void)didRequestForCreateBoardMessage:(NSNotification *)notification {
    NSString *pushMessage = [notification object];
    
    [self showPushView:pushMessage acceptedStatus:NO ratingView:NO];
}

-(void)didRequestForRequestPriceBoardMessage:(NSNotification *)notification {
    NSString *pushMessage = [notification object];

    [self showPushView:pushMessage acceptedStatus:NO ratingView:NO];
}

- (void)didRequestForAcceptBoardMessage:(NSNotification *)notification {
    
    NSArray *arrObject = [notification object];
    NSString *pushMessage = [arrObject firstObject];
    endRideId = arrObject[1];

    [self showPushView:pushMessage acceptedStatus:YES ratingView:NO];
    
    PFQuery *requestMessageQuery = [PFQuery queryWithClassName:@"RequestMessage"];
    [requestMessageQuery includeKey:@"from"];
    [requestMessageQuery includeKey:@"to"];
    [requestMessageQuery includeKey:@"rideMessage"];
    [requestMessageQuery whereKey:@"objectId" equalTo:endRideId];
    [requestMessageQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error) {
            selectedMessage = objects.firstObject;
            coast = [NSString stringWithFormat:@"Ride Cost: £%.1f", [selectedMessage[@"price"] doubleValue]];;
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Alfred" message:@"Can't get the message right now." delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil] show];
        }
    }];
    
    
    [endRideTimer invalidate];
    endRideTimer = [NSTimer scheduledTimerWithTimeInterval: RIDE_END_EXPIRATION_TIME
                                                    target: self
                                                  selector: @selector(didEndRide:)
                                                  userInfo: nil
                                                   repeats: NO];

}

- (void)didRequestForDeleteBoardMessage:(NSNotification *)notification {
    [endRideTimer invalidate];
    NSString *pushMessage = [notification object];

    [self showPushView:pushMessage acceptedStatus:NO ratingView:NO];
}

- (void)didRequestForEndBoardMessage:(NSNotification *)notification {

    [self showPushView:coast acceptedStatus:NO ratingView:YES];
}

- (void)didRequestForAutoDeclineBoardMessage:(NSNotification *)notification {
    NSString *pushMessage = [notification object];

    [self showPushView:pushMessage acceptedStatus:NO ratingView:NO];
}

- (void)didRequestForGetSelectedMessageObject:(NSNotification *)notification {
    
    NSDictionary *dict = notification.userInfo;
    selectedMessage = [dict valueForKey:@"messageInfo"];
    double price = [selectedMessage[@"price"] doubleValue];
    coast = [NSString stringWithFormat:@"Ride Cost: £%.1f", price];
}

- (void)showPushView:(NSString *)description acceptedStatus:(BOOL)isAccepted ratingView:(BOOL)openRatingView {
    
    requestRideDecisionPopupViewController = [[RideRequestDecisionViewController alloc] initWithNibName:@"RideRequestDecisionViewController" bundle:nil];
    requestRideDecisionPopupViewController.decision = description;
    requestRideDecisionPopupViewController.isAccepted = isAccepted;
    requestRideDecisionPopupViewController.openRatingView = openRatingView;
    [requestRideDecisionPopupViewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:requestRideDecisionPopupViewController animated:YES completion:nil];
}

-(void)didRequestForOpenRatingView:(NSNotification *)notification {
    [NSTimer scheduledTimerWithTimeInterval: 0.5 target: self
                                   selector: @selector(openRatingView:) userInfo: nil repeats: NO];
}

-(void)openRatingView:(id)sender {
    
    [self performSegueWithIdentifier:@"rateUser" sender:nil];
}

- (void)didEndRide:(id)sender {
    
    [HUD showUIBlockingIndicatorWithText:@"Endining..."];
    [PFCloud callFunctionInBackground:@"DeleteRideMessage"
                       withParameters:@{@"deleteMessageObjId": endRideId,
                                        @"reason": @"END_RIDE_MESSAGE"}
                                block:^(NSString *success, NSError *error) {
                                    [HUD hideUIBlockingIndicator];
                                    if (!error) {
                                        
                                        NSLog(@"total coast for rating with local ========= %@", coast);
                                        [self showPushView:coast acceptedStatus:NO ratingView:YES];
                                        
                                        NSLog(@"delete request board message sucessfully");
                                        
                                    } else {
                                        
                                        NSLog(@"Getting request message failed");
                                        
                                        [[[UIAlertView alloc] initWithTitle:@"Alfred" message:@"Can't delete the messages right now." delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:nil, nil] show];
                                    }
                                }];
}

#pragma mark - UIActionSheet Delegate.
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{

    NSLog(@"Clicked button: %ld", (long)buttonIndex);
    
    switch (buttonIndex) {
        case 0:{//post as driver
            if ([[PFUser currentUser][@"EnabledAsDriver"] boolValue]) {
                [self performSegueWithIdentifier:@"NewDriverMessageSegue" sender:self];
            } else {
                [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Alfred"
                                                               description:@"You should register as Driver."
                                                                      type:TWMessageBarMessageTypeError
                                                                  duration:3.0];
            }
            break;
        }
        case 1:{//post as passenger
            [self performSegueWithIdentifier:@"NewPassengerMessageSegue" sender:self];
            break;
        }
        default:
            break;
    }
}

- (UIViewController *)tabBarViewController:(MDTabBarViewController *)viewController viewControllerAtIndex:(NSUInteger)index{
    
    UIStoryboard * main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if(index == 0) {
        AllMessageTabViewController *controller = [main instantiateViewControllerWithIdentifier:@"AllMessageTabViewController"];
        return controller;
    } else if(index == 1) {
        RequestsTabViewController *controller = [main instantiateViewControllerWithIdentifier:@"RequestsTabViewController"];
        return controller;
    } else {
        BookedRideTabViewController *controller = [main instantiateViewControllerWithIdentifier:@"BookedRideTabViewController"];
        return controller;
    }
}

- (void)setScrollEnabled:(BOOL)enabled onPageViewController:(UIPageViewController *)pvc {
    for (UIScrollView *view in pvc.view.subviews) {
        if ([view isKindOfClass:[UIScrollView self]]) {
            view.scrollEnabled = enabled;
        }
    }
}

- (IBAction)postANewMessage:(id)sender {
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Posting a new message" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Post as driver", @"Post as passenger", nil];
    [sheet showInView:self.view];
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString: @"rateUser"]) {
        
        RideRatingViewController *vc =(RideRatingViewController*)[segue destinationViewController];
        
        //rate only last user, this is wrong
        //NSLog(@"Rate to the Passenger =================== /n %@ /n ======================= %@", _lastRideInfo, passenger);
        vc.rideMessage = selectedMessage;
        vc.isBoardMessage = YES;
    }
}



@end
