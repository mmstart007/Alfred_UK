//
//  SideMenuTableViewController.m
//  Alfred
//
//  Created by Arjun Busani on 24/01/15.
//  Copyright (c) 2015 A Ascendanet Sun. All rights reserved.
//

#import "SideMenuTableViewController.h"
#import "SideBottomTableViewCell.h"
#import "SideLogoTableViewCell.h"
#import "SideMenuTableViewCell.h"
#import "SideProfileTableViewCell.h"
#import "SWRevealViewController.h"
#import "RiderViewController.h"
#import "DriverRegistrationCarViewController.h"
#import "ProfileTableViewController.h"
#import "RidesHistoryTableViewController.h"
#import "ShareTableViewController.h"
#import "MDSnackbar.h"
#import "RedeemRewardsTableViewController.h"
#import "SideMenuDriverTableViewCell.h"
#import "DriverViewController.h"
#import "AlfredMessageBoardViewController.h"
#import "WalletViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Parse/Parse.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "AlfredLoginViewController.h"

#import "AboutViewController.h"



@interface SideMenuTableViewController () <UITableViewDelegate, MFMailComposeViewControllerDelegate, MDSnackbarDelegate>{
    
    UIButton * issueButton;
    UIButton * aboutButton;
    UIButton *feedbackButton;
    PFObject *_driverStatus;
    PFUser *_currentUser;
    
}


@end

@implementation SideMenuTableViewController
@synthesize name,driverSwitch,messageBoardDict,profilePic,storyboardType;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _currentUser = [PFUser currentUser];
    _driverStatus = [PFUser currentUser][@"driverStatus"];
    
    storyboardType = @"Main";
    
    
    
    name = [PFUser currentUser][@"FullName"];
    profilePic =[PFUser currentUser][@"ProfilePicUrl"];
    
    
    
    //self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu bg"]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRequestForDriverMode:) name:@"didRequestForDriverMode" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeEnabledAsDriver) name:@"didBecomeEnabledAsDriver" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeDisabledAsDriver) name:@"didBecomeDisabledAsDriver" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeUserProfile:) name:@"didChangedUserImage" object:nil];
    
    self.tableView.delegate = self;
    
    
    
}

-(void)didBecomeEnabledAsDriver{
    
    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        [self.tableView reloadData];
    }];
    
    
}

-(void)didBecomeDisabledAsDriver{
    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        self.driverSwitch.on = false;
        [self driverSwitch:nil];
        
    }];
    
    
}


-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if(error == nil){
            [self.tableView reloadData];
        }else{
            if(error.code == kPFErrorInvalidSessionToken){
                //logout user and prompt for login again
                [PFUser logOut];
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                AlfredLoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginId"];
                [self presentViewController:loginViewController animated:YES completion:nil];
                
            }
            
        }
        
        
    }];
}
-(void)didChangeUserProfile:(id)object{
    
    
    name = [PFUser currentUser][@"FullName"];
    profilePic = [PFUser currentUser][@"ProfilePicUrl"];
    [self.tableView reloadData];
    
    
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didRequestForDriverMode" object:nil];
    
}

-(void)didRequestForDriverMode:(NSNotification *)notification{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    messageBoardDict = [notification object];
    
    
    [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self
                                   selector: @selector(didRequestForMessageBoardStartRide:) userInfo: nil repeats: NO];
    
    
    
    [self.driverSwitch setOn:YES animated:NO];
    [prefs setBool:NO forKey:@"UserMode"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self homeButton:self];
    
    
}

