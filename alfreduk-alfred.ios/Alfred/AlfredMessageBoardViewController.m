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
#import "MessageBoardLogoTableViewCell.h"
#import "MessageBoardDriverDetailTableViewController.h"
#import "MessageBoardUserDetailTableViewController.h"
#import "MessageBoardPersonalUserTableViewController.h"
#import "MessageBoardPersonalDriverTableViewController.h"
#import "AlfredMessage.h"
#import "MDButton.h"
#import "MDConstants.h"
#import "FirstTabViewController.h"
#import "SecondTabViewController.h"
#import "ThirdTabViewController.h"
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
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@""
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:nil
                                                                           action:nil];
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
//    SWRevealViewController *revealViewController = self.revealViewController;
//    if ( revealViewController ) {
//        [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
//        [self.navigationItem.leftBarButtonItem setTarget:self.revealViewController];
//        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
//    }
    /*CGRect  frame = self.view.bounds;
    CGFloat width = 60;
    CGFloat height = 60;
    MDButton *floatingButton = [[MDButton alloc] initWithFrame:CGRectMake(frame.size.width - 20 - width, frame.size.height - 100 - height, height, height) type:MDButtonTypeFloatingAction rippleColor:[UIColor clearColor]];
    floatingButton.backgroundColor =  [UIColor colorWithRed:80.0f/255 green:180.0f/255 blue:190.0f/255 alpha:1.0f];
    [floatingButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [floatingButton addTarget:self action:@selector(postANewMessage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:floatingButton]; */
    
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationController.navigationItem.backBarButtonItem.title =  @"";
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

-(void)loadCityMessages:(NSString*)city {
    
    PFQuery *query = [PFQuery queryWithClassName:@"BoardMessage"];
    [query includeKey:@"author"]; //load user data also
    [query includeKey:@"author.userRating"];
    [query includeKey:@"author.driverRating"];
    [HUD showUIBlockingIndicator];
    [query  findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [HUD hideUIBlockingIndicator];
        if(!error){
            messageData = objects;
            
            if(objects.count == 0) {
                self.tableView.hidden = YES;
                return ;
            } else {
                self.tableView.hidden = NO;
                [self.tableView reloadData];
            }
        } else {
            if(error.code == 209){
                //TODO: Login user again
            }
            self.tableView.hidden = YES;
            messageData = nil;
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Ooops! "
                                                           description:@"Can't get messages right now."
                                                                  type:TWMessageBarMessageTypeError];
            NSLog(@"Failed to get city messages");
        }
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(self.segmentFilterControl.selectedSegmentIndex == 1){
        // all messages
        return 2;
    } else {
        //my messages
        return 1;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(self.segmentFilterControl.selectedSegmentIndex == 0){
        selectedMessageDict = messageData[indexPath.row];
        bool driverMessage = [selectedMessageDict[@"driverMessage"] boolValue];
        if (!driverMessage) {
            [self performSegueWithIdentifier:@"MessageBoardUserDetailSegueID" sender:self];
        } else {
            [self performSegueWithIdentifier:@"MessageBoardDriverDetailSegueID" sender:self];
        }
    } else {
        if(indexPath.section == 0){
            //this is for driver mode
            if(inDriverMode) {
                selectedMessageDict = _rideJoinRequests[indexPath.row];
                [self performSegueWithIdentifier:@"MessageBoardUserDetailSegueID" sender:self];
            } else {
                
            }
        } else {
            //here should allow u to edit messages
            selectedMessageDict = _userBoardMessages[indexPath.row];
            //check message type
            bool driverMessage  = [selectedMessageDict[@"driverMessage"] boolValue];
            
            if(driverMessage){
                [self performSegueWithIdentifier:@"MessageBoardPersonalDriverDetailSegueID" sender:self];
            } else {
                [self performSegueWithIdentifier:@"MessageBoardPersonalUserDetailSegueID" sender:self];
                
            }
        }
    }
}

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
        SecondTabViewController *controller = [main instantiateViewControllerWithIdentifier:@"SecondTabViewController"];
        return controller;
    } else if(index == 1) {
        FirstTabViewController *controller = [main instantiateViewControllerWithIdentifier:@"FirstTabViewController"];
        return controller;
    } else {
        ThirdTabViewController *controller = [main instantiateViewControllerWithIdentifier:@"ThirdTabViewController"];
        return controller;
    }
}

- (IBAction)postANewMessage:(id)sender {
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Posting a new message" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Post as driver", @"Post as passenger", nil];
    [sheet showInView:self.view];
}

- (IBAction)changeMessagesFilter:(id)sender {
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"MessageBoardPersonalDriverDetailSegueID"]){
        MessageBoardPersonalDriverTableViewController *vc = [segue destinationViewController];
        vc.selectedMessage = selectedMessageDict;
    }
    if ([[segue identifier] isEqualToString:@"MessageBoardPersonalUserDetailSegueID"]){
        MessageBoardPersonalUserTableViewController *vc = [segue destinationViewController];
        vc.selectedMessage = selectedMessageDict;
    }
    if ([[segue identifier] isEqualToString:@"MessageBoardDriverDetailSegueID"]){
        MessageBoardDriverDetailTableViewController *vc = [segue destinationViewController];
        vc.selectedMessage = selectedMessageDict;
    }
    if ([[segue identifier] isEqualToString:@"MessageBoardUserDetailSegueID"]){
        MessageBoardUserDetailTableViewController *vc = [segue destinationViewController];
        vc.selectedMessage = selectedMessageDict;
    }
}




@end
