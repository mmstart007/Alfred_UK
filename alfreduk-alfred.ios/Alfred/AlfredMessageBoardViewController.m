//
//  AlfredMessageBoardViewController.m
//  Alfred
//
//  Created by Miguel Angel Carvajal on 7/15/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import <TWMessageBarManager/TWMessageBarManager.h>
#import <Parse/Parse.h>

#import "AlfredMessageBoardViewController.h"
#import "MessageBoardMessageTableViewCell.h"
#import "MessageBoardDriverDetailTableViewController.h"
#import "MessageBoardUserDetailTableViewController.h"
#import "MessageBoardPersonalUserTableViewController.h"
#import "MessageBoardPersonalDriverTableViewController.h"
#import "AlfredMessage.h"
#import "MDButton.h"
#import "MDConstants.h"
#import "RequestsTabViewController.h"
#import "AllMessageTabViewController.h"
#import "BookedRideTabViewController.h"
#import "MDTabBarViewController.h"
#import "SWRevealViewController.h"

@interface AlfredMessageBoardViewController () <UITabBarDelegate, UIActionSheetDelegate, MDTabBarViewControllerDelegate> {
    NSArray *messageData;
    bool inDriverMode;
    BOOL myMessages;
    AlfredMessage  * selectedMessageDict;
    NSString * city;
    NSArray *_rideJoinRequests;
    NSArray *_userBoardMessages;
}

@end

@implementation AlfredMessageBoardViewController

@synthesize locationManager;

- (void)viewDidLoad {

    [super viewDidLoad];
    
    MDTabBarViewController *tabBarViewController = [[MDTabBarViewController alloc] initWithDelegate:self];
    NSArray *names = @[@"All messages",@"Requests", @"Boooked rides"];

    [tabBarViewController setItems:names];
    tabBarViewController.tabBar.backgroundColor = [UIColor colorWithRed:80.0f/255 green:180.0f/255 blue:190.0f/255 alpha:1.0f];
    
    [self addChildViewController:tabBarViewController];
    [self.view addSubview:tabBarViewController.view];
    [tabBarViewController didMoveToParentViewController:self];
    
    UIView *controllerView = tabBarViewController.view;
    
    id<UILayoutSupport> rootTopLayoutGuide = self.topLayoutGuide;
    id<UILayoutSupport> rootBottomLayoutGuide = self.bottomLayoutGuide;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(rootTopLayoutGuide, rootBottomLayoutGuide, controllerView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[rootTopLayoutGuide]["@"controllerView][" @"rootBottomLayoutGuide]" options:0 metrics:nil views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[controllerView]|" options:0 metrics:nil views:viewsDictionary]];
    
    // Do any additional setup after loading the view.
    messageData = [[NSArray alloc] init];
    //global messages
    myMessages = NO;
    //get from preferences
    inDriverMode = ![[PFUser currentUser][ @"UserMode"] boolValue];
}

-(void)viewWillAppear:(BOOL)animated{

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

#pragma mark - UIActionSheet Delegate.
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{

    NSLog(@"Clicked button: %ld", (long)buttonIndex);
    
    switch (buttonIndex) {
        case 0:{//post as driver
            [self performSegueWithIdentifier:@"NewDriverMessageSegue" sender:self];
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
    if(index == 0){
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

//- (void)setScrollEnabled:(BOOL)enabled onPageViewController:(UIPageViewController *)pvc {
//    for (UIScrollView *view in pvc.view.subviews) {
//        if ([view isKindOfClass:[UIScrollView self]]) {
//            view.scrollEnabled = enabled;
//        }
//    }
//}

- (IBAction)postANewMessage:(id)sender {
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Posting a new message" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Post as driver", @"Post as passenger", nil];
    [sheet showInView:self.view];
}




@end