-(void)didRequestForMessageBoardStartRide:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didRequestForMessageBoardStartRide" object:messageBoardDict];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section==0) {
        return 2;
    }
    else if (section==1){
        return 1;
    }
    else if (section==2){
        return 6;
    }
    else
        return 6;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SideLogoTableViewCell";
    SideLogoTableViewCell *cell = (SideLogoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SideLogoTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    if ([indexPath section]==0) {
        if (indexPath.row==0) {
            cell.logoView.hidden = YES;
            
        }
        
        if (indexPath.row==1) {
            cell.logoView.hidden = NO;
            
        }
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        
    }
    
    if ([indexPath section]==1) {
        static NSString *simpleTableIdentifier = @"SideProfileTableViewCell";
        SideProfileTableViewCell *cell = (SideProfileTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SideProfileTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        if(name == Nil){
            NSLog(@"Error: User name is nil");
            name = @"Miguel Carvajal";
        }
        
        cell.profileImageView.layer.cornerRadius = cell.profileImageView.layer.frame.size.width/2;
        cell.profileImageView.layer.masksToBounds = YES;
        [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:profilePic] placeholderImage:[UIImage imageNamed:@"blank profile"]];
        
        
        [cell.profileNameLabel setText:name];
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        
        return cell;
    }
    
    if ([indexPath section]==2) {
        static NSString *simpleTableIdentifier = @"SideMenuTableViewCell";
        SideMenuTableViewCell *cell = (SideMenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SideMenuTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        
        
        if (indexPath.row == 0) {
            UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(30.0f, 0, cell.bounds.size.width-70.0f, 0.6f)];
            topLineView.backgroundColor = [UIColor grayColor];
            [cell.contentView addSubview:topLineView];
        }
        
        UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(30.0f, cell.bounds.size.height, cell.bounds.size.width-70.0f, 0.6f)];
        bottomLineView.backgroundColor = [UIColor grayColor];
        [cell.contentView addSubview:bottomLineView];
        
        
        if (indexPath.row==0) {
            [cell.menuPicImageView setImage:[UIImage imageNamed:@"homemenu"]];
            [cell.menuButton setTitle:@"ALFRED MAP" forState:UIControlStateNormal];
            [cell.menuButton addTarget:self action:@selector(homeButton:) forControlEvents:UIControlEventTouchUpInside];
        }
        if (indexPath.row==1) {
            [cell.menuPicImageView setImage:[UIImage imageNamed:@"messageboard"]];
            [cell.menuButton setTitle:@"MESSAGE BOARD" forState:UIControlStateNormal];
            [cell.menuButton addTarget:self action:@selector(messageButton:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        if (indexPath.row==2) {
            [cell.menuPicImageView setImage:[UIImage imageNamed:@"profilemenu"]];
            [cell.menuButton setTitle:@"PROFILE" forState:UIControlStateNormal];
            [cell.menuButton addTarget:self action:@selector(profileButton:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        
        if (indexPath.row==3) {
            [cell.menuPicImageView setImage:[UIImage imageNamed:@"walletmenu"]];
            [cell.menuButton setTitle:@"MY WALLET" forState:UIControlStateNormal];
            [cell.menuButton addTarget:self action:@selector(myWalletButton:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        if (indexPath.row==4) {
            [cell.menuPicImageView setImage:[UIImage imageNamed:@"share menu"]];
            [cell.menuButton setTitle:@"SHARE" forState:UIControlStateNormal];
            [cell.menuButton addTarget:self action:@selector(shareButton:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        //        if (indexPath.row==5) {
        //            [cell.menuPicImageView setImage:[UIImage imageNamed:@"redeem menu"]];
        //            [cell.menuButton setTitle:@"REDEEM REWARDS" forState:UIControlStateNormal];
        //            [cell.menuButton addTarget:self action:@selector(redeemButton:) forControlEvents:UIControlEventTouchUpInside];
        //
        //        }
        if (indexPath.row==5) {
            [cell.menuPicImageView setImage:[UIImage imageNamed:@"register menu"]];
            [cell.menuButton setTitle:@"REGISTER AS DRIVER" forState:UIControlStateNormal];
            [cell.menuButton addTarget:self action:@selector(registerAsAdriverButton:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        
        return cell;
    }
    
    //driver switch section
    if ([indexPath section]==3) {
        
        static NSString *simpleTableIdentifier = @"SideBottomTableViewCell";
        SideBottomTableViewCell *cell = (SideBottomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SideBottomTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        
        
        if (indexPath.row==0) {
            static NSString *simpleTableIdentifier = @"SideMenuDriverTableViewCell";
            SideMenuDriverTableViewCell *cell = (SideMenuDriverTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
            
            
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SideMenuDriverTableViewCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            cell.selectionStyle = UITableViewCellEditingStyleNone;
            UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(30.0f, cell.bounds.size.height, cell.bounds.size.width-70.0f, 0.6f)];
            bottomLineView.backgroundColor = [UIColor grayColor];
            [cell.contentView addSubview:bottomLineView];
            
            driverSwitch = cell.driverSwitch;
            
            [driverSwitch addTarget:self action:@selector(driverSwitch:) forControlEvents:UIControlEventValueChanged];
            BOOL enabledAsDriver = [[PFUser currentUser][@"EnabledAsDriver"] boolValue];
            [driverSwitch setEnabled: enabledAsDriver];
            
            BOOL isUser = [[PFUser currentUser][@"UserMode"] boolValue];
            [driverSwitch setOn: !isUser];
            
            
            return cell;
            
        }
        
        //this is for leaving a space
        if (indexPath.row==1) {
            cell.bottomButton.hidden = YES;
            
        }
        
        
        if (indexPath.row==2) {
            issueButton = cell.bottomButton;
            
            
            [cell.bottomButton setTitle:@"Facing Issue? Need Help!" forState:UIControlStateNormal];
            [issueButton addTarget:self action:@selector(facingIssuesButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        if (indexPath.row==3) {
            
            aboutButton = cell.bottomButton;
            
            [cell.bottomButton setTitle:@"About" forState:UIControlStateNormal];
            [aboutButton addTarget:self action:@selector(aboutButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
            
        }
        if (indexPath.row==4) {
            
            feedbackButton = cell.bottomButton;
            
            [cell.bottomButton setTitle:@"Send Feedback" forState:UIControlStateNormal];
            
            [feedbackButton addTarget:self action:@selector(sendFeedbackButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
            
        }
        if (indexPath.row==5) {
            cell.bottomButton.hidden = YES;
            
        }
        
        return cell;
    }
    
    return cell;
}


-(void)facingIssuesButtonTouchUpInside:(id)sender{
    NSLog(@"Facing issues button touched");
    
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    //    controller.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    controller.navigationBar.tintColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:1];
    controller.navigationBar.translucent = NO;
    
    [ controller setToRecipients:@[@"info@alfredcarsharing.com"]];
    
    controller.mailComposeDelegate = self;
    [controller setSubject:@"Have an issue? Contact us , we are Happy to help 😄"];
    
    if (controller){
        [self presentModalViewController:controller animated:YES];
        
    }
    
    
    
    
    
    
}

-(void)sendFeedbackButtonTouchUpInside{
    NSLog(@"Send feedback button touched");
#warning Incomplete method implementation
}

-(void)aboutButtonTouchUpInside{
    
    NSLog(@"About button touched");
    
    SWRevealViewController *revealController = [self revealViewController];
    UIViewController *frontViewController = revealController.frontViewController;
    UINavigationController *frontNavigationController =nil;
    
    if ( [frontViewController isKindOfClass:[UINavigationController class]] )
        frontNavigationController = (id)frontViewController;
    
    
    if ( ![frontNavigationController.topViewController isKindOfClass:[AboutViewController class]] )
        
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardType bundle:nil];
        
        //        MessageBoardTableViewController *frontViewController = (MessageBoardTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MessageBoardID"];
        
        AboutViewController *frontViewController = (AboutViewController *)[storyboard instantiateViewControllerWithIdentifier:@"AboutViewControllerID"];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
        [revealController pushFrontViewController:navigationController animated:YES];
    }
    else{
        [revealController revealToggleAnimated:YES];
        
    }
    
    
    
    
}




-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    int section  = indexPath.section;
    int row = indexPath.row;
    
}

-(void)driverSwitch:(id)sender{
    
    
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLogin"];
    
    
    
    if (self.driverSwitch.on) {
        
        [PFUser currentUser][@"UserMode"] = @NO;
        NSNotificationCenter *notificationCenter =[NSNotificationCenter defaultCenter];
        
        [notificationCenter postNotificationName:@"didRequestForStoppingAllMappingServices" object:nil];
        
        
        
        [HUD showUIBlockingIndicatorWithText:@"Turning on..."];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL suceed, NSError *error){
            
            
            if(_driverStatus == nil){
                //not driver status yet, just create it
                
                PFObject *driverStatus = [PFObject objectWithClassName:@"DriverStatus"];
                driverStatus[@"available"] = @NO; //not available until fix location, and save settings
                driverStatus[@"active"] = @NO;
                driverStatus[@"inride"] = @NO;
                driverStatus[@"numberOfSeats"] = @4;
                driverStatus[@"ladiesOnly"] = @NO;
                driverStatus[@"pricePerSeat"] = [NSNumber numberWithDouble:2.0];
                driverStatus[@"user"] = [PFUser currentUser];
                
                
                
                [driverStatus saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if(succeeded){
                        
                        
                        _currentUser[@"driverStatus"] = driverStatus;
                        [_currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                            assert(succeeded);
                        }];
                        
                        [HUD hideUIBlockingIndicator];
                        [self homeButton:sender];
                    }
                }];
                
                
                
            }else{
                
                
                [_driverStatus fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                    if(!error){
                        
                        //now show correct map
                        [self homeButton:nil];
                        [HUD hideUIBlockingIndicator];
                        
                        
                    }else{
                        
                        assert(0);
                        
                    }
                }];
                
            }
        }]; //end of save user in background
        
    }else  {
        
        
        _currentUser[@"UserMode"] = @YES;
        
        [HUD showUIBlockingIndicatorWithText:@"Turning off..."];
        [_currentUser saveInBackgroundWithBlock:^(BOOL suceed, NSError *error){

            [HUD hideUIBlockingIndicator];
            if(suceed){
                [self homeButton:nil];

            }else{
                
                self.driverSwitch.on = YES;
                _currentUser[@"UserMode"] = @NO;
                [self.revealViewController revealToggleAnimated:YES];
                MDSnackbar *snackbar = [[MDSnackbar alloc] initWithText: @"Failed to turn off driver mode" actionTitle:nil];
                snackbar.multiline = YES;
                [snackbar show];
            }
            
        }];
        
    }
    
    [self.tableView reloadData];
    
    
    
}
//MAPS button pressed
-(void)homeButton:(id)sender{
    
    BOOL userMode = [_currentUser[@"UserMode"] boolValue];
    
    if (userMode) {
        // user mode
        
        SWRevealViewController *revealController = [self revealViewController];
        UIViewController *frontViewController = revealController.frontViewController;
        UINavigationController *frontNavigationController =nil;
        
        if ( [frontViewController isKindOfClass:[UINavigationController class]] )
            frontNavigationController = (id)frontViewController;
        
        
        if ( ![frontNavigationController.topViewController isKindOfClass:[RiderViewController class]] )
            
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardType bundle:nil];
            
            RiderViewController *frontViewController = (RiderViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MainPageId"];
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
            [revealController pushFrontViewController:navigationController animated:YES];
        }
        else{
            [revealController revealToggleAnimated:YES];
            
        }
        
        
        
    }
    else{
        //driver mode
        
        SWRevealViewController *revealController = [self revealViewController];
        UIViewController *frontViewController = revealController.frontViewController;
        UINavigationController *frontNavigationController =nil;
        
        if ( [frontViewController isKindOfClass:[UINavigationController class]] )
            frontNavigationController = (id)frontViewController;
        
        
        if ( ![frontNavigationController.topViewController isKindOfClass:[DriverViewController class]] )
            
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardType bundle:nil];
            
            DriverViewController *frontViewController = (DriverViewController *)[storyboard instantiateViewControllerWithIdentifier:@"DriverMainID"];
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
            [revealController pushFrontViewController:navigationController animated:YES];
        }
        else{
            [revealController revealToggleAnimated:YES];
            
        }
        
    }
    
    
}






-(void)messageButton:(id)sender{
    SWRevealViewController *revealController = [self revealViewController];
    UIViewController *frontViewController = revealController.frontViewController;
    UINavigationController *frontNavigationController =nil;
    
    if ( [frontViewController isKindOfClass:[UINavigationController class]] )
        frontNavigationController = (id)frontViewController;
    
    
    if ( ![frontNavigationController.topViewController isKindOfClass:[AlfredMessageBoardViewController class]] )
        
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardType bundle:nil];
        
        //        MessageBoardTableViewController *frontViewController = (MessageBoardTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MessageBoardID"];
        
        //show the message board created by me
        AlfredMessageBoardViewController *frontViewController = (AlfredMessageBoardViewController *)[storyboard instantiateViewControllerWithIdentifier:@"AlfredMessageBoardID"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
        [revealController pushFrontViewController:navigationController animated:YES];
    }
    else{
        [revealController revealToggleAnimated:YES];
        
    }
}

-(void)profileButton:(id)sender{
    SWRevealViewController *revealController = [self revealViewController];
    UIViewController *frontViewController = revealController.frontViewController;
    UINavigationController *frontNavigationController =nil;
    
    if ( [frontViewController isKindOfClass:[UINavigationController class]] )
        frontNavigationController = (id)frontViewController;
    
    
    if ( ![frontNavigationController.topViewController isKindOfClass:[ProfileTableViewController class]] )
        
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardType bundle:nil];
        
        ProfileTableViewController *frontViewController = (ProfileTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ProfileId"];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
        [revealController pushFrontViewController:navigationController animated:YES];
    }
    else{
        [revealController revealToggleAnimated:YES];
        
    }
    
}

-(void)rideButton:(id)sender{
    
    SWRevealViewController *revealController = [self revealViewController];
    UIViewController *frontViewController = revealController.frontViewController;
    UINavigationController *frontNavigationController =nil;
    
    if ( [frontViewController isKindOfClass:[UINavigationController class]] )
        frontNavigationController = (id)frontViewController;
    
    
    if ( ![frontNavigationController.topViewController isKindOfClass:[RidesHistoryTableViewController class]] )
        
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardType bundle:nil];
        
        RidesHistoryTableViewController *frontViewController = (RidesHistoryTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"RidesHistoryId"];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
        [revealController pushFrontViewController:navigationController animated:YES];
    }
    else{
        [revealController revealToggleAnimated:YES];
        
    }
    
}

-(void)myWalletButton:(id)sender{
    SWRevealViewController *revealController = [self revealViewController];
    UIViewController *frontViewController = revealController.frontViewController;
    UINavigationController *frontNavigationController =nil;
    
    if ( [frontViewController isKindOfClass:[UINavigationController class]] )
        frontNavigationController = (id)frontViewController;
    
    
    if ( ![frontNavigationController.topViewController isKindOfClass:[WalletViewController class]] )
        
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardType bundle:nil];
        
        WalletViewController *frontViewController = (WalletViewController *)[storyboard instantiateViewControllerWithIdentifier:@"WALLET_VIEW_CONTROLLER"];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
        [revealController pushFrontViewController:navigationController animated:YES];
    }
    else{
        [revealController revealToggleAnimated:YES];
        
    }
}

-(void)shareButton:(id)sender{
    SWRevealViewController *revealController = [self revealViewController];
    UIViewController *frontViewController = revealController.frontViewController;
    UINavigationController *frontNavigationController =nil;
    
    if ( [frontViewController isKindOfClass:[UINavigationController class]] )
        frontNavigationController = (id)frontViewController;
    
    
    if ( ![frontNavigationController.topViewController isKindOfClass:[ShareTableViewController class]] )
        
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardType bundle:nil];
        
        ShareTableViewController *frontViewController = (ShareTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ShareId"];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
        [revealController pushFrontViewController:navigationController animated:YES];
    }
    else{
        [revealController revealToggleAnimated:YES];
        
    }
    
}

-(void)redeemButton:(id)sender{
    SWRevealViewController *revealController = [self revealViewController];
    UIViewController *frontViewController = revealController.frontViewController;
    UINavigationController *frontNavigationController =nil;
    
    if ( [frontViewController isKindOfClass:[UINavigationController class]] )
        frontNavigationController = (id)frontViewController;
    
    
    if ( ![frontNavigationController.topViewController isKindOfClass:[RedeemRewardsTableViewController class]] )
        
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardType bundle:nil];
        
        RedeemRewardsTableViewController *frontViewController = (RedeemRewardsTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"RedeemRewardId"];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
        [revealController pushFrontViewController:navigationController animated:YES];
    }
    else{
        [revealController revealToggleAnimated:YES];
        
    }
    
}

-(void)registerAsAdriverButton:(id)sender{
    
    SWRevealViewController *revealController = [self revealViewController];
    UIViewController *frontViewController = revealController.frontViewController;
    UINavigationController *frontNavigationController =nil;
    
    if ( [frontViewController isKindOfClass:[UINavigationController class]] )
        frontNavigationController = (id)frontViewController;
    
    
    if ( ![frontNavigationController.topViewController isKindOfClass:[DriverRegistrationCarViewController class]] )
        
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        DriverRegistrationCarViewController *frontViewController = (DriverRegistrationCarViewController *)[storyboard instantiateViewControllerWithIdentifier:@"RegisterDriverId"];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
        //[revealController pushFrontViewController:navigationController animated:YES];
        [self presentViewController:navigationController animated:YES completion:nil];
    }
    else{
        // [revealController revealToggleAnimated:YES];
        
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([indexPath section]==0) {
        if (indexPath.row==0) {
            return 30;
        }
        else
            
            return 70;
        
    }
    if ([indexPath section]==1) {
        return 60;
    }
    if ([indexPath section]==2) {
        
        return 40;
    }
    else if ([indexPath section]==3){
        if (indexPath.row==0) {
            return 45;
        }
        if (indexPath.row==1) {
            return 10;
        }
        else
            return 30;
    }
    return 45;
    
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    
    [controller dismissViewControllerAnimated:YES completion:nil];
    
}





@end
